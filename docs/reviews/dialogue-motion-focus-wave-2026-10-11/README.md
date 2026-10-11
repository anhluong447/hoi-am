# Hover/focus và nhịp sóng — 2026-10-11

Theo phản hồi của người dùng, bỏ khung focus xanh trên lựa chọn hội thoại.
Vùng nhận input vẫn cố định; focus bàn phím và hover được thể hiện bằng lớp
giấy vàng, màu chữ, mũi tên và phóng visual 1.04×. Các target ngoài lựa chọn
hội thoại giữ theme hiện có.

Sóng tăng biên độ từ 3 lên 5 px, chu kỳ chính từ 5.6 xuống 3.8 giây và chu kỳ
phụ từ 7.3 xuống 5.1 giây. Tuning nằm trong `content/ui/dialogue.json`.
Giữ nguyên bố cục, nhịp mở/đóng, tốc độ chữ và hiệu ứng hoa.

Xem [video](dialogue-motion-focus-wave-v1.mp4),
[hover](captures-v1/07-hover-draft.png) và
[focus bàn phím](captures-v1/08-keyboard-focus.png).
Chạy F5 → UI preview → **Mở lại chuyển cảnh** để xem trên máy thật.

Đã chạy `tools/verify.py`: architecture/reference/content, import, 689 headless
checks và bootstrap đều pass. `tools/verify_native.py`: 64 interaction checks
và 19 motion checks pass trên Forward+. Capture/movie chạy lại 19 motion checks
và lưu 19 PNG; kiểm tra ảnh hover/focus không còn khung xanh.

Video dùng cadence cố định 60 FPS để review chuyển động, không phải phép đo FPS
thực. Lần chỉnh này không chạy lại profiler hoặc export Windows. Giữ nguyên
[evidence và giới hạn hiệu năng trước đó](../dialogue-motion-2026-10-11/README.md).
Hashes của evidence mới nằm trong [evidence.json](evidence.json); không thay
captures, video hoặc inventory lịch sử.
