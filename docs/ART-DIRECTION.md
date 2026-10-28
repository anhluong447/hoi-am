# Hướng nghệ thuật và ranh giới review

## Hướng đã chốt

Theo [ADR 005](decisions/005-side-scroll-2d.md) (2026-10-28), world chuyển sang
**Godot 2D side-scroll**, đồ họa high-res painted, cinematic, lighting/effect đầy
đủ, **không pixel art**. Hướng HD-2D/Octopath-style trước đó
([ADR 004](decisions/004-hd2d-world.md)) được archive, không còn là mục tiêu world
mới; mục "World (archived)" bên dưới giữ làm tài liệu lịch sử. Không nhập asset
hoặc giả định chính xác pipeline nội bộ của tựa game tham khảo.

Mốc trực quan chính cho khám phá là
[03-hud-map.png](reference/coastal-editorial-v1/03-hud-map.png). Đây là concept,
không phải screenshot runtime hay mesh scene có thể import trực tiếp.

## Hai track độc lập

| Track | Phải kiểm chứng | Không dùng làm điều kiện chặn |
| --- | --- | --- |
| UI | Hình, bố cục, giấy/mực, type/icon, flowers/notebook/harbor attached, light/motion/focus | Room/portrait/camera giống concept |
| World | Camera, tỷ lệ, movement, occlusion, sprite readability, nắng/bóng/atmosphere, performance | UI đã hoàn tất replica |

Track world trước đây deferred ở source; nay trở thành workstream chính của
migration. Việc này không thay đổi phạm vi visual gate UI đã được người dùng chốt.
UI tĩnh/motion ở source còn G2/G3 mở; port engine không tự đóng các gate đó.

## World

Hướng hiện tại là 2D side-scroll high-res painted cinematic; chi tiết kỹ thuật ở
[design doc](superpowers/specs/2026-10-28-side-scroll-environment-design.md) và
skill `.claude/skills/making-story-side-scrollers/`.

- **Colour script theo buổi**: mỗi phòng có preset Sáng/Chiều/Tối/Đêm
  (`content/world2d/lighting/<room>.json`) — grade, màu/năng lượng light, màu
  bóng, mật độ bụi, tint nước. Chuyển buổi nội suy preset, không hard-cut.
- **Ánh sáng chủ yếu vẽ sẵn trong art** (painted light/shadow trong từng lớp);
  runtime chỉ thêm tối đa vài light có động cơ (cửa sổ, đèn bàn), một vệt nắng
  additive và `CanvasModulate`/grade theo buổi. Không rely runtime lighting để
  tạo mood chính.
- **Readability kiểm bằng greyscale**: mọi composition phải đọc được khối
  sáng/tối khi bỏ màu trước khi coi là đạt; nhân vật phải nổi trên nền painted
  ở mọi buổi, không bị hiệu ứng (bụi, glow, DOF) lấn át.
- **Kit nhiều lớp**, không phải một background phẳng: sky/far/back/mid/actor/
  foreground riêng theo `plane` trong content, mỗi lớp có `art_ref` riêng để
  parallax và occlusion đúng; foreground che nhân vật theo `sort_y`/alpha, không
  dùng một ảnh concept cắt dán làm nền tĩnh.
- **Placeholder AI có provenance bắt buộc**: ảnh tạo bằng Codex CLI
  (`image_generation`), prompt lưu ở `assets/world2d/<room>/source/prompts.json`,
  `content/world2d/art_manifest_v1.json` ghi `status` (`placeholder_ai` |
  `final`) và nguồn gốc (tool, prompt, ngày, hash). Placeholder không được coi
  là art đã duyệt; thay art thật chỉ đổi file + manifest, không đổi layout,
  collision hay code.
- PC Forward+ là giả định ban đầu; HDR 2D/glow trên Canvas layer, UI coastal
  nằm ngoài vùng glow/grade. Web/mobile chưa là acceptance target.
- Toạ độ layout là world units độc lập độ phân giải ảnh (px/unit khai báo
  trong art manifest); đổi ảnh khác độ phân giải không được đổi toạ độ.

## World (archived — HD-2D, xem ADR 005)

Mục này giữ nguyên làm tài liệu lịch sử cho hướng HD-2D trước đây
([ADR 004](decisions/004-hd2d-world.md)); không còn là hướng triển khai tiếp.

- Room/props lấy chi tiết từ art 2D trên surface/cutout nhiều lớp; geometry đơn
  giản hỗ trợ collision và bóng. Nhân vật sprite trên plane, di chuyển trên XZ.
- Camera góc nghiêng được kiểm soát. So perspective FOV nhỏ với orthographic ở
  blockout trước khi khóa, ghi camera transform/FOV/size trong evidence.
- Sprite nearest filtering, pixel density và projected size phải được thử cùng
  camera; tránh default billboard khiến silhouette nghiêng hoặc bóng như tấm bìa.
- Nhận sáng, alpha depth và bóng của sprite có review riêng; dùng shadow proxy
  nếu cần. Không giả định sprite 2D tự có khối 3D.
- Nắng cửa sổ, local lights, ambient/cool-warm grading, dust và depth of field
  được bổ sung theo budget. Không bật mọi hiệu ứng mặc định hay dùng blur để che art.
- Room art phải được xây từ source meshes/textures, không biến concept PNG thành
  một background duy nhất nếu cần di chuyển, occlusion và shadow động.

## UI

Giữ design plane 1672×941, uniform fit/letterbox. UI nằm ngoài world DOF/fog;
text rõ và hitbox ổn định. Prompt tương tác project world position sang UI bằng
adapter nhỏ, xử lý off-screen/occlusion, không sửa domain để theo camera.

Paper, wave, flowers, notebook và harbor print là UI. World cây/bàn/báo/cốc là
context; portrait và background thay được. Tách các lớp theo animation/hit target;
không dùng full-screen screenshot có text làm runtime UI.

Các ảnh/metadata tham chiếu nằm ở [reference](reference/README.md). Source scope
JSON giữ nguyên như historical snapshot; đường dẫn mask runtime cũ trong snapshot
không phải resource contract mới. Khi port asset pack sẽ có manifest riêng.

## Acceptance

Ngày 2026-10-11, người dùng chấp nhận UI tĩnh và yêu cầu giữ bố cục, chỉ phát triển
motion hội thoại. Static diagnostics lịch sử giữ làm tham khảo, không chặn motion.
Blur-in được cho phép trên ký tự mới xuất hiện; phần đã đọc phải sắc nét, và một
lần bấm hoàn tất câu cùng blur. World DOF/fog vẫn không tác động tới UI. Idle dùng
sóng nhẹ và hoa đung đưa, giữ giấy và chữ ổn định.

UI: captures neutral/bright/dark/detailed, fixture và thời điểm xác định, mask
theo UI; uncertain fringe alpha vẫn cần review bằng mắt. World: still/video lúc
đứng, đi, bị che, đổi light preset, cùng GPU/device ghi rõ. Performance: đo realtime
Forward+ trên máy thật, tách cost UI/world; headless không chứng nhận GPU hoặc FPS.

Godot tham khảo:
[Sprite3D](https://docs.godotengine.org/en/stable/classes/class_sprite3d.html),
[environment/post-processing](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html),
[renderer capabilities](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).
