# Hồi Âm — Godot

Project Godot độc lập cho game tòa soạn học đường ở Hải Vọng. Định hướng:
môi trường 3D, nhân vật sprite 2D, UI coastal 2D; PC/Forward+ là mục tiêu ban đầu.

`../hai-vong/` giữ nguyên làm nguồn đối chứng. Project này có thể phát triển kiến
trúc riêng, không phụ thuộc JavaScript, HTML hay checkout cũ khi chạy game.

## Bắt đầu

Mở `project.godot` bằng Godot 4.7.2 và nhấn F6 trên
`src/bootstrap/main.tscn` hoặc F5. Màn đầu có ba lối vào:

- **Khám phá phòng CLB**: greybox 3D, sprite Khuê/Vân, WASD/mũi tên để đi,
  E để xem target, Esc để quay lại. Cửa phát portal ID rồi trả về spawn an toàn;
  chưa có phòng sân trường 3D. Di chuyển không đổi gameplay time.
- **Vòng ngày và công việc**: session thật; đi học → kết thúc CLB → các slot
  nghỉ/điều tra → ngủ. HUD lấy state thật, lệnh sai bị từ chối. Mỗi lần vào
  preview tạo session mới; chưa có save/load hay tích hợp world-dialogue-command.
- **Xem giao diện coastal**: dialogue/HUD độc lập, đổi nền sáng/tối/chi tiết,
  focus bằng Tab, chọn bằng Enter hoặc chuột. Text/choice/notebook copy từ catalog.

Chapter 01–05 đã có implementation và evidence; static visual G2 còn mở.
Đây là bản kỹ thuật để phát triển tiếp, chưa phải gameplay đầy đủ/production art.
F6 chạy riêng các scene trong `src/bootstrap/previews/`.

```powershell
python tools/check_architecture.py
python tools/check_reference.py
python tools/check_content.py
python tools/verify.py --godot 'D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe'
python tools/verify_native.py --godot 'D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe'
```

Ngoài đường dẫn ví dụ trên, có thể truyền executable khác hoặc đặt `GODOT_PATH`.
Game chỉ cần Godot; Python là tooling phát triển. Node chỉ dùng cho bước import
content/oracle từ ES module đã thực hiện, không phải dependency của runtime.
Chromium chỉ cần khi rebuild art SVG có filter, không cần cho gameplay/checks.

## Tài liệu hiện hành

- [Roadmap theo chapter](docs/migration/README.md)
- [Kiến trúc và ranh giới](docs/ARCHITECTURE.md)
- [Workflow phát triển](docs/DEVELOPMENT.md)
- [Quy tắc authoring content](content/README.md)
- [Hướng nghệ thuật 2.5D và UI](docs/ART-DIRECTION.md)
- [Nguồn tham chiếu và baseline](docs/reference/README.md)
- [Kết quả kiểm tra foundation](docs/reviews/foundation.md)
- [Review Chapter 01–05 và hình native](docs/reviews/chapters-01-05/README.md)
- [Source mapping](docs/migration/source-mapping.md)
- [Schema gameplay v3](docs/decisions/002-gameplay-state-v3.md)

Git repository riêng dùng branch `main` tại
[anhluong447/hoi-am](https://github.com/anhluong447/hoi-am). Commit
source, content, `.gd.uid`, scene, tài liệu và nguồn art; `.godot/` và build outputs
là cache. Reference snapshots có Git attributes giữ nguyên byte qua checkout.
