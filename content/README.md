# Authoring content

Content trong project mới dùng JSON. Không giữ bản JavaScript song song làm runtime
source. Khi port một pack, xuất dữ liệu một lần, kiểm tra IDs/hash rồi author trực
tiếp tại đây. Folder theo feature chỉ tạo khi pack thật được port.

| Vị trí | Trách nhiệm |
| --- | --- |
| locales/vi.json | Toàn bộ chữ, lời thoại, tên hiển thị, lỗi và accessibility |
| ui/ | Key mapping, bố cục và motion/light presets của UI |
| gameplay/ | Roster, cases, quests, balance của gameplay, sau Chapter 1/2 |
| formula_sandbox/ | Ruleset công thức riêng, sau Chapter 10 |
| dialogue/ | Graph và điều kiện/intent bằng technical IDs |
| world/ | Room metadata, spawn, interaction/schedule IDs và preset |
| manifest.json | Pack version và đường dẫn catalog/boot hiện dùng |

Không ép geometry/material nặng thành JSON: mesh, scene, shader, Theme và material
là Godot resources đặt cạnh world/view hoặc trong assets. Balance/nghiệp vụ không
nằm trong inspector của scene, trừ thông số thuần presentation/spatial.

## Text

vi.json giữ 798 key gốc và thêm `ui.common.quit`. Keys cũ vẫn ổn định để log/save
cũ resolve được. Key mới nên mô tả ý nghĩa: `dialogue.van.intro`, `hud.energy`.
Không dùng tên đã dịch để switch, lookup state hay đặt ID.

TextCatalog nhận catalog được inject, format placeholder `{name}`. Thiếu key hoặc
parameter là lỗi cấu trúc, không hiển thị raw key cho người chơi. Parameter chỉ
substitute một lần: chữ `{count}` trong giá trị của `{name}` vẫn là chữ literal.
Giá trị là plain text; khi dùng RichTextLabel cần escape hoặc whitelist markup.

Scene chứa Label/Button trống. Controller/composition resolve text vào view model;
view render model. Wordmark, bảng tin, poster và chữ trong scene cũng dùng catalog,
không bake player-facing lettering vào texture. Số/đơn vị và keybinding labels
phải có template/catalog khi hiển thị; input action IDs vẫn là technical data.

## Pack và validation

Content loader ở infrastructure chỉ đọc Dictionary JSON và báo lỗi parse.
Domain validator kiểm tra duplicate IDs, references, numeric ranges, graph edges,
case/stat/quest keys và ruleset compatibility khi mỗi pack được đưa vào.
Foundation checker mới kiểm tra JSON duplicate keys, *_key và *_path; chưa tuyên
bố có gameplay content validator trước Chapter 1/2.

Trong export, include các file JSON cần đọc qua FileAccess. Không import review
fixture vào live pack hoặc tự cập nhật baseline khi tuning thay đổi.
