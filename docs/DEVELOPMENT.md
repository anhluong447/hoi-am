# Workflow phát triển

## Công cụ

Godot 4.7.2 Steam hiện đã được kiểm tra qua MCP; project dùng Forward+ và Jolt.
Python 3.12 chạy tooling không cần package ngoài. Node chỉ cần cho bước import
ES module ban đầu, không cần để chạy/test Godot sau đó. Export templates được
kiểm tra riêng ở Chapter 12; không coi editor đã cài là export đã sẵn sàng.

`capture_migration.py`/`export_migration.mjs` chỉ phục vụ import một lần và đọc
source. Các oracle/captured packs đã khóa hash; tool từ chối overwrite. Khi cần
thay balance/content có chủ đích, tạo phiên bản pack/evidence mới và ghi ledger.
Runtime/checks hiện tại không cần Node hay checkout nguồn.

`bake_ui_art.py` cần Chromium ở bước authoring vì SVG filters. Runtime dùng PNG
đã commit. Giữ masters/prompts/fonts/licenses; validate art hashes sau rebuild.

Mở project trực tiếp; F5 có playable/sandbox và ba preview; F6 chạy scene cụ thể.
MCP hỗ trợ mở/chạy scene và đọc debug, không thay thế visual/device review.

## Checks thường dùng

```powershell
python tools/check_architecture.py
python tools/check_reference.py
python tools/check_content.py
python tools/verify.py --godot 'D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe'
python tools/verify_native.py --godot 'D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe'
```

Có thể đặt `GODOT_PATH` hoặc dùng executable trên PATH. Verify chạy policy checks,
headless editor import, contract tests rồi boot smoke. Nó fail khi process lỗi
hoặc Godot ghi SCRIPT ERROR/Parse Error/ERROR dù exit code là 0. Tool đọc cả log
file vì bản Windows/Steam có thể không gửi hết lỗi ra console. Test run phải có
completion marker, không coi việc engine tự thoát là test pass.

Chỉ sửa docs: chạy architecture/reference. Sửa runtime/content: chạy full verify.
Sau port gameplay: chạy thêm parity fixtures của chapter tương ứng. Sửa world/UI:
chạy Godot thật với Forward+, kiểm tra input/focus/resize, rồi lưu evidence review.

Browser suite của hai-vong không áp dụng cho scene Godot. Source checkout giữ
nguyên; reference baselines đã copy có hash lock. Khi cần oracle mới, công cụ
đọc source phải viết output vào project này hoặc thư mục tạm, không vào hai-vong.

`verify_native.py --capture` chạy input checks rồi capture tuần tự; output thử ở
`artifacts/native-review/`. Lưu evidence lịch sử bằng `capture_review.gd --
--output res://docs/reviews/<review>/<new-version>`; tool từ chối thư mục docs
đã tồn tại. Xem [review UI hiện tại](reviews/ui-upgrade-2026-10-10/README.md).
Logs native không được dùng để suy ra FPS từ `--fixed-fps` hoặc headless cadence.

## Viết một feature

1. Đọc chapter và scope; phân biệt port parity với thay đổi game design.
2. Thêm content/key/schema và validation trước; technical IDs không đổi theo chữ.
3. Viết domain nhỏ và deterministic, test những failure/state boundaries thật.
4. Gọi qua GameSession; controller dựng model, view emit local signals.
5. Làm scene/script cùng thư mục, preview được với fixture độc lập.
6. Chạy checks vừa đủ, ghi evidence và cập nhật chapter status.

Không thêm test chỉ để phản chiếu implementation. Có thể dùng fixture giả trong
tests, nhưng không đưa fixture state hoặc số liệu placeholder vào session thật.

## Quy ước file

- snake_case cho file/folder; PascalCase cho class_name; một class/role mỗi file.
- GDScript dùng tab, typed signatures, constants trước fields, lifecycle trước API
  khi đó là scene script. Runtime file giới hạn 200 nonblank lines.
- Giữ `.gd.uid` do Godot sinh trong version control; `.godot/` là cache.
- Scene text/tooltip/title để trống; resolve qua catalog khi configure/render.
- resources tham chiếu `res://`, saves dùng `user://`; không hardcode đường dẫn máy.
- JSON UTF-8, hai spaces, không duplicate key. Content editor được quyền sửa source;
  generated outputs phải ghi rõ builder và provenance.
- `.gdignore` ở docs/tools/tests ngăn editor nhập tài liệu/fixtures thành runtime art.

## Art và content

Font hiện có Source Serif 4 nhập kèm OFL/METADATA/hash. Không overwrite reference
concept, baseline, prompt hoặc font gốc. Khi đổi font, tạo phiên bản asset mới.
Production assets phải có source/licensing; file PNG có chữ từ concept không là UI.

World và UI có gate riêng. Chụp UI ở 1672×941/DPR-equivalent, fixture/clock cố định;
chụp world ở camera/light preset ghi rõ. Tests pass không đóng visual gate.

Manifest UI đang dùng là `content/ui/art_manifest_v3.json`: 16 textures gốc,
ba lớp wash/prompt từ v2 và HUD frame v3. Giữ cả source SVG, recipe Python và
PNG từng phiên bản; `check_content.py` kiểm hash của mọi manifest lịch sử.
`bake_ui_art.py --version 2`/`--version 3` từ chối ghi đè phiên bản đã tồn tại.
Muốn thay art tiếp, thêm recipe/version mới rồi đổi manifest trong content.
Không bake chữ vào art. Font variation theo weight được tạo mới từ base font;
kiểm native render cần xác nhận cả glyph/icon sau khi configure lại view.

`tests/capture_ui_upgrade.gd -- --output res://docs/reviews/<review>/<new-version>`
chụp 22 frames của dialogue/HUD, text dài và playable. Với 4:3/ultrawide,
screenshot viewport là vùng nội dung; letterbox bên ngoài được kiểm bằng pointer
qua window transform trong native suite. File ảnh không tự chứng minh toàn bộ window.

## Export

JSON đọc bằng FileAccess phải được đưa vào PCK qua include filter của export preset
(`*.json`, cùng font license cần phân phối). Chapter 12 kiểm tra exported executable
ở thư mục sạch, không có checkout nguồn. Docs/tests/tools không cần ship.
`export_presets.cfg` có Windows Desktop. `python tools/build_windows.py --godot
<exe>` export debug/release, copy licenses và chạy self-check từ folder sạch.
Templates 4.7.2 Steam đã được kiểm tra trên máy evidence. Distribution gồm cả
folder `build/windows/release/`; binary không cần checkout/Node/Python/editor.

`tests/profile_native.gd` dùng real clock + GPU/CPU measurement, VSync off và cap
120 FPS; khác hoàn toàn `capture_playable.gd --write-movie` dùng fixed cadence.
Ghi device/window/preset và sample length. Không suy GPU/FPS từ movie encoding.

Đọc [authoring guide đã thử](CONTENT-AUTHORING.md),
[save/schema decision](decisions/003-native-saves-and-formula-v2.md),
[review 06–12](reviews/chapters-06-12/README.md) trước khi mở feature tiếp theo.

## Version control và bàn giao

Hai project tách biệt; không tạo ignore hoặc commit ở source. Hoi-am chưa có
Git repository trước lúc setup; foundation đã init repo riêng trên `main`.
Commit theo work package, push khi được yêu cầu. Ignore cache/build/artifacts;
giữ code/content/UID/docs. Reference
snapshots có `-text` attributes để Git không normalize byte làm mất hash lock.

Mỗi chapter hoặc phần feature nhỏ kết thúc bằng bản chạy được, checklist cập nhật,
evidence kiểm tra và các giới hạn còn mở. Không cần người dùng duyệt từng thao tác
routine; hỏi khi thiếu quyết định gameplay/art/platform có ảnh hưởng đáng kể.

Style tham khảo:
[Godot GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
