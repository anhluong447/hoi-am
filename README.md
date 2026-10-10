# Hồi Âm — Godot

Project Godot độc lập cho game tòa soạn học đường ở Hải Vọng. Định hướng:
môi trường 3D, nhân vật sprite 2D, UI coastal 2D; PC/Forward+ là mục tiêu ban đầu.

`../hai-vong/` giữ nguyên làm nguồn đối chứng. Project này có thể phát triển kiến
trúc riêng, không phụ thuộc JavaScript, HTML hay checkout cũ khi chạy game.

## Bắt đầu

Mở `project.godot` bằng Godot 4.7.2 và nhấn F6 trên
`src/bootstrap/main.tscn` hoặc F5. Hiện có màn boot với text từ catalog và nút thoát;
world/gameplay chưa được port. Đây là skeleton, chưa phải bản demo 2.5D.

```powershell
python tools/check_architecture.py
python tools/check_reference.py
python tools/verify.py --godot 'D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe'
```

Ngoài đường dẫn ví dụ trên, có thể truyền executable khác hoặc đặt `GODOT_PATH`.
Game chỉ cần Godot; Python là tooling phát triển. Node chỉ dùng cho bước import
catalog từ ES module đã thực hiện, không phải dependency của runtime.

## Tài liệu hiện hành

- [Roadmap theo chapter](docs/migration/README.md)
- [Kiến trúc và ranh giới](docs/ARCHITECTURE.md)
- [Workflow phát triển](docs/DEVELOPMENT.md)
- [Quy tắc authoring content](content/README.md)
- [Hướng nghệ thuật 2.5D và UI](docs/ART-DIRECTION.md)
- [Nguồn tham chiếu và baseline](docs/reference/README.md)
- [Kết quả kiểm tra foundation](docs/reviews/foundation.md)

Git repository riêng dùng branch `main` tại
[anhluong447/hoi-am](https://github.com/anhluong447/hoi-am). Commit
source, content, `.gd.uid`, scene, tài liệu và nguồn art; `.godot/` và build outputs
là cache. Reference snapshots có Git attributes giữ nguyên byte qua checkout.
