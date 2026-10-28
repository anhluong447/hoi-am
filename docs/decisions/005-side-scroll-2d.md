# ADR 005 — World 2D side-scroll

Quyết định của người dùng, 2026-10-28. Thay thế hướng [ADR 004](004-hd2d-world.md):
world không còn theo HD-2D top-down/isometric. Hướng mới: **Godot + 2D
side-scrolling**, đồ họa high-res painted, cinematic, lighting/effect đầy đủ,
**không pixel art**. Lý do: concept phòng CLB và hành lang hoàng hôn của repo
hai-vong (nhánh `feat/first3-art-direction`) là góc ngang; HD-2D hiện tại xa
concept đó. Repo hai-vong là nguồn cảm hứng — docs thiết kế của nó là bản mới
nhất cho Hồi Âm; runtime browser/pixel của nó không phải mục tiêu port.

Đỉnh cảm xúc của ba ngày đầu là trận debate/trial ở ngày 3, nhưng người dùng
chọn dựng môi trường side-scroll trước, debate làm ở đợt sau (cần brainstorm
riêng, ngoài phạm vi đợt này). Art hiện tại dùng placeholder do AI tạo
(Codex CLI, `image_generation`, có provenance); art thật thay sau mà không
sửa layout/code.

## Hệ quả

- Docs thiết kế mới nhất của hai-vong (Story Bible v2, GDD-Defense, GDD-Attack,
  RULES, các tài liệu narrative, First3Days gốc, bảng ánh xạ ba ngày đầu, 11
  concept PNG) được nhập byte-exact vào `docs/design/`, nguồn ghi ở
  `docs/design/SOURCES.json` (repository, branch, commit 40-hex, SHA-256 và số
  byte từng file). `tools/check_reference.py` xác minh các byte này không đổi.
- World HD-2D (ADR 004, HD00–HD09) được **archive, không xóa**: code, content,
  evidence giữ nguyên chỗ; `docs/world-hd2d/status.json` đánh dấu archived.
  HD-2D không còn là hướng triển khai tiếp; nó chỉ gỡ khỏi đường chạy chính khi
  mọi location có phòng 2D tương đương, việc đó không nằm trong đợt này.
- World 2D mới sống ở `src/world/side/` (content ở `content/world2d/`), theo
  thiết kế [2026-10-28-side-scroll-environment-design.md]
  (../superpowers/specs/2026-10-28-side-scroll-environment-design.md) và kế
  hoạch mốc E0–E4 ở `docs/superpowers/plans/`. Tiến độ theo dõi ở
  `docs/world-side/status.json`.
- Domain, GameSession, formula sandbox, save schema gameplay hiện có **giữ
  nguyên** trong đợt này; đổi hướng world không viết lại Bible v2/GDD ngay.
- `docs/ART-DIRECTION.md` viết lại phần world cho high-res painted cinematic;
  phần UI coastal đã duyệt 2026-10-11 không đổi.
- Skill `.claude/skills/making-story-side-scrollers/` dùng khi lên kế hoạch
  cảnh/slice cho world side-scroll.

Xem [kiến trúc world 2D](../ARCHITECTURE.md#world-2d-side-scroll) và
[world-side status](../world-side/status.json).
