# Local Chrome DevTools transport for authoring capture and verification.
import base64
import hashlib
import json
import os
import socket
import struct
from urllib.parse import urlparse


class DevTools:
    """Minimal local CDP transport: masked client frames, fragmentation and ping."""
    def __init__(self, url):
        parsed = urlparse(url)
        if parsed.scheme != 'ws' or parsed.hostname not in ('localhost', '127.0.0.1'):
            raise ValueError('DevTools must be a local WebSocket')
        self.socket = socket.create_connection((parsed.hostname, parsed.port), timeout=25)
        self.buffer = b''
        self.sequence = 0
        key = base64.b64encode(os.urandom(16)).decode('ascii')
        request = (f'GET {parsed.path} HTTP/1.1\r\nHost: {parsed.netloc}\r\n'
                   f'Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\n'
                   'Sec-WebSocket-Version: 13\r\n\r\n')
        self.socket.sendall(request.encode('ascii'))
        while b'\r\n\r\n' not in self.buffer:
            chunk = self.socket.recv(4096)
            if not chunk:
                raise RuntimeError('DevTools closed during handshake')
            self.buffer += chunk
        headers, self.buffer = self.buffer.split(b'\r\n\r\n', 1)
        expected = base64.b64encode(hashlib.sha1((key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11').encode()).digest())
        if b' 101 ' not in headers.split(b'\r\n', 1)[0] or expected not in headers:
            raise RuntimeError('Invalid DevTools handshake')

    def read(self, size):
        chunks = []
        if self.buffer:
            chunks.append(self.buffer[:size])
            size -= len(chunks[0])
            self.buffer = self.buffer[len(chunks[0]):]
        while size:
            chunk = self.socket.recv(min(size, 65536))
            if not chunk:
                raise RuntimeError('DevTools socket closed')
            chunks.append(chunk)
            size -= len(chunk)
        return b''.join(chunks)

    def send(self, payload, opcode=1):
        size = len(payload)
        header = bytes([0x80 | opcode])
        if size < 126:
            header += bytes([0x80 | size])
        elif size < 65536:
            header += bytes([0x80 | 126]) + struct.pack('>H', size)
        else:
            header += bytes([0x80 | 127]) + struct.pack('>Q', size)
        mask = os.urandom(4)
        self.socket.sendall(header + mask + bytes(value ^ mask[i % 4] for i, value in enumerate(payload)))

    def receive(self):
        message = []
        while True:
            first, second = self.read(2)
            opcode, size = first & 15, second & 127
            if size == 126:
                size = struct.unpack('>H', self.read(2))[0]
            elif size == 127:
                size = struct.unpack('>Q', self.read(8))[0]
            mask = self.read(4) if second & 128 else None
            payload = self.read(size)
            if mask:
                payload = bytes(value ^ mask[i % 4] for i, value in enumerate(payload))
            if opcode == 8:
                raise RuntimeError('DevTools closed')
            if opcode == 9:
                self.send(payload, 10)
                continue
            if opcode == 10:
                continue
            message.append(payload)
            if first & 128:
                return json.loads(b''.join(message))

    def call(self, method, params=None):
        self.sequence += 1
        self.send(json.dumps({'id': self.sequence, 'method': method, 'params': params or {}}).encode('utf-8'))
        while True:
            result = self.receive()
            if result.get('id') != self.sequence:
                continue
            if 'error' in result:
                raise RuntimeError(f'{method}: {result["error"]}')
            return result.get('result', {})

    def evaluate(self, expression, await_promise=False):
        result = self.call('Runtime.evaluate', {'expression': expression, 'returnByValue': True,
                                               'awaitPromise': await_promise})
        if 'exceptionDetails' in result:
            raise RuntimeError(f'Capture page exception: {result["exceptionDetails"]}')
        return result.get('result', {}).get('value')
