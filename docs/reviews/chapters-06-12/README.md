# Review Chapters 06–12

Ngày: 2026-10-10. Source hai-vong giữ nguyên. Đây là nghiệm thu migration kỹ thuật
và pipeline mẫu; không chứng nhận story/balance/art production hoàn chỉnh.

Playable nối room → NPC prompt → dialogue choice → GameSession → HUD. Sổ tay có
calendar, cases, quest, team, editorial feedback, personal, travel, reports và
three save slots. Commands bị reject hiện copy từ catalog; UI không tự commit
outcome. Dialogue-only/travel/walking không đổi progression. Modal đóng/huỷ và
repeat dispose được kiểm tra; controller không import world hoặc storage.

Full gameplay parity: 4 policies, 834 commands, gồm 84 ngày; so **toàn bộ state**,
logs/metrics/reports/people/articles và committed baseline. Tám traces bổ sung
calendar/guards/reassignment/publication/quest/personal kiểm tra từng accepted /
rejected state và events. Full formula parity: 8 policies, cả state/journal/reports
và baseline; display adapter giải quyết keyed names/labels/journal. Float tolerance
1e-8, integer/IDs/order exact. Reference baselines không regenerate.

Save tests gồm native semantic round-trip, backup/temp interruption, injected disk
failure, corrupt JSON/fields, future versions/content, wrong ruleset, legacy raw /
wrapped/browser saves và safe room restore. Xem
[ADR 003](../../decisions/003-native-saves-and-formula-v2.md).

Evidence cuối được khóa trong `evidence.json`, kết quả ở `full-results.json`,
`profile-summary-final.json`, `native-profile-final.json` và `logs/`.
`captures-v8/` là lượt review cuối, 23 ảnh gồm room high/low/perspective,
fog/glow/DOF A/B, walking, dialogue, 9 management panels, extension NPC/prompt/
graph và sandbox trước/sau benchmark. NPC extension đã mở dialogue qua input E
thật của engine. `playable-v3.mp4` dùng fixed cadence để review lifecycle/motion;
**không** dùng đo FPS. `inventory.json` giữ hash và lý do bảo tồn các lượt cũ:
v1 dừng vì node name, v2/v3 sửa tab/wrap, v5 phát hiện lỗi sandbox render,
v6/v7 đã sửa nhưng chưa có portal/prompt/quality fixes cuối.

Clean import từ snapshot Git không `.godot` đã chạy 650 headless checks, không
lỗi; native input suite có 18 checks, không lỗi. Kiểm tra bao gồm graph choice IDs
sau reorder, portal theo content, quality sau travel và safe spawn theo cả chiều
ngang lẫn chiều cao. Architecture: 59 runtime scripts, tối đa 199 dòng không rỗng;
928 catalog entries. Python tools compile và source oracles recapture khớp.

Native profiling dùng real clock, VSync off, cap 120 FPS, 1280×720 và 1920×1080;
14 runs × 300 measured frames sau warm-up 120 frames/run. Có walk/modal transitions.
Renderer Forward+/D3D12, NVIDIA RTX 3050 Ti Laptop GPU. Đây là short regression
capture; power-state/editor workload làm A/B có nhiễu. Budget 60 FPS là 16.67 ms;
frame p95 các lượt cuối 8.659–8.704 ms, GPU p95 tối đa 3.423 ms. Các số frame
đã chịu cap 120 FPS; không dùng chúng để suy FPS tối đa của GPU.
Không suy cost effect bằng hiệu nhỏ hơn biến động của sample. GPU query và CPU
render setup theo [RenderingServer docs](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html).

Debug và release Windows export đã chạy trong folder sạch không project.godot,
source checkout, Node hoặc Python; kiểm tra gameplay, panels, user save/load,
ruleset isolation, packaged JSON/font glyphs, room travel và sandbox benchmark
thật. Distribution có
engine/font licenses. Preset theo
[Godot Windows export docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).

Giới hạn visual được giữ rõ:

- Phòng CLB là authored **asset/pipeline sample**, chưa có richness/portrait/city
  giống concept. Các location khác là prototype. Sprite shadow dùng capsule proxy.
- Dialogue giữ wave/paper/harbor/flowers/notebook native layers và catalog text;
  typography/paper/alpha vẫn có khoảng cách với concept. HUD hiện là composition
  chơi được, chưa đạt pixel parity với `03-hud-map.png`; G2 còn mở.
- Workspace có layout/focus/long text/motion đã review. Dialogue fade là technical
  preset, không dùng nó để đóng static gate còn mở. Chưa nghiệm thu motion toàn bộ
  màn hình theo source G3, portrait expressions hoặc gamepad vật lý.
- 60 FPS budget pass chỉ trên device/scene/resolution của evidence; chưa có stress
  campaign nhiều NPC, target GPU yếu, controller phần cứng hoặc soak test dài.

Pipeline extension đã thử qua room/NPC/graph/case thật;
[authoring guide](../../CONTENT-AUTHORING.md) ghi source/provenance và bước chạy.
Mesh/material sample là dữ liệu và shader authored trong project; provenance,
nguồn, import và hash của kit ở `world-kit-manifest.json`. Captured source assets,
masters, prompts và baseline trước migration giữ nguyên byte.

Phần còn lại của roadmap là **C11.05**: refine paper/material/typography/icon và
attached art của dialogue/HUD bằng isolated captures trên design plane 1672×941;
so đúng UI scope và mask, giữ các fringe alpha chưa chắc chắn. Không đóng G2 bằng
headless parity, world sample, fade animation hoặc giới hạn sai số tự đặt. Giữ
checklist này mở; technical handoff Chapter 12 không đồng nghĩa toàn bộ roadmap
đã nghiệm thu visual.
