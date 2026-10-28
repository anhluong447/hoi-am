# Môi trường 2D side-scroll cho 3 ngày đầu — design

Ngày: 2026-10-28. Trạng thái: **bản thiết kế chờ người dùng duyệt**, chưa triển khai.
Skill áp dụng: `.claude/skills/making-story-side-scrollers/`.

## 1. Ý định và lý do

Người dùng chuyển hướng Hồi Âm (2026-10-28) sang **Godot + 2D side-scrolling**, đồ họa
**high-res painted, cinematic, lighting và effect đầy đủ — không pixel**. Concept phòng
CLB và hành lang hoàng hôn của repo hai-vong (nhánh `feat/first3-art-direction`) vốn là
góc ngang; HD-2D top-down hiện tại xa concept. Repo hai-vong là nguồn cảm hứng, docs
thiết kế của nó là bản mới nhất; runtime browser/pixel của nó không phải mục tiêu.

Đỉnh cảm xúc của 3 ngày đầu sẽ là **trận debate trial ở ngày 3** (người dùng, 2026-10-28),
nhưng người dùng chọn **làm môi trường trước, debate để sau**. Đợt này dựng sân khấu: 7 địa
điểm của First3Days đi lại được, có chiều sâu, ánh sáng theo buổi và không khí, dùng
**placeholder AI** để sau thay art thật mà không sửa code/layout.

## 2. Mục tiêu

1. Tầng world mới `src/world2d/`: phòng side-scroll nhiều lớp parallax, foreground che,
   actor đi trái/phải trên một làn, camera follow có giới hạn, cửa nối phòng, điểm tương tác.
2. Bảy không gian của First3Days đi lại được: cổng trường, phòng giám thị, lớp 11A3,
   hành lang dãy C, Phòng số 3, phòng trọ, căng tin.
3. Ánh sáng/không khí theo buổi (Sáng, Chiều, Tối, Đêm) là content: grade, light,
   nắng xuyên cửa, bụi, sóng/nước, sương; reduced-motion tắt chuyển động.
4. Phòng số 3 là **beauty corner**: đạt chất lượng trình bày cao nhất có thể với
   placeholder, đo thời gian làm từng loại asset để ước lượng phần còn lại.
5. Art placeholder do AI tạo, có provenance; thay art = đổi file + manifest, không đổi
   layout, collision, interaction hay code.
6. Docs thiết kế mới nhất của hai-vong được nhập vào `docs/design/`, có decision record
   cho chuyển hướng; HD-2D được archive, không xóa.

## 3. Không làm (non-goals)

- Trận debate THỦ/CÔNG và trial ngày 3 (đợt sau, cần brainstorm riêng).
- Viết lại domain theo Bible v2/GDD (energy 10/5, ba loại quest, phân công…). Domain,
  GameSession, formula sandbox giữ nguyên trong đợt này.
- Kịch bản/cutscene 3 ngày, staging hội thoại theo beat, NPC theo lịch First3Days.
- Art cuối, animation cuối của nhân vật, nhạc/SFX sản xuất.
- Đổi UI coastal/dialogue đã được duyệt 2026-10-11.

## 4. Anti-goals (làm vậy là thất bại dù chạy được)

- Placeholder bị coi là art đã duyệt, hoặc có ảnh AI không log provenance lọt vào build.
- Chữ đọc được nướng vào ảnh; text không qua `TextCatalog`.
- Layout/collision phụ thuộc kích thước ảnh, khiến thay art phải sửa toạ độ.
- Hiệu ứng lấn át nhân vật: nhân vật không đọc được trên nền painted.
- Xóa/ghi đè evidence HD-2D hoặc baseline cũ.
- Tuyên bố hiệu năng từ headless.

## 5. Ràng buộc (từ `AGENTS.md`)

Text chỉ ở `content/locales/vi.json`; layout/tuning ở `content/`; một file một vai trò,
≤200 dòng nonblank; world không sở hữu lịch/energy/tiền/save; composition owns
dependencies, scene emit signal local; save field mới cần validator, review version,
migration, fixtures; chạy `tools/check_architecture.py`, `check_reference.py`,
`check_content.py`, `verify.py --godot <exe>`, `verify_native.py --godot <exe>` và
evidence hình ảnh mới cho thay đổi world; không sửa `../hai-vong/`.

## 6. Quyết định của người dùng

- Godot + 2D side-scroll, high-res cinematic, không pixel.
- Docs mới nhất lấy từ repo hai-vong.
- Debate ngày 3 là climax, làm sau; môi trường trước.
- Art hiện tại: AI tạo placeholder; art thật thay sau.

## 7. Thiết kế (các lựa chọn dưới đây là **đề xuất của người viết**, chờ duyệt)

### 7.1 Địa điểm và phòng — không đổi domain

Domain đã có `location_id` (school, club, home, …) và save lưu `world.room_id`.
Ánh xạ bảy không gian vào location sẵn có, phòng là khái niệm chỉ của world:

| Không gian | location_id | room_id mới |
| --- | --- | --- |
| Cổng trường | school | `school_gate_2d` |
| Phòng giám thị | school | `discipline_office_2d` |
| Lớp 11A3 | school | `class_11a3_2d` |
| Hành lang dãy C | school | `corridor_c_2d` |
| Căng tin | school | `canteen_2d` |
| Phòng số 3 | club | `room3_2d` |
| Phòng trọ | home | `home_room_2d` |

Đi qua cửa giữa các phòng cùng location là thao tác world thuần (không tốn thời gian,
không qua command). Đổi location vẫn dùng luồng travel hiện có. `playable.gd.travel()`
hiện chỉ đổi `controller.location_id` và mount phòng, không tốn thời gian trong domain;
vì vậy cửa hành lang C → Phòng số 3 (khác location) được phép là cửa `travel` không tốn
thời gian, giống hành vi travel hiện nay. Các location khác
(library, cafe, shop, job, waterfront) giữ phòng HD-2D cho tới khi có phòng 2D, để game
vẫn chạy trọn vẹn trong thời gian chuyển đổi.

Nối phòng (đề xuất, theo First3Days: dãy C tầng trệt có Phòng số 3):
cổng trường ↔ phòng giám thị; cổng trường ↔ hành lang C; hành lang C ↔ lớp 11A3,
căng tin, Phòng số 3. Travel tới `school` vào cổng trường; tới `club` vào Phòng số 3;
tới `home` vào phòng trọ. Interaction targets hiện có giữ nguyên location: target của
`club` đặt trong Phòng số 3, của `school` ở hành lang C, của `home` ở phòng trọ.

### 7.2 Định nghĩa phòng (content)

`content/world2d/rooms/<room_id>.json`, schema có version, validator thuần:

- `bounds` (x min/max theo world units), `floor_y`, `spawns` (id → x, facing).
- `layers[]`: id, `plane` (sky, far, back, mid, actor, foreground), `scroll_scale`,
  `art_ref` (khóa trong art manifest), `anchor`, `z`, `blur` (pre-blurred hay không).
- `props[]`: id, `art_ref`, vị trí, pivot, `sort_y`, `occludes_actor`, bóng tiếp xúc.
- `doors[]`: id, x, đích (room_id + spawn), `travel` khi đổi location.
- `interactions[]`: target ID kỹ thuật + action ID (giữ cầu nối controller hiện có).
- `atmosphere_ref`, `lighting_ref` → preset theo buổi.

Toạ độ là **world units độc lập độ phân giải ảnh**: art manifest khai báo kích thước
nguồn và tỉ lệ px/unit, nên thay ảnh khác độ phân giải không đổi layout.

### 7.3 Art manifest và placeholder

`content/world2d/art_manifest_v1.json`: `art_ref` → file, kích thước, px/unit, pivot,
`status` (`placeholder_ai` | `final`), provenance (tool, prompt, ngày, hash nguồn, chỉnh
sửa). `tools/check_content.py` mở rộng: mọi file được tham chiếu có hash khớp; build
release liệt kê các `placeholder_ai` còn lại (không chặn dev build, phải hiện rõ).

Công cụ tạo ảnh (người dùng chọn 2026-10-28): Claude điều khiển **Codex CLI**
(`codex exec`, tính năng `image_generation`, 0.162.1 trên máy dev), đính concept làm
tham chiếu bằng `-i`. Prompt do Claude viết, lưu trong
`assets/world2d/<room>/source/prompts.json`; ảnh gốc ở `source/`, bản runtime đã
crop/scale là recipe có hash. Provenance ghi phiên bản Codex, model, prompt, ảnh tham
chiếu, ngày, hash. Codex chỉ được tạo ảnh vào thư mục chỉ định, không sửa code/content.

Quy trình placeholder: tạo **từng lớp riêng** (bầu trời/biển, tường sau, đồ mid, foreground)
thay vì cắt một ảnh concept; chữ đọc được (biển phòng, bảng tin) là label runtime từ catalog.
Concept hai-vong là tham chiếu mood/bố cục, không đưa vào build.

### 7.4 Render, ánh sáng, không khí

**Cập nhật 2026-10-28 (người dùng):** Hồi Âm là game casual, phải chạy trên máy không có
card rời; hiệu năng tối ưu sau, không đo tiếp ở đợt này. Cấu hình mặc định theo thiết kế
(không phải số đo): **tắt HDR 2D và glow**, ánh sáng vẽ sẵn vào plate, tối đa 2 light
runtime, vệt nắng là sprite additive, plate cỡ ~1920×1080 import lossless, renderer giữ
Forward+ chờ kiểm tra iGPU. Evidence RTX tham khảo: `docs/world-side/evidence/e1-stress-v1/`.
Các dòng dưới về HDR/glow chỉ là tùy chọn chất lượng cao, mặc định tắt.

- Forward+, `use_hdr_2d` bật, `WorldEnvironment` nền Canvas có glow; UI coastal ở
  `CanvasLayer` trên Canvas Max Layer nên không bị glow/grade.
- Ánh sáng chính **vẽ sẵn trong art**; runtime thêm tối đa vài light có động cơ (cửa sổ,
  đèn bàn), một vệt nắng additive, `CanvasModulate`/grade theo buổi, dither chống banding.
- Normal map chỉ khi cần cho nhân vật/đồ chính, sau bài prototype (mục 9).
- Preset `content/world2d/lighting/<room>.json`: mỗi buổi có grade, màu/năng lượng light,
  màu bóng, mật độ bụi, tint nước. Chuyển buổi = nội suy preset.
- Buổi hiển thị lấy từ phase domain qua bảng ánh xạ trong content (world chỉ đọc snapshot):
  `morning`→Sáng, `investigation`/`personal`→Chiều, `evening`→Tối, `bed`→Đêm,
  `weekend1`→Sáng, `weekend2`→Chiều. Preview cho chọn buổi tay để review.
- UI coastal giữ nguyên, nằm ngoài glow/grade (xem 7.4 dòng đầu).
- Không khí: bụi `GPUParticles2D` seed cố định trong vùng nắng, shader nước cho biển qua
  cửa sổ, đung đưa nhẹ cho rèm/cây. Reduced-motion: tắt bụi/đung đưa/camera lag, giữ ánh sáng tĩnh.
- DOF: lớp xa pre-blur từ pipeline; tối đa một pass blur runtime.

### 7.5 Actor và camera

- Khuê (player) và NPC placeholder: sprite AI high-res tĩnh theo hướng trái/phải, chuyển
  động placeholder bằng bob/squash theo quãng đường đi (không giả là animation cuối).
  Kỹ thuật animation cuối (Skeleton2D/Spine/frame) quyết định sau beauty corner.
- Di chuyển: gia tốc/ma sát, tốc độ, kích thước người trong content; actor sort theo
  baseline cùng props `sort_y`, foreground che đúng alpha.
- Camera: follow có dead zone, clamp theo bounds sau zoom, snap khi vào phòng.

### 7.6 Save

`world.position` hiện là mảng 3 số của HD-2D. Đề xuất **world envelope v2**:
`{version: 2, location_id, room_id, x, facing}` cho phòng 2D; phòng HD-2D còn lại vẫn
ghi `position` 3 số như cũ (v2 cho phép đúng một trong hai, validator kiểm theo loại
phòng) để không mất vị trí ở các location chưa chuyển. Migration v1→v2: location đã có
phòng 2D → phòng 2D mặc định + spawn mặc định (không đổi toạ độ 3D, ghi vào behavior
ledger); location chưa có → giữ nguyên `position`. Validator, fixture save v1 thật,
fixture hỏng, giữ đường legacy tile.

### 7.7 Docs và archive

- Nhập vào `docs/design/`: Story Bible v2, GDD-Defense, GDD-Attack, RULES (lịch sử), các
  tài liệu narrative (prologue vision, environmental storytelling, script opening scenes,
  editorial review), First3Days gốc + bảng ánh xạ, 11 concept PNG. Nguồn: nhánh
  `feat/first3-art-direction` commit `3aacdbc`; ghi commit + SHA-256 từng file, giữ byte.
- `docs/decisions/005-side-scroll-2d.md`: chuyển hướng, lý do, thay thế quyết định HD-2D.
- Viết mới `docs/ART-DIRECTION.md` cho high-res cinematic; cập nhật `AGENTS.md`,
  `ARCHITECTURE.md`, `DEVELOPMENT.md`, `src/world/README.md` cho hướng mới.
- HD-2D: evidence và content giữ nguyên chỗ, đánh dấu archived trong status; code HD-2D
  chỉ gỡ khỏi đường chạy chính khi mọi location có phòng 2D (không trong đợt này).

## 8. Thứ tự làm và điều kiện qua mốc

| Mốc | Nội dung | Qua mốc khi |
| --- | --- | --- |
| E0 Nền tảng docs | Branch mới, nhập docs, decision 005, cập nhật AGENTS/ARCHITECTURE | Checks architecture/reference/content pass; hash docs nguồn ghi đủ |
| E1 Prototype rủi ro (đã dừng 2026-10-28: chỉ có số RTX tham khảo, iGPU hoãn) | Phòng thử worst-case: HDR 2D + glow + 5 lớp + 3 light + 1 blur + bụi | Native trên máy dev (RTX 3050 Ti laptop, như HD08): p95 ≤16,7 ms ở 1080p, VRAM world ≤1 GB; 1440p chỉ đo để ghi. Chọn độ phân giải plate/nén theo kết quả |
| E2 World2D core + greybox | Schema/validator, room loader, actor/camera, cửa, interaction, save v2, 7 phòng hộp xám | `verify.py` + `verify_native.py` pass; đi hết 7 phòng, cửa/travel đúng, save/load v1→v2 |
| E3 Beauty corner Phòng số 3 | Placeholder AI đủ lớp, lighting 4 buổi, không khí, foreground | Người dùng xem bản chơi native; ảnh greyscale/gameplay size; bảng giờ làm từng asset |
| E4 Phủ placeholder 6 phòng | Theo kit/quy trình chốt ở E3 | Evidence High/Low mỗi phòng, provenance đủ, hiệu năng native từng phòng |

Mỗi mốc dừng để người dùng review trước khi sang mốc tiếp.

## 9. Để lại cho người lập plan

Chi tiết schema JSON, tên node/script, cách chia file ≤200 dòng, tham số tuning mặc định,
cách nối `playable_rooms.gd` với loader 2D, kịch bản test, tên/thư mục evidence (version
mới, không ghi đè).

## 10. Rủi ro cần prototype trước (E1)

HDR 2D + glow trong chế độ Canvas trên Forward+/D3D12; giới hạn ~16 light mỗi canvas item
(chưa xác minh); normal map tối dưới `CanvasModulate` ban đêm; Lossless vs nén VRAM cho
plate lớn; `Parallax2D` khi camera zoom; banding gradient hoàng hôn.
