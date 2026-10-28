# E2 — side-scroll greybox v3

Ngày 2026-10-28. Evidence kỹ thuật cho bảy phòng side-scroll; **chờ người dùng
chơi và review E2 trước khi lên plan E3**. Đây là greybox, không nghiệm thu art cuối.

## Kiểm chứng

- `python tools/verify.py --godot <Godot 4.7.2>`: 1129 headless checks, 0 failures;
  policies, reference/content integrity, import và bootstrap smoke qua.
- Walkthrough `tests/native_side_rooms.gd`: **265 checks, 0 failures, 28 captures**.
  Luồng: room3 → corridor → gate → office → gate → corridor → class → corridor →
  canteen → corridor → room3; sau đó travel home.
- Đi bằng action input của Godot, tương tác qua viewport input; kiểm cửa/spawn,
  giải phóng phòng cũ, prompt và nhãn địa điểm HUD, bounds, khóa input trong/qua exit
  thoại Vân, một lần reveal không dispatch choice, save v2 và import save v1 thật.
  Store kiểm thử nằm riêng trong `saves/`, không ghi đè save của người chơi.
- Gate native đầy đủ sau các sửa lỗi: **455 checks, 0 failures** — side rooms 265,
  interaction 68, dialogue motion 19, HD-2D 24, HD-2D locations 79. Lượt cuối chạy
  `verify_native.py` không có `--side-output` nên tạo capture phụ trong artifacts;
  ảnh v3 được giữ nguyên. Log gốc chụp v3 ở `native-side-rooms-capture.log`;
  logs của gate cuối ở `logs/`.

Lệnh tạo evidence này:

```powershell
python tools/verify_native.py --godot 'D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe' --side-output res://docs/world-side/evidence/e2-greybox-v3
```

Để chạy lại, dùng một output version **chưa tồn tại**. Run thường không có
`--side-output` sẽ tạo thư mục mới trong `artifacts/native-side-rooms/`.

## Máy và cách chụp

Godot 4.7.2-stable Steam, Windows 11 (10.0.26300), i7-11800H,
NVIDIA RTX 3050 Ti Laptop GPU, Forward+/D3D12. Editor của người dùng vẫn mở.
Native, cap 60 FPS, physics 60 Hz, không `--fixed-fps`/movie/headless. Cửa sổ test
không nhận focus/mouse OS; input fixture được gửi thẳng qua Godot. Không thay thế
kiểm thử bàn phím/gamepad vật lý.

PNG 1920×1080: pixel viewport native được copy nguyên tỉ lệ lên canvas đen bằng
kích thước cửa sổ để giữ letterbox `KEEP`; **không resize nội dung render**.
Từng capture kiểm viewport nằm trong cửa sổ và PNG đúng kích thước.
`report.json.viewport_texture` được đọc cuối phiên, sau các thao tác save/HD-2D,
nên không dùng nó làm kích thước nguồn tại thời điểm chụp (minor đã ghi trong review).

Các buổi được chọn bằng lighting API để so sánh, không chạy lệnh thay lịch gameplay.
Vì vậy HUD vẫn ghi ngày/buổi của state gốc trong cả ảnh lighting đêm. Nhãn địa điểm
phải đổi đúng theo location thực; regression này đã được sửa và kiểm tra.

## Ảnh

| Phòng | Sáng | Chiều | Tối | Đêm |
| --- | --- | --- | --- | --- |
| Phòng số 3 | [ảnh](room3_2d-sang.png) | [ảnh](room3_2d-chieu.png) | [ảnh](room3_2d-toi.png) | [ảnh](room3_2d-dem.png) |
| Hành lang C | [ảnh](corridor_c_2d-sang.png) | [ảnh](corridor_c_2d-chieu.png) | [ảnh](corridor_c_2d-toi.png) | [ảnh](corridor_c_2d-dem.png) |
| Cổng trường | [ảnh](school_gate_2d-sang.png) | [ảnh](school_gate_2d-chieu.png) | [ảnh](school_gate_2d-toi.png) | [ảnh](school_gate_2d-dem.png) |
| Phòng giám thị | [ảnh](discipline_office_2d-sang.png) | [ảnh](discipline_office_2d-chieu.png) | [ảnh](discipline_office_2d-toi.png) | [ảnh](discipline_office_2d-dem.png) |
| Lớp 11A3 | [ảnh](class_11a3_2d-sang.png) | [ảnh](class_11a3_2d-chieu.png) | [ảnh](class_11a3_2d-toi.png) | [ảnh](class_11a3_2d-dem.png) |
| Căng tin | [ảnh](canteen_2d-sang.png) | [ảnh](canteen_2d-chieu.png) | [ảnh](canteen_2d-toi.png) | [ảnh](canteen_2d-dem.png) |
| Phòng trọ | [ảnh](home_room_2d-sang.png) | [ảnh](home_room_2d-chieu.png) | [ảnh](home_room_2d-toi.png) | [ảnh](home_room_2d-dem.png) |

Review ảnh: tầng nền/mặt sàn/prop phân biệt được, silhouette nhân vật đọc được qua
bốn buổi, prop không che phần đầu ở các vị trí chụp, prompt và coastal UI rõ.
Đây chỉ là các khung hình cố định; người dùng cần chơi thử chuyển phòng/đi lại.

## Giới hạn và lịch sử

Frame p95 trong `report.json` là quan sát wall-clock khi đi 10 giây mỗi phòng,
chịu cap/VSync và workload máy. Không kết luận GPU budget, 60 FPS trên iGPU hay
native export từ kết quả này. Đo Intel UHD vẫn hoãn theo quyết định người dùng;
không mở lại profiling. Chưa tạo build Windows mới trong Task 10.

[v1](../e2-greybox-v1/README.md) giữ ảnh trước sửa nhãn HUD;
[v2](../e2-greybox-v2/README.md) giữ lượt native không hoàn tất.
Không ghi đè hai version đó hoặc baseline/source cũ. Các điều chỉnh và minor còn
lại được ghi ở [review-notes](review-notes.md).

`manifest.json` kiểm kê SHA-256/bytes của ảnh, reports, logs và các input được chọn;
`sources/` giữ bản sao byte của runner, navigation/save/world code và content đã
kiểm tra. Không dùng contact-sheet thumbnail thay ảnh PNG gốc để nghiệm thu.
