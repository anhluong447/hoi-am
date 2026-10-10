# Foundation review — 2026-10-10

Trạng thái: foundation verified; các chapter migration tiếp theo chưa bắt đầu.

## Phạm vi

Main boot, WorldRoot/Interface separation, JSON content/locale, TextCatalog,
GameSession ownership contracts, minimal bootstrap view/theme và tooling.
Nhập 18 reference/font files nguyên byte, 799 catalog entries; source giữ nguyên.

## Chưa thuộc nghiệm thu này

Gameplay/formula mechanics, room 2.5D, actor rig, coastal replica/motion, persistence,
device performance và native export. Boot screen là foundation, không chứng nhận
concept parity hoặc game đã playable.

## Kiểm tra thực tế

| Check | Kết quả |
| --- | --- |
| Target architecture/catalog/resources/docs links | 0 issues, 5 runtime scripts, 799 entries |
| Reference integrity | 18 locked copies, 4 concept hashes match |
| Godot headless editor import | Pass |
| Headless contracts | 33 checks, 0 failures |
| Headless bootstrap smoke | Pass |
| MCP native debug boot | Forward+ D3D12, NVIDIA RTX 3050 Ti Laptop, errors: [] |
| Source architecture | 0 issues, 798 entries |
| Source git status | Clean, không sửa project tham chiếu |

Command: `python tools/verify.py --godot <Steam Godot executable>`. Verify đọc
stdout/stderr và log file, nhận diện completion marker của suite. Các contracts
kiểm tra missing-key/parameter, non-recursive interpolation, snapshot/result/event
aliasing, rejected/invalid commands, strict boolean callback result, validator
error preservation, content-root traversal và bootstrap/window title từ catalog.

MCP run đã được stop sau smoke; editor người dùng đang mở không bị stop.
Runtime files hiện 16–47 nonblank lines. Tại thời điểm review foundation, Git
target đã init main, chưa commit/push.
Raw engine logs của lần verify nằm trong `artifacts/verification/` (local ignored).
Source revision và copy hashes ở [inventory](../reference/import-inventory.json).

Native smoke chỉ xác nhận startup không lỗi trên máy này, không phải visual
review, benchmark GPU hay export validation. Browser suite không chạy vì source
runtime/UI/content không thay đổi; test Godot thay cho browser tests ở target.
