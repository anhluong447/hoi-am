# Side-scroll environment E0–E2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nhập docs thiết kế mới, đo rủi ro render 2D cinematic, và dựng tầng world 2D side-scroll với 7 phòng greybox đi được, nối vào game, save tương thích.

**Architecture:** Phòng 2D là scene `src/world/side/side_room.tscn` hiện thực cùng hợp đồng mà `playable` đang dùng với phòng 3D (signals + methods), nên composition chỉ rẽ nhánh theo `config.kind`. Layout/art/lighting là JSON trong `content/world2d/`, validate bằng validator thuần trong `src/shared/`. Spec ghi `src/world2d/`; plan đặt ở `src/world/side/` để nằm trong layer `world` sẵn có của `check_architecture.py` (không cần thêm layer). World envelope v2 lưu `x/facing` cho phòng 2D; phòng HD-2D giữ envelope v1.

**Tech Stack:** Godot 4.7.2 GDScript, Forward+ D3D12, `Parallax2D`, `Camera2D`, `CanvasModulate`, `PointLight2D`, `GPUParticles2D`; Python 3 checks trong `tools/`.

**Spec:** `docs/superpowers/specs/2026-10-28-side-scroll-environment-design.md` (E0, E1, E2). E3/E4 có plan riêng sau review E2.

## Global Constraints

- Không sửa `../hai-vong/`. Nguồn docs: `https://github.com/anhluong447/hai-vong` nhánh `feat/first3-art-direction` commit `3aacdbc`, giữ nguyên byte, ghi SHA-256.
- Text người chơi chỉ trong `content/locales/vi.json`, đọc qua `TextCatalog`; không chữ đọc được trong ảnh.
- Layout/tuning/lighting ở `content/`; toạ độ phòng là **ref px** (chiều cao phòng chuẩn 1080 ref px), độc lập độ phân giải ảnh.
- Mỗi file runtime ≤200 dòng nonblank; scene cạnh script; snake_case.
- `world` chỉ phụ thuộc `world`, `shared`; không đọc session/lịch/energy/save.
- Không đổi domain gameplay, `GameSession`, formula sandbox, UI coastal/dialogue đã duyệt.
- Không ghi đè evidence cũ; evidence mới vào thư mục có version mới dưới `docs/world-side/evidence/`.
- Godot: `D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe` (gọi là `$GODOT` bên dưới).
- Gate mỗi task: `python tools/check_architecture.py`, `python tools/check_reference.py`, `python tools/check_content.py`, `python tools/verify.py --godot $GODOT`; task đụng world/UI thêm `python tools/verify_native.py --godot $GODOT`. Báo cáo đúng lệnh đã chạy.
- Hiệu năng chỉ tuyên bố từ đo native; mốc E1: p95 ≤16,7 ms ở 1080p, VRAM world ≤1 GB trên RTX 3050 Ti laptop.

## Review Focus

1. Save cũ (envelope v1 có `position` 3 số, room HD-2D) load khi location đó đã chuyển sang 2D → vào spawn mặc định, không crash, không mất tiến trình (Task 9).
2. Đi qua cửa khi đang mở dialogue/modal hoặc khi input bị khóa → không chuyển phòng (Task 5).
3. Spawn/`x` ngoài bounds hoặc NaN trong save/content → clamp vào spawn mặc định; validator từ chối NaN (Task 3, Task 9).
4. Chuyển phòng liên tục (bấm cửa hai lần trong một frame) → chỉ một lần mount, phòng cũ được free (Task 8).
5. Reduced motion bật trước khi vào phòng → bụi/sway/camera lag tắt ngay khi mount (Task 6).

---

### Task 1: E0 — Nhập docs thiết kế, decision record, cập nhật hướng dự án

**Files:**
- Create: `docs/design/SOURCES.json`, `docs/design/narrative/*.md`, `docs/design/gameplay/*.md`, `docs/design/first3/First3Days.md`, `docs/design/first3/FIRST-THREE-DAYS.md`, `docs/design/concept/{characters,locations}/*.png`
- Create: `docs/decisions/005-side-scroll-2d.md`, `docs/world-side/status.json`, `docs/world-side/README.md`
- Modify: `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/ART-DIRECTION.md`, `docs/DEVELOPMENT.md`, `src/world/README.md`, `docs/world-hd2d/status.json`, `tools/check_reference.py`
- Add (đã viết, chưa commit): `.claude/skills/making-story-side-scrollers/**`, spec và plan này

**Interfaces:**
- Produces: `docs/design/SOURCES.json` = `{"repository": str, "branch": "feat/first3-art-direction", "commit": "3aacdbc…(full sha)", "files": [{"source": str, "target": str, "sha256": str, "bytes": int}]}`

- [ ] **Step 1:** Tạo branch `feature/side-scroll-world` từ `feature/hd2d-world`.
- [ ] **Step 2: Viết check trước.** Thêm vào `tools/check_reference.py` hàm `validate_design_sources()` đọc `docs/design/SOURCES.json`, assert mỗi `target` tồn tại, SHA-256 và số byte khớp, `commit` là 40 hex. Gọi từ `main()`.
- [ ] **Step 3:** Chạy `python tools/check_reference.py` → FAIL "docs/design/SOURCES.json" missing.
- [ ] **Step 4:** Clone nguồn vào scratchpad (`git clone --branch feat/first3-art-direction`), checkout `3aacdbc`, copy: `docs/design/narrative/*.md`, `docs/design/gameplay/{GDD-Defense,GDD-Attack,RULES}.md`, `docs/history/narrative/First3Days.md` → `docs/design/first3/`, `docs/guides/FIRST-THREE-DAYS.md` → `docs/design/first3/`, 11 PNG concept → `docs/design/concept/`. Sinh `SOURCES.json` bằng Python (sha256 + bytes). Không sửa nội dung.
- [ ] **Step 5:** Chạy `python tools/check_reference.py` → PASS.
- [ ] **Step 6: Docs hướng mới.**
  - `005-side-scroll-2d.md`: bối cảnh, quyết định người dùng 2026-10-28 (Godot 2D side-scroll, high-res cinematic không pixel, docs hai-vong là bản mới nhất, debate ngày 3 là climax làm sau, placeholder AI qua Codex), thay thế quyết định HD-2D (`docs/decisions/004-hd2d-world.md`), hệ quả.
  - `AGENTS.md`: thay câu "independent Godot migration target" bằng hướng mới; thêm: world mới ở `src/world/side/` + `content/world2d/`; docs thiết kế chuẩn ở `docs/design/` (giữ byte); HD-2D archived (không xóa, không là hướng mới); skill `making-story-side-scrollers` dùng khi lên plan cảnh/slice. Giữ nguyên quy tắc text/content/kiến trúc/check và mục dialogue UI 2026-10-11.
  - `ART-DIRECTION.md`: viết lại cho high-res painted cinematic theo skill (colour script theo buổi, light vẽ sẵn + runtime ít, readability greyscale, kit, placeholder AI có provenance). Giữ nguyên phần UI coastal.
  - `ARCHITECTURE.md`/`DEVELOPMENT.md`/`src/world/README.md`: thêm `src/world/side/`, `content/world2d/`, lệnh native mới (Task 10).
  - `docs/world-hd2d/status.json`: thêm `"archived": "2026-10-28 superseded by docs/decisions/005-side-scroll-2d.md"`.
  - `docs/world-side/status.json`: `{"E0":"complete","E1":"pending","E2":"pending","E3":"pending","E4":"pending"}` (cập nhật ở các task sau).
- [ ] **Step 7:** Chạy gate (không cần native). Expected: tất cả PASS.
- [ ] **Step 8: Commit** `docs: adopt side-scroll direction and import latest design sources`.

### Task 2: E1 — Prototype rủi ro render và đo native

**Files:**
- Create: `src/bootstrap/previews/side_stress_preview.tscn`, `src/bootstrap/previews/side_stress_preview.gd`, `content/world2d/stress/stress_v1.json`, `tests/profile_side_stress.gd`, `tools/profile_side_stress.py`
- Create evidence: `docs/world-side/evidence/e1-stress-v1/{report.json,README.md,*.png}`

**Interfaces:**
- Consumes: không (preview độc lập, không session).
- Produces: `report.json` = `{"machine": {...}, "runs": [{"variant": str, "resolution": [w,h], "hdr_2d": bool, "frames": int, "p50_ms": float, "p95_ms": float, "p99_ms": float, "vram_mib": float}], "recommendation": {"hdr_2d": bool, "plate_import": "lossless"|"vram_bptc", "max_runtime_lights": int}}`

- [ ] **Step 1:** `stress_v1.json` khai báo worst-case: 5 lớp plate 3840×2160 (ảnh nhiễu procedural sinh lúc chạy, không commit ảnh), 3 `PointLight2D`, 1 sun shaft additive, 1 pass blur `CanvasGroup` cho lớp xa, `GPUParticles2D` 120 hạt, `WorldEnvironment` Canvas + glow, actor 2 sprite có normal map phẳng.
- [ ] **Step 2:** `side_stress_preview.gd`: `func configure(spec: Dictionary, variant: Dictionary) -> void` dựng cảnh từ spec; variant bật/tắt `hdr_2d` (`get_viewport().use_hdr_2d`), glow, normal map, `CanvasModulate` tối (kiểm hiện tượng normal map tối ban đêm), camera pan qua lại liên tục 4 s/chu kỳ.
- [ ] **Step 3:** `tests/profile_side_stress.gd` (native, không headless): với mỗi variant × độ phân giải (1920×1080, 2560×1440): warm-up 10 s, đo 30 s bằng thời gian thực giữa frame (`Time.get_ticks_usec`), VRAM qua `Performance.RENDER_VIDEO_MEM_USED`, chụp 1 PNG; ghi `report.json`. VSync tắt, cap 120 FPS như HD08.
- [ ] **Step 4:** `tools/profile_side_stress.py --godot $GODOT` chạy 3 lần, gộp vào report, in bảng.
- [ ] **Step 5:** Chạy; đọc kết quả. Điền `recommendation` dựa trên đo: `hdr_2d` = true chỉ khi p95 ≤16,7 ms ở 1080p với HDR; `plate_import` = so sánh ảnh chụp + VRAM; ghi rõ light cap quan sát được và hiện tượng normal map tối.
- [ ] **Step 6:** README evidence: máy, driver, renderer, lệnh, bảng kết quả, giới hạn đo (không phải mọi phòng).
- [ ] **Step 7:** Gate (verify.py; preview không vào native suite). Cập nhật `docs/world-side/status.json` E1 = `complete` kèm đường dẫn report.
- [ ] **Step 8: Commit** `perf: measure side-scroll render stress on native hardware`.
- [ ] **Step 9: DỪNG — người dùng review report E1** trước Task 6 (Task 3–5 có thể tiếp vì không phụ thuộc kết quả).

### Task 3: Schema phòng 2D, art manifest, validator thuần

**Files:**
- Create: `src/shared/side_room_validation.gd`, `tools/check_side_rooms.py`, `tests/test_side_room.gd`
- Modify: `tools/check_content.py` (gọi `check_side_rooms.validate()`), `tests/run_tests.gd` (thêm suite)

**Interfaces:**
- Produces (GDScript, static): 
  - `validate_manifest(manifest: Dictionary) -> Dictionary` → `{"ok": bool, "errors": Array[String]}`
  - `validate_room(room: Dictionary, manifest: Dictionary) -> Dictionary` → như trên
  - `validate_lighting(preset: Dictionary) -> Dictionary` → như trên
- Room JSON (`content/world2d/rooms/<id>.json`):
  `{"kind":"side_room_v1","id":str,"location_id":str,"title_key":str,"height":1080,"bounds":{"min_x":num,"max_x":num},"floor_y":num,"default_spawn":str,"spawns":{id:{"x":num,"facing":-1|1}},"layers":[{"id","plane":"sky|far|back|mid|foreground","scroll_scale":num,"art_ref","position":[x,y],"z":int}],"props":[{"id","art_ref","position":[x,y],"sort_y":num,"occludes_actor":bool}],"doors":[{"id","x","width","target_room","target_spawn","target_location"?:str}],"interactions":[{"id","x","width","label_key","anchor_y"}],"actors":[{"id","actor_ref","x","facing"}],"lighting_ref":str}`
- Manifest (`content/world2d/art_manifest_v1.json`): `{"schema_version":1,"assets":{ref:{"kind":"greybox","color":"#rrggbb","size":[w,h]} | {"kind":"image","path":"res://…","size":[w,h],"px_per_unit":num,"pivot":[x,y],"status":"placeholder_ai|final","sha256":str,"provenance":{"tool":str,"prompt_id":str,"date":str}}}}`
- Lighting (`content/world2d/lighting/<id>.json`): `{"schema_version":1,"phases":{"sang|chieu|toi|dem":{"modulate":"#rrggbb","sun":{"color","energy","angle"},"lights":[{"id","position":[x,y],"color","energy","radius"}],"dust":num(0..1),"water_tint":"#rrggbb"}}}`; map phase domain: `content/world2d/phase_lighting.json` = `{"morning":"sang","investigation":"chieu","personal":"chieu","evening":"toi","bed":"dem","weekend1":"sang","weekend2":"chieu"}`.

- [ ] **Step 1: Test thất bại** `tests/test_side_room.gd` (extends test_suite), fixture dict hợp lệ dựng trong test:
  - `expect(V.validate_room(valid, manifest).ok, "Valid side room accepted")`
  - không `kind`=`side_room_v1` → reject; `bounds.min_x >= max_x` → reject; spawn `x` ngoài bounds → reject; `x` = NAN → reject; `default_spawn` không có trong `spawns` → reject; `art_ref` không có trong manifest → reject; id trùng giữa layers/props/doors/interactions → reject; `plane` lạ → reject; door thiếu `target_spawn` → reject.
  - `validate_manifest`: image thiếu `sha256`/`status` → reject; `px_per_unit <= 0` → reject; greybox màu sai định dạng → reject.
  - `validate_lighting`: thiếu một trong 4 buổi → reject; `dust` ngoài 0..1 → reject.
- [ ] **Step 2:** Đăng ký suite trong `run_tests.gd`; chạy `python tools/verify.py --godot $GODOT` → FAIL (script missing).
- [ ] **Step 3:** Hiện thực ba hàm trong `side_room_validation.gd` (không I/O, không node). Kiểm text key không ở đây (check_architecture đã kiểm `_key`).
- [ ] **Step 4:** `tools/check_side_rooms.py`: duyệt mọi file trong `content/world2d/rooms/`, áp cùng luật cấu trúc + kiểm `target_room` tồn tại và `target_spawn` có trong phòng đích, ảnh `kind:image` có file và SHA-256 khớp; gọi từ `check_content.py`.
- [ ] **Step 5:** Chạy gate → PASS.
- [ ] **Step 6: Commit** `feat: add side-room content schema and validators`.

### Task 4: Actor đi ngang và camera

**Files:**
- Create: `src/world/side/side_motion.gd`, `src/world/side/side_actor.gd`, `src/world/side/side_actor.tscn`, `src/world/side/side_camera.gd`, `content/world2d/tuning.json`, `tests/test_side_motion.gd`
- Modify: `tests/run_tests.gd`

**Interfaces:**
- Produces:
  - `side_motion.gd` static `step(velocity: float, axis: float, delta: float, tuning: Dictionary) -> float`; tuning `{"max_speed":360.0,"accel_time":0.10,"decel_time":0.08}` (ref px/s, s). `clamp_x(x: float, bounds: Dictionary, half_width: float) -> float`.
  - `side_actor.gd` (Node2D): `var velocity: float`, `var facing: int`, `var travelled: float`, `func configure(texture: Texture2D, height_ref: float, tuning: Dictionary) -> void`, `func move(axis: float, delta: float, bounds: Dictionary) -> void`, `func stop() -> void`; bob placeholder: offset y = `sin(travelled / stride * TAU) * bob` với `stride`,`bob` trong tuning (`"stride":180.0,"bob":4.0`); `facing` theo dấu vận tốc, flip sprite.
  - `side_camera.gd` (Camera2D): `func configure(bounds: Dictionary, height: float, tuning: Dictionary) -> void`, `func follow(target_x: float, delta: float, reduced: bool) -> void`, `func snap(target_x: float) -> void`; zoom = viewport height / `height`; limits = bounds; dead zone `"camera_dead_zone":120.0`, response `"camera_response":0.08` tại 60 Hz quy đổi `1-(1-r)^(dt*60)`; reduced → snap.
- [ ] **Step 1: Test thất bại** `tests/test_side_motion.gd`:
  - từ 0, axis 1, sau 0,10 s (6 bước 1/60) → `velocity ≈ 360` (±1).
  - từ 360, axis 0, sau 0,08 s → `velocity == 0`; không đổi dấu khi hãm.
  - đổi hướng: từ 360, axis −1 → qua 0 rồi âm, không nhảy thẳng −360 trong một bước.
  - `clamp_x(9999, {"min_x":0,"max_x":2000}, 40) == 1960`; NaN axis coi như 0.
  - Actor: `move` tới mép → `velocity == 0` và `travelled` không tăng thêm khi đứng ép mép.
  - Camera: `follow` 120 bước với reduced=false tiến về target, không vượt limit; reduced=true → bằng target ngay (sau clamp).
- [ ] **Step 2:** Chạy verify → FAIL.
- [ ] **Step 3:** Hiện thực ba file; actor/camera đọc tuning từ tham số, không tự đọc file.
- [ ] **Step 4:** Chạy gate → PASS.
- [ ] **Step 5: Commit** `feat: add side-scroll actor motion and camera`.

### Task 5: Scene phòng 2D (lớp, props, cửa, tương tác)

**Files:**
- Create: `src/world/side/side_room.gd`, `src/world/side/side_room.tscn`, `src/world/side/side_layers.gd`, `src/world/side/side_targets.gd`, `tests/test_side_room_scene.gd`
- Modify: `tests/run_tests.gd`

**Interfaces:**
- Consumes: Task 3 schema, Task 4 `side_actor`, `side_camera`, `side_motion`.
- Produces — `side_room.gd` (Node2D), cùng hợp đồng phòng 3D:
  - signals: `interaction_requested(target_id: String)`, `portal_requested(location_id: String, spawn_id: String)`, `door_requested(room_id: String, spawn_id: String)`, `menu_requested`, `nearby_changed(target_id: String)`
  - `var player: Node2D` (side_actor), `const KIND := "side_room_v1"`
  - `configure(config: Dictionary, actors: Dictionary, textures: Dictionary) -> void` (textures: art_ref → Texture2D; greybox ref không cần texture)
  - `set_input_enabled(enabled: bool)`, `place_player(spawn_id: String, x: float = NAN, facing: int = 0)` (x NaN/ngoài bounds → spawn), `safe_spawn_x(x: float) -> float`, `target_label_key(id: String) -> String`, `accepts_saved_room(id: String) -> bool` (true khi `id == config.id`), `anchor_for(id: String) -> Dictionary` (`{"visible": bool, "position": Vector2}` toạ độ màn hình qua `get_global_transform_with_canvas()`), `set_actor_talking(id: String, talking: bool)`, `set_quality(id: String)`, `set_reduced_motion(reduced: bool)`. (`set_lighting_phase` do Task 6 thêm.)
  - `side_layers.gd`: `static func build(parent: Node2D, layers: Array, textures: Dictionary, manifest: Dictionary) -> void` tạo `Parallax2D` cho mỗi layer có `scroll_scale != 1`, `Sprite2D`/`ColorRect` greybox; props sort theo `z_index` = `sort_y` so với baseline actor (`floor_y`); prop `occludes_actor` đặt `z_index` > actor.
  - `side_targets.gd`: `static func nearest(targets: Array, x: float) -> String` (target có `|x - t.x| <= t.width/2`, gần nhất thắng; rỗng nếu không có).
- Input: action `move_left`/`move_right` có sẵn; tương tác/cửa dùng action hiện có của phòng 3D (đọc `newsroom.gd::_unhandled_input` và dùng đúng action đó); menu như phòng 3D.
- [ ] **Step 1: Test thất bại** `tests/test_side_room_scene.gd` (headless, dùng room fixture dict + manifest greybox):
  - mount → `player.position.x == spawns[default].x`; `player.position.y == floor_y`.
  - nhấn `move_right` 12 physics frame → x tăng; session không liên quan (không truyền).
  - `set_input_enabled(false)` rồi nhấn → x không đổi.
  - đứng trong vùng interaction → `nearby_changed` phát đúng id một lần; nhấn tương tác → `interaction_requested(id)`.
  - đứng trong cửa cùng location + nhấn tương tác → `door_requested(target_room, target_spawn)`; cửa có `target_location` → `portal_requested(location, spawn)`; input bị khóa → không phát (Review Focus 2).
  - `place_player("missing", NAN)` → spawn mặc định; `safe_spawn_x(1e9)` → clamp trong bounds (Review Focus 3).
  - prop `occludes_actor` có `z_index` > player; layer `scroll_scale` 0.3 là con của `Parallax2D`.
  - `anchor_for(id)` trả `visible` true khi target trong màn hình.
- [ ] **Step 2:** Chạy verify → FAIL.
- [ ] **Step 3:** Hiện thực; giữ mỗi file ≤200 dòng nonblank.
- [ ] **Step 4:** Gate → PASS.
- [ ] **Step 5: Commit** `feat: add side-scroll room scene with doors and targets`.

### Task 6: Ánh sáng theo buổi và không khí (sau review E1)

**Files:**
- Create: `src/world/side/side_lighting.gd`, `src/world/side/side_atmosphere.gd`, `src/world/side/side_water.gdshader`, `src/world/side/side_grade.gdshader`, `content/world2d/lighting/school_day.json`, `content/world2d/lighting/room3.json`, `content/world2d/lighting/home.json`, `content/world2d/phase_lighting.json`, `tests/test_side_lighting.gd`
- Modify: `src/world/side/side_room.gd` (thêm `set_lighting_phase`), `project.godot` (chỉ khi report E1 khuyến nghị `hdr_2d`), `tests/run_tests.gd`

**Interfaces:**
- Consumes: Task 2 `recommendation`; Task 3 lighting schema; Task 5 room.
- Produces: `side_room.set_lighting_phase(phase_id: String) -> void` (phase domain, tra `phase_lighting.json` được inject qua `config.phase_map`); `side_lighting.gd` (Node2D) `apply(preset: Dictionary, blend: float)`; `side_atmosphere.gd` `configure(spec: Dictionary, seed: int)`, `set_density(value: float)`, `set_reduced_motion(reduced: bool)`.
- Quy ước: `CanvasModulate` theo `modulate`; sun shaft = `Sprite2D` additive gradient, góc `sun.angle`; light runtime ≤ `recommendation.max_runtime_lights`; bụi `GPUParticles2D` seed cố định (`seed = hash(room.id)`), số hạt = `dust × 120`; nước = shader trên layer có `"water": true`; grade + dither trong `side_grade.gdshader` trên một `CanvasLayer` dưới UI. Chuyển buổi tween 1,5 s; reduced → đặt ngay.
- [ ] **Step 1: Test thất bại** `tests/test_side_lighting.gd`:
  - mỗi phase domain trong `phase_lighting.json` map ra một buổi có trong preset.
  - `set_lighting_phase("evening")` → `CanvasModulate.color` tiến về `toi.modulate` (sau tween hoặc ngay khi reduced).
  - reduced motion bật **trước** configure → particles `emitting == false`, camera snap (Review Focus 5).
  - số light runtime ≤ giới hạn; UI `CanvasLayer` layer > grade layer.
- [ ] **Step 2:** verify → FAIL. **Step 3:** hiện thực. **Step 4:** gate → PASS.
- [ ] **Step 5: Commit** `feat: add side-scroll time-of-day lighting and atmosphere`.

### Task 7: Bảy phòng greybox

**Files:**
- Create: `content/world2d/rooms/{school_gate_2d,discipline_office_2d,class_11a3_2d,corridor_c_2d,canteen_2d,room3_2d,home_room_2d}.json`, `content/world2d/art_manifest_v1.json` (chỉ `kind: greybox`), `content/world2d/tuning.json` (nếu chưa có ở Task 4)
- Modify: `content/locales/vi.json` (tên 7 phòng, nhãn cửa/biển runtime)

**Interfaces:**
- Consumes: schema Task 3. Produces: 7 room id ở trên; spawn ids dùng ở Task 8/10:
  - `school_gate_2d`: spawns `travel`, `from_office`, `from_corridor`; cửa → `discipline_office_2d/from_gate`, → `corridor_c_2d/from_gate`.
  - `discipline_office_2d`: `from_gate`; cửa → `school_gate_2d/from_office`.
  - `corridor_c_2d`: `from_gate`, `from_class`, `from_canteen`, `from_room3`; cửa → gate, `class_11a3_2d/from_corridor`, `canteen_2d/from_corridor`, `room3_2d/from_corridor` với `target_location: "club"`.
  - `class_11a3_2d`, `canteen_2d`: `from_corridor` + cửa về hành lang.
  - `room3_2d`: `travel`, `from_corridor`; cửa → `corridor_c_2d/from_room3` với `target_location: "school"`; interaction targets = các target id hiện có của phòng club 3D (đọc `content/world/newsroom_hd2d_v1.json`, giữ nguyên id, label key).
  - `home_room_2d`: `travel`; interaction targets = target của home 3D (giữ id).
  - Target của location `school` 3D đặt trong `corridor_c_2d`.
- Kích thước tham khảo: chiều cao 1080; Phòng số 3 rộng 3200 ref px, hành lang 4800, phòng khác 2400–3200; `floor_y` 900; greybox phân màu theo plane (sky sáng nhất → foreground tối nhất) để nhìn được chiều sâu.
- [ ] **Step 1:** Viết 7 file + manifest + text keys.
- [ ] **Step 2:** `python tools/check_content.py` → PASS (graph cửa hai chiều, spawn tồn tại).
- [ ] **Step 3:** Thêm vào `tests/test_side_room.gd`: mọi file trong `content/world2d/rooms/` qua `validate_room`; mọi cửa có cửa ngược về phòng nguồn.
- [ ] **Step 4:** verify → PASS. **Step 5: Commit** `content: add seven greybox side rooms for the first three days`.

### Task 8: Nối phòng 2D vào game

**Files:**
- Create: `src/bootstrap/gameplay/playable_world.gd` (tách `travel`, `world_snapshot`, `restore_world` khỏi `playable.gd`), `src/bootstrap/side_resources.gd`
- Modify: `src/bootstrap/gameplay/playable.gd`, `src/bootstrap/gameplay/playable.tscn` (`World` thành `Node`), `src/bootstrap/gameplay/playable_rooms.gd`, `content/world/locations.json`, `tests/test_playable.gd`

**Interfaces:**
- Consumes: Task 5 room contract, Task 6 `set_lighting_phase`, Task 7 room ids.
- Produces:
  - `locations.json`: entry 2D = `{"kind":"side","entry_room":"room3_2d","rooms_path":"res://content/world2d/rooms/","prototype":false,"art_acceptance":"greybox"}` cho `club` (`room3_2d`), `school` (`school_gate_2d`), `home` (`home_room_2d`); location khác giữ entry HD-2D.
  - `side_resources.gd` static `prepare(room: Dictionary, manifest: Dictionary, lighting: Dictionary, phase_map: Dictionary) -> Dictionary` → `{"ok", "config", "textures"}`; validate bằng Task 3 trước khi thay phòng.
  - `playable_world.gd`: `travel(play: Node, location_id: String, spawn_id: String = "travel") -> void`, `enter_room(play: Node, room_id: String, spawn_id: String) -> void`, `snapshot(play: Node) -> Dictionary`, `restore(play: Node, world: Dictionary) -> void`.
  - `playable_rooms.mount` rẽ theo `config.get("kind") == "side_room_v1"`; nối `door_requested` → `enter_room.call_deferred`, `portal_requested(location, spawn)` → `travel.call_deferred`; mỗi lần mount khóa input và bỏ qua yêu cầu cửa/portal tiếp theo tới khi mount xong (Review Focus 4).
  - `playable._refresh()` gọi `room.set_lighting_phase(session phase)` nếu room có method (phòng 2D).
- [ ] **Step 1: Test thất bại** trong `tests/test_playable.gd`:
  - khởi động playable → phòng là side room `room3_2d`.
  - đặt player tại cửa hành lang của `room3_2d`, bấm tương tác → phòng `corridor_c_2d`, `controller.location_id == "school"`, snapshot session không đổi (không tốn thời gian).
  - phát hai yêu cầu cửa trong cùng frame → đúng một phòng mới, phòng cũ đã free.
  - travel `library` → vẫn mount phòng HD-2D cũ (tương thích).
  - mở dialogue → input phòng bị khóa; đóng → mở lại.
- [ ] **Step 2:** verify → FAIL. **Step 3:** hiện thực; `playable.gd` ≤200 nonblank sau khi tách. **Step 4:** gate + `verify_native.py` → PASS (suite HD-2D cũ vẫn xanh cho location chưa chuyển; nếu test HD-2D cũ assert club/school/home là 3D, cập nhật đúng test đó sang location còn HD-2D, ghi lý do trong commit).
- [ ] **Step 5: Commit** `feat: mount side-scroll rooms for school, club and home`.

### Task 9: World envelope v2 và tương thích save

**Files:**
- Modify: `src/domain/gameplay/save_contract.gd`, `src/bootstrap/gameplay/playable_world.gd`, `tests/test_saves.gd`, `docs/migration/behavior-ledger.md`
- Create: `tests/fixtures/saves/world_v2_side.json`, `tests/fixtures/saves/world_v2_corrupt_x.json`, `tests/fixtures/saves/world_v2_both_fields.json` (giữ fixture v1 hiện có)

**Interfaces:**
- Produces: `save_contract.valid_world(world)` chấp nhận
  - v1 như cũ;
  - v2 `{"version":2,"location_id":str,"room_id":str,"x":finite num,"facing":-1|1}` cho phòng 2D, hoặc `{"version":2,"location_id","room_id","position":[3 finite]}` cho phòng HD-2D; có cả `x` và `position` → invalid.
- `playable_world.snapshot` ghi v2 (x/facing nếu side, position nếu 3D). `restore`: v2 side + room tồn tại → `enter_room` + `place_player(spawn mặc định, x, facing)`; v1 hoặc room HD-2D cũ khi location giờ là side → `travel(location, "travel")` (spawn mặc định).
- [ ] **Step 1: Test thất bại** `tests/test_saves.gd`:
  - fixture v1 thật hiện có (club, position 3D) decode OK; restore → `room3_2d`, player ở spawn `travel` (Review Focus 1); state gameplay giữ nguyên.
  - `world_v2_side.json` round-trip: save tại x=1234, facing −1 → load → x=1234, facing −1, cùng room.
  - `world_v2_corrupt_x.json` (x = "NaN"/chuỗi) → decode `ok == false`, code `invalid_save_envelope`.
  - `world_v2_both_fields.json` → invalid.
  - v2 x ngoài bounds của room → restore clamp về spawn mặc định.
  - legacy tile/press save vẫn đi qua `legacy_world` như cũ.
- [ ] **Step 2:** verify → FAIL. **Step 3:** hiện thực; validator thuần (domain không đọc file world). **Step 4:** ghi behavior ledger: "Save v1 tại club/school/home vào spawn mặc định phòng 2D, vị trí 3D không chuyển đổi". **Step 5:** gate → PASS.
- [ ] **Step 6: Commit** `feat: add world envelope v2 for side-scroll rooms with legacy fallback`.

### Task 10: Native walk-through, evidence greybox, đóng E2

**Files:**
- Create: `tests/native_side_rooms.gd`, `docs/world-side/evidence/e2-greybox-v1/{README.md,*.png,report.json}`
- Modify: `tools/verify_native.py`, `docs/world-side/status.json`, `docs/DEVELOPMENT.md`

**Interfaces:**
- Consumes: mọi task trước.
- [ ] **Step 1:** `tests/native_side_rooms.gd` (không headless): khởi động playable; đi bằng input thật qua đồ thị cửa: room3 → corridor → gate → office → gate → corridor → class → corridor → canteen → corridor → room3; travel home; tại mỗi phòng: chụp PNG 1920×1080 ở 4 buổi (gọi `set_lighting_phase`), assert player trong bounds, prompt HUD hiện khi đứng tại target, input khóa khi mở dialogue Vân ở room3; ghi `report.json` (phòng, checks, frame time p95 khi đi 10 s mỗi phòng).
- [ ] **Step 2:** Thêm vào `verify_native.py` với log `native-side-rooms.log` và marker hoàn tất.
- [ ] **Step 3:** Chạy `python tools/verify.py --godot $GODOT` và `python tools/verify_native.py --godot $GODOT` → PASS. Xem lại từng ảnh: greybox đọc được chiều sâu, nhân vật không bị foreground che mặt.
- [ ] **Step 4:** README evidence: lệnh, máy, số check, giới hạn (greybox, không phải art; frame time chỉ là quan sát, không thay profile E1).
- [ ] **Step 5:** `status.json`: E2 `complete` + evidence; E3 `next`.
- [ ] **Step 6: Commit** `test: native walk-through and greybox evidence for side rooms`.
- [ ] **Step 7: DỪNG — người dùng chơi bản greybox và review E2.** Sau đó viết plan E3 (beauty corner Phòng số 3, placeholder qua Codex) dựa trên report E1 và phản hồi.
