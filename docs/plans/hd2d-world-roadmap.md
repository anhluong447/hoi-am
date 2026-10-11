# Kế hoạch world HD-2D cho Hồi Âm

Trạng thái: **bản đề xuất chờ người dùng duyệt**. Chưa thay runtime, asset đang dùng,
manifest, save schema hoặc các quyết định kiến trúc hiện hành.
Mốc nền: commit `5301b93`; định hướng được làm rõ ngày 2026-10-11.

## 1. Kết quả cần đạt

World có chiều sâu, movement, collision, ánh sáng và camera 3D. Nhân vật và môi
trường lấy hình ảnh chủ yếu từ art 2D: sprite, texture mặt sàn/tường, các lớp đạo
cụ có nền trong suốt và hậu cảnh nhiều khoảng cách. Chi tiết, đường viền, vật liệu
và bản sắc thị giác do art quyết định; hình học đơn giản hỗ trợ bố trí và chiếu sáng.

Tham chiếu chính: [03-hud-map.png](../reference/coastal-editorial-v1/03-hud-map.png).
Giữ chất tòa soạn ven biển: gỗ/giấy ấm, mực xanh, cây xanh, cảng xanh mát, nắng vàng.
Đây là hướng HD-2D riêng của Hồi Âm, không phải sao chép asset hay pipeline nội bộ
của Octopath Traveller. Concept định hướng composition và mood, không chứng minh
cách từng vật thể được dựng hoặc là ảnh cần khớp từng pixel.

Đề xuất art: nhân vật pixel rõ; môi trường dùng raster 2D có nét vẽ và cụm màu
được kiểm soát, giảm chi tiết nhiễu để đi cùng sprite. Một mẫu đối chứng sẽ thử
môi trường pixel cứng hơn trước khi khóa style. Không mặc định pixelate cả màn.

UI/HUD/thoại giữ bố cục và motion đã duyệt. World effects không làm mờ chữ UI.
Đi lại không đổi ngày/energy; tương tác tiếp tục đi qua controller và GameSession.
Không sửa source `hai-vong`, oracle, reference ảnh hoặc evidence lịch sử.

## 2. Hiện trạng đã kiểm tra

| Thành phần | Hiện có | Công việc mới |
| --- | --- | --- |
| World spatial | CharacterBody3D, XZ movement, collider, targets/portals, safe spawn | Giữ contract, tách visual khỏi collider/proxy |
| Phòng CLB | Playable dùng `newsroom_sample.json`, 41 geometry boxes | Thay phần nhìn bằng bộ môi trường 2D |
| World preview | Dùng `newsroom.json`, camera orthographic/perspective | Thêm preview HD-2D riêng, cùng pack được chọn với playable |
| Nhân vật | Khuê/Vân: atlas 32×48, foot pivot (16,46), walk theo khoảng cách | Giữ làm mẫu hiệu chuẩn; art vẫn là pilot |
| Cảng/atmosphere | Boxes, water shader, dust, far DOF | Thay harbor hình khối bằng texture layers; tune effects sau art |
| Tải content | Composition đọc JSON và inject actor textures | Bổ sung world art manifest và resource injection nhỏ |
| Các địa điểm | 8 location IDs; 7 địa điểm ngoài CLB là prototype | Chuyển dần sau khi phòng CLB được duyệt |
| Kiểm chứng | Architecture/content/reference, headless, native, export tools | Thêm contract visual pack, occlusion evidence và profile mới |

`docs/ART-DIRECTION.md` hiện ghi room/props chính là mesh 3D. Sau khi plan được
duyệt, cập nhật quyết định này và phần world trong ARCHITECTURE/CONTENT-AUTHORING.
Chapters 00–12 giữ nguyên ý nghĩa lịch sử: migration kỹ thuật đã kiểm chứng;
chưa đồng nghĩa bộ art mới hoặc world HD-2D đã hoàn thành.

## 3. Cách dựng từng nhóm hình ảnh

| Nhóm | Cách dựng đề xuất | Quy tắc |
| --- | --- | --- |
| Nhân vật | AnimatedSprite3D, foot pivot, atlas directional | Không đổi atlas chỉ để chữa sai camera/scale |
| Sàn/tường | Mặt phẳng hoặc khối rất đơn giản phủ texture 2D | UV/mật độ texel được hiệu chuẩn; nhận ánh sáng/bóng |
| Bàn | Các mặt texture riêng cho mặt bàn, mặt trước/chân, đồ trên bàn | Đặt ở độ sâu thật; không ép cả bàn thành một billboard |
| Tủ/kệ/máy in | Một hoặc vài mặt art 2D cố định theo camera; collider độc lập | Tách lớp khi cần actor đi trước/sau hoặc bóng khác nhau |
| Cây/sách/báo/trang trí | Sprite3D hoặc textured cards | Pivot/footprint rõ; depth test đúng; hạn chế alpha blend chồng lớp |
| Cửa sổ | Khung có art, lỗ mở thật hoặc các mặt không bịt đường nắng | Không bake cả view qua cửa sổ vào wall texture |
| Cảng/đồi/trời | 3–5 lớp art ở khoảng cách khác nhau | Perspective có thể tạo parallax theo depth; orthographic cần authored layer offsets nếu muốn parallax |
| Bóng | Bóng mặt phẳng/cutout hoặc proxy chỉ đổ bóng theo từng prop | Collider không tự là hình bóng đúng |
| Biển/bụi/lá | Texture animation hoặc shader/particles nhỏ có budget | Bổ sung sau khi composition tĩnh đã đọc rõ |
| Biển tên/bảng/báo có chữ | Nền art không chữ; copy từ catalog trên surface riêng | Không bake player-facing strings vào ảnh |

Camera mặc định đề xuất: góc nhìn cố định trong từng phòng, cho phép follow nhẹ
trong giới hạn đã author, chưa có orbit tự do. Thử orthographic trước; đối chứng
perspective FOV nhỏ để chọn cảm giác chiều sâu. Góc nhìn gần chính diện cửa sổ,
nhìn xuống vừa đủ thấy sàn, tránh mặc định góc chéo 45° của mô hình thu nhỏ.
Camera phải khóa trước khi sản xuất props phụ thuộc góc nhìn.

## 4. Kiến trúc và dữ liệu đề xuất

```text
assets/world/coastal/v1/
  source/                       masters, layers, prompts/recipes, provenance
  runtime/                      textures và atlas đã chọn
content/world/
  art_manifest_v1.json          asset IDs, res:// paths, hashes, import profiles
  visuals/newsroom_v1.json      placements, groups, pivots, visual/shadow policies
  newsroom_hd2d_v1.json         spatial pack CLB mới; camera, targets, proxies
src/world/props/
  sprite_prop.tscn + .gd        prop nhiều lớp với visual và anchor riêng
src/world/rooms/newsroom/
  room_visuals.gd               dựng visual groups của phòng từ dữ liệu được inject
  room_geometry.gd              legacy boxes và collider của pack mới
  room_atmosphere.gd            light/harbor/ambient ownership của room
src/bootstrap/previews/
  hd2d_preview.tscn + .gd        preview phòng mẫu và các case đứng/đi/che khuất
src/bootstrap/
  world_resources.gd            composition load/cache tài nguyên cho room mount
```

Đây là các vai trò dự kiến, chỉ tạo file khi chapter có feature thực tế. Có thể
đổi tên/chia file để giữ mỗi runtime file không quá 200 nonblank lines; không tạo
engine/framework, registry toàn cục hoặc autoload. Scene và script đặt cạnh nhau.

Visual definition tối thiểu: stable ID, asset ID/layers, transform, pivot,
footprint, material profile, shadow policy và optional animation tuning.
Spatial definition giữ collider, target/anchor, spawn/portal và camera riêng.
Một asset dùng lại được ở nhiều placement; tên dịch không quyết định asset/target ID.

Composition dùng loader hiện có để đọc và validate, rồi inject definitions và
Texture2D/resources vào world. World không đọc session, save hay outcome domain.
Không load từng texture mỗi frame. JSON/content sở hữu tuning; scenes sở hữu node
và lifecycle; tools kiểm nguồn/import/hash. Thêm text preview qua catalog.

Pack cũ và captures cũ tiếp tục chạy. Khi pack mới đủ gate, đổi mapping của
`locations.club` và entry preview; giữ location ID `club` và mapping room ID cũ
nếu đổi tên pack. Save cũ cần kiểm safe spawn sau remount. Mục tiêu không đổi save
schema; nếu phát sinh nhu cầu thay trường, có validator/migration review riêng.

Prompt visibility hiện raycast theo collider. Khi visual/collider tách nhau,
review lại query mask và authored visibility proxies để bàn/cây không chặn prompt
sai. Depth rendering, collision, shadow và prompt occlusion là bốn chính sách riêng.

## 5. Chapter HD00 — Chốt quy ước và lập inventory

Đầu vào: concept, các room packs, camera/sprite pilot và plan đã được duyệt.

- Ghi ADR world mới; sửa mô tả art direction, không sửa ledger lịch sử.
- Lập inventory phần tái sử dụng, thay mới, nguồn art và lỗ hổng của bộ hiện có.
- Chia concept thành foreground, playable midground, room shell và harbor background.
- Lập asset list kèm role, kích thước dự kiến, layer split và mức ưu tiên.
- Khởi tạo checklist HD00–HD09 riêng; migration status cũ chỉ thêm link workstream mới.

Đầu ra: ADR, asset inventory, room layout annotated, checklist và review folder mới.
Gate: mọi vật thể nhìn thấy có cách dựng dự kiến; phạm vi UI/gameplay/world rõ.

## 6. Chapter HD01 — Hiệu chuẩn camera, scale và pixel

- Tạo preview độc lập, chưa thay playable mặc định.
- Dùng sàn, cửa sổ, một bàn test và Khuê/Vân để so camera A/B.
- Thử pitch khoảng 30–40° và yaw nhỏ; con số chỉ là dải thử, không chốt production.
- Đo actor projected height, pixel density ở 1280×720 và 1920×1080. Đối chiếu tỷ lệ
  nhân vật/lối đi/cửa sổ từ concept; giữ frame/pivot gốc để phân biệt lỗi camera/art.
- Test đứng/đi ngang/dọc/chéo; kiểm foot sliding, shimmer và mép sprite lúc follow.
- Thử nearest cho actor và các texture profiles riêng cho môi trường; kiểm mipmaps
  ở surface nhìn xiên/xa thay vì tắt mipmaps toàn project.
- Khóa giới hạn camera; resize và 4:3/ultrawide vẫn dùng chính sách fit đã có.

Đầu ra: bảng camera/scale, preset content, ảnh A/B và clip movement ngắn.
Gate: actor rõ, bàn đúng tỷ lệ, chuyển động ổn; camera không làm scene giống
mô hình đồ chơi và không crop vùng tương tác quan trọng.

## 7. Chapter HD02 — Dựng prop 2D trong không gian 3D

- Xây một `sprite_prop` cụ thể; bàn có mặt trên/mặt trước, cây có cutout, tủ có
  2–3 visual layers. Chỉ hỗ trợ các kiểu đã dùng trong cảnh mẫu.
- Tách visual khỏi collision và shadow-only proxy; giữ chân prop ở mặt sàn.
- Validate asset IDs, finite transforms, positive scale, pivot/layer references.
- Test alpha discard/scissor cho silhouette cứng; chỉ dùng alpha blend khi cần
  xuyên sáng mềm. Không chữa sorting bằng cách tắt depth test toàn scene.
- Actor đi trước/sau bàn, qua khoảng trống chân bàn, sau cây và sát mép cửa sổ.
- Kiểm anchor/prompt occlusion, collision footprint và safe spawn.

Đầu ra: prop scenes, minimal schema/validation, scene che khuất và captures.
Gate: không xuyên vật, không đảo thứ tự lớp hoặc thấy hình chữ nhật quanh sprite;
bóng không tự chuyển hướng theo billboard. Pack legacy vẫn chạy.

## 8. Chapter HD03 — Bộ art mẫu và mốc duyệt phong cách

Làm một góc phòng có thể chơi: sàn/tường/cửa sổ, một bàn, tủ nhỏ, cây, giấy/sách,
Khuê/Vân và harbor 3 lớp. Khoảng 8–12 nhóm art, số texture phụ thuộc layer split.

- Tạo art độc lập từ reference style; lưu masters/source, prompts/recipes,
  licensing/provenance, palette, pivot và import settings.
- So hai hướng trong cùng camera/light: môi trường pixel cứng và môi trường nét vẽ
  có cụm màu. Đề xuất chọn hướng thứ hai nếu hòa hợp sprite và concept hơn.
- Texture chỉ bake chi tiết/local shading vừa đủ; hướng nắng chính nằm ở lighting
  để tránh một vật có hai bóng trái hướng hoặc vùng sáng không theo room.
- Normal maps chỉ thử trên sàn/tường/mặt bàn khi đem lại kết quả rõ; chưa áp dụng
  cho mọi sprite. Không dùng DOF để che art chưa đạt.
- Capture bản tắt effects và bản light cơ bản; quay vòng đi trước/sau bàn.

Đầu ra: corner slice, asset manifest v1, contact sheet, video và style notes.
**Mốc duyệt hình ảnh thứ nhất:** người dùng chọn/chỉnh phong cách và camera.
Không sản xuất toàn bộ môi trường trước mốc này. Có thể tiếp tục validation/tooling
không phụ thuộc style trong lúc chờ; không coi thời gian chờ là đồng ý.

## 9. Chapter HD04 — Hoàn thiện phòng CLB bằng bộ art đã duyệt

- Dựng room shell, cửa/khung cửa sổ, các bàn theo khu vực, ghế/tủ/kệ, máy in,
  bảng, đèn, cây và paper stacks. Tái sử dụng assets nhưng có biến thể đủ tự nhiên.
- Tách đồ tiền cảnh, main room và harbor; lối đi giữa phòng phải đọc được.
- Harbor mở rộng 3–5 lớp trời/đồi/thành phố/biển/thuyền theo composition đã khóa.
- Chỉ Khuê/Vân là actors gameplay đang có; NPC trang trí thêm phải được ghi rõ,
  không tự tạo lịch, dialogue, quest hoặc actor canon mới từ ảnh concept.
- Bảng/biển/báo readable dùng live text keys; texture artwork không chứa copy.
- Actor pilot được giữ nếu đạt style. Nếu cần art nhân vật mới, làm pack version
  riêng có duyệt silhouette/palette và kiểm đủ hướng/idle/walk/talk trước khi chọn.

Đầu ra: `newsroom_hd2d_v1`, toàn bộ selected art/source manifest và video exploration.
Gate: phòng có chất tòa soạn ven biển, art nhất quán, điểm tương tác nhìn được;
player luôn có tuyến đi tới các target cần thiết. Không còn blockout lộ ở pack mới.

## 10. Chapter HD05 — Tích hợp playable, interaction và save

- Khi room art đạt gate, chuyển location `club` sang pack mới; preview chọn cùng pack.
- Giữ stable target IDs, graph/commands, portal destinations và controller bridge.
- Nếu cần đổi vị trí bàn/NPC, đổi anchors/radii/proxies đồng bộ; không đổi command.
- Prompt hiển thị đúng khi trước/sau vật và biến mất khi anchor bị che hoặc ngoài view.
- Dialogue giữ world input lock trong reveal/modal/exit; không đổi animation đã duyệt.
- Load saves cũ/currents: đúng location, vị trí hợp lệ hoặc safe fallback; không kẹt
  trong props. Kiểm chuyển phòng rồi quay lại, input/focus và resize.

Đầu ra: playable CLB mới, native integration evidence, save/travel regression results.
Gate: đầy đủ loop thao tác hiện có; gameplay/formula oracle không đổi. Thay layout
spatial được ghi chủ đích, không regenerate baseline gameplay để làm pass.

## 11. Chapter HD06 — Nắng, bóng và chiều sâu

- Khóa nắng qua cửa sổ và ambient xanh mát; thử light A/B trên art thật.
- Chọn shadow mode từng nhóm: actor/contact proxy, table/room geometry proxy,
  cutout foliage nếu đạt silhouette và cost. Không dùng chung capsule cho mọi prop.
- Hiệu chuẩn exposure/grade: giấy/gỗ không cháy, sprite không mất viền/màu.
- Thử DOF xa/tiền cảnh theo khoảng cách camera thực; main playable region rõ.
- Thử dust/glow/fog riêng từng effect rồi quyết định bật/tắt bằng evidence.
- High/Low khác cost/effects, không biến Low thành phòng thiếu assets/props quan trọng.

Đầu ra: light/quality presets, A/B và captures actor ở vùng sáng/tối.
Gate: mood gần concept, bóng không lộ card/proxy, UI rõ; effects không che chi tiết
hoặc việc tương tác. Các chính sách bóng/camera từ HD02 được kiểm lại.

## 12. Chapter HD07 — Ambient motion và sự sống trong cảnh

- Sea shimmer/nhịp nước trên texture biển, chuyển động cây rất nhẹ, bụi vùng nắng.
- Actor idle/talk/walk hoạt động ở tất cả hướng đang có; bước theo travel distance.
- Thử camera follow mượt trong giới hạn đã khóa; không rung pixel hoặc lộ mặt sau card.
- Tuning trong content; pause/unmount ngắt tweens/particles đúng, không giữ nodes cũ.
- Reduced motion giảm/tắt dao động/camera phụ và particles trang trí theo lựa chọn,
  giữ thông tin/gameplay tương đương. Low quality và reduced motion có vai trò riêng.
- Mở/đổi/đóng thoại trong world mới; không thêm motion vào HUD/UI ngoài scope đã duyệt.

Đầu ra: clip đứng/đi/tương tác 30–60 giây, motion/quality A/B.
Gate: scene có sức sống, chữ/sprite vẫn đọc rõ; không gây cảm giác mọi props rung cùng
một nhịp hoặc chỉ dùng blur làm chiều sâu.

## 13. Chapter HD08 — Profile, nghiệm thu và bàn giao phòng mẫu

- Full architecture/reference/content/headless/native checks sau thay runtime/world.
- Profile real clock: hidden/static world, walk, effects A/B, dialogue reveal + world,
  High/Low ở 720p/1080p. Không dùng movie cadence làm benchmark.
- Đề xuất mục tiêu ban đầu: 1080p High trên RTX 3050 Ti máy hiện có, p95 frame time
  không quá 16.7 ms trong mẫu ổn định. Đây là mục tiêu cần đo, chưa là cam kết FPS.
- Warm-up 10 giây, ít nhất 30 giây samples/case, lặp 3 lần; ghi cap/VSync/device,
  driver, scene/camera, median/p95/p99, stutters, memory và draw/transparent cost.
- Chạy profiling riêng, không export/test/encode đồng thời; không dừng editor người
  dùng. Nếu baseline vẫn nhiễu, ghi đủ samples và điều tra thay vì chọn run tốt nhất.
- Tối ưu theo đo: atlas/import, số card chồng alpha, shadow coverage, effect density,
  resource lifetime. Không xây batching/LOD framework trước khi có bottleneck.
- Export Windows debug/release, kiểm packaged assets/fonts/text/save trong folder sạch.
- Lưu captures/video/logs/profile có version/hash; giữ raw source và evidence cũ.

Đầu ra: build có thể review, performance report, authoring guide và remaining issues.
**Mốc duyệt hình ảnh thứ hai:** room CLB hoàn chỉnh được người dùng chấp nhận.
Gate: functionality, visual và performance được đánh giá riêng; chưa đạt mục tiêu
thì ghi vấn đề mở, không gọi toàn bộ workstream là hoàn thành.

## 14. Chapter HD09 — Mở rộng world theo cùng pipeline

Chỉ bắt đầu sản xuất art hàng loạt sau HD08. Mỗi room có composition/asset list,
pack version, collision/anchor check và visual review; giữ location IDs hiện có.

| Đợt | Địa điểm | Mục đích |
| --- | --- | --- |
| 1 | Library, cafe | Thử kit nội thất dùng lại nhưng giữ bản sắc khác CLB |
| 2 | Home, shop, job | Mở rộng props/chức năng và điều kiện ánh sáng |
| 3 | School, waterfront | Giải camera/visibility và pixel density cho không gian rộng/ngoài trời |

Room ngoài trời có spike riêng về cây/nhà cutout, water/horizon, sunlight và follow
range; không tự kéo giãn kit CLB thành cả thành phố. Chỉ thêm module authoring thật
sự được dùng bởi ít nhất một room; scene prototypes không bị xóa trước khi có thay thế.

Nếu cần NPC hoặc narrative mới, đưa thành work package content/gameplay riêng;
world art migration không tự mở rộng canon hoặc rules. Nếu asset cũ cần archive,
lập inventory, kiểm moved bytes và sửa references trước khi chuyển.

Đầu ra: các room packs hoàn chỉnh theo từng đợt, reusable selected art, extension
rehearsal thêm một prop/room không sửa domain, final native/export review.
Gate cuối: 8 địa điểm được đánh giá riêng; nơi còn prototype phải ghi rõ, không tính
migration kỹ thuật đã pass là production art đã xong.

## 15. Thứ tự, checkpoints và cách bàn giao

```text
Plan được duyệt
  → HD00 → HD01 → HD02 → HD03 → duyệt corner slice/style
  → HD04 → HD05 → HD06 → HD07 → HD08 → duyệt phòng CLB
  → HD09: các room theo đợt
```

HD01–02 có thể dùng art test rẻ; không cần asset final để kiểm spatial mechanics.
Lighting cơ bản có từ slice; HD06 là hoàn thiện trên toàn phòng. Nếu light làm lộ
lỗi texture/pivot/camera, sửa owner tương ứng trước khi thêm effects. Mỗi chapter
kết thúc bằng bản chạy được, work log, checks và evidence cần thiết. Các commit
art/code có phạm vi review được; không gom tất cả vào một lần thay renderer.

Không dự báo ngày hoàn thành cố định khi chưa duyệt sample: thời gian lớn nhất
nằm ở art iteration và hiệu chuẩn camera/texture. Báo tiến độ theo output/gate,
phân biệt code đã chạy, art tạm và hình ảnh đã được người dùng duyệt.

## 16. Các rủi ro cần giải trong slice

| Vấn đề | Cách giải và điểm kiểm |
| --- | --- |
| Art 2D đẹp nhưng nhìn thành tấm bìa | Khóa camera, chia lớp/mặt đúng không gian, thử đi trước/sau ở HD01–03 |
| Sprite pixel và background quá mịn không hòa hợp | So style A/B và pixel density trong cùng scene trước art batch |
| Alpha sai thứ tự, viền đen, cây che actor | Profiles cutout/import riêng, depth case, xem ảnh native và clip movement |
| Texture bake nắng trùng dynamic light | Local shading trong art; hướng sáng/bóng chính do room preset sở hữu |
| Camera follow lộ khoảng trống/mặt sau | Author follow bounds, background overscan, case ở các mép phòng |
| Visual proxy lệch collision hoặc prompt | Validate footprint/anchor, native interaction và save fallback cases |
| DOF làm cả căn phòng mờ như sample hiện tại | Tính lại khoảng cách camera; A/B tắt DOF, main actor/targets phải sắc nét |
| FPS nhiễu hoặc alpha/shadow tốn GPU | Baseline/effect A/B thật, lặp samples, budget High/Low, không cam kết trước đo |

## 17. Những điểm đề xuất để người dùng duyệt

1. Phạm vi: world HD-2D mới; giữ UI và gameplay hiện có.
2. Cách dựng: art 2D nhiều lớp + hình học đơn giản hỗ trợ surfaces/proxies; camera
   cố định có follow giới hạn, chưa hỗ trợ orbit tự do.
3. Art: thử hai mức pixel trong slice, ưu tiên môi trường nét vẽ có cụm màu đi cùng
   nhân vật pixel và palette ven biển của concept.
4. Thứ tự: phòng CLB trước, duyệt góc mẫu rồi phòng hoàn chỉnh trước khi mở rộng.
5. Mục tiêu performance đề xuất: 1080p/60 FPS High trên máy hiện có, xác nhận bằng
   profile; điều chỉnh chất lượng từ số đo, không biến mục tiêu thành cam kết.

Sau khi plan được duyệt, bắt đầu HD00–HD03. Chưa sửa world runtime hoặc sản xuất
asset trong lượt lập kế hoạch này. Duyệt plan không tự đóng hai visual checkpoints.

## 18. Cơ sở kỹ thuật đã đối chiếu

- [SpriteBase3D](https://docs.godotengine.org/en/stable/classes/class_spritebase3d.html):
  texture 2D trong world 3D, pixel size/shading/depth và giới hạn billboard shadows.
- [StandardMaterial3D](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html):
  alpha cutout/blend, depth prepass và shadow behavior; dùng để thiết kế case HD02.
- [Image import](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html):
  mipmaps, memory/import và alpha border; profile riêng cho actor/cutout/surfaces.

Docs stable là cơ sở tham khảo; kiểm behavior bằng Godot 4.7.2 Steam/Forward+ đang
dùng trong project. Các quyết định art/camera/performance ở trên là đề xuất của
project, không phải thông số mặc định hoặc lời bảo đảm từ tài liệu engine.
