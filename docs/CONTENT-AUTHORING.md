# Thêm feature và content

F5 → **Bắt đầu chơi** cho vòng chơi; ba preview cũ dùng riêng để review renderer.
F5 → **Sandbox công thức** để chạy tám benchmark. Hai entry có session, validators
và saves riêng; không đưa knobs sandbox vào gameplay.

Copy pack capture đã khóa sang một phiên bản authored mới khi thay tuning có chủ
đích, rồi đổi manifest và ghi behavior ledger. Không sửa captured pack/baseline
để làm parity pass. Text mới vào `content/locales/vi.json`, definitions dùng keys
và stable IDs; controller resolve text ở view time.

Ví dụ đã chạy thật nằm ở `content/extensions/reading_room/`:

1. `room.json` dùng newsroom room kit, có spawn/camera/colliders và target
   `library-visitor`. NPC dùng sprite Vân làm stand-in được ghi rõ, không phải art
   nhân vật mới đã duyệt.
2. `dialogue.json` có node start, speaker ID và catalog text key. Interpreter chỉ
   hỗ trợ next, tối đa ba choices, optional phase guard và explicit command.
   Graph phải reachable, không cycle; muốn loop có chủ đích phải review contract.
   Choices mới đặt `id` rõ ràng, duy nhất trong node; captured graphs cũ giữ IDs
   theo vị trí để bảo toàn oracle. `portal.to` dùng location ID đã có trong
   `content/world/locations.json`; label/prompt lấy từ room đang mount.
3. `case.json` thêm key `library-ledger`, stat need và text refs. Nó dùng open /
   assign / nightly processing hiện có; không sửa domain handler.
4. F6 `src/bootstrap/gameplay/extension_preview.tscn`. Composition thêm case/graph
   vào bản copy của pack trước validation. Normal gameplay giữ ba template gốc,
   nên policy baseline không bị thay.

Extension rehearsal được kiểm tra qua `test_playable.gd` và native captures. Không
coi ví dụ case này là nội dung canon. Các location school/library/cafe/shop/job/
waterfront/home hiện có prototype room từ cùng kit; thêm geometry/art authored
theo từng room khi sản xuất, giữ location IDs và safe-spawn contract.

Room sample `content/world/newsroom_sample.json` dùng mesh boxes/desk legs/shelves,
procedural surface/water shaders và harbor layers; source cạnh scene trong
`src/world/rooms/newsroom/`. High dùng dynamic sun shadows, dust và DOF xa; Low
tắt các effect đó. Fog/glow đã A/B, chưa bật mặc định. Texture pipeline actor/UI
vẫn giữ imported masters, manifests và font licenses.

Feature mới đi theo content/schema → pure handler → GameSession → controller
model → view/local signals → tests. Không đưa outcome vào button hoặc actor.
Runtime file tối đa 200 dòng không rỗng; reference hình/source/baseline giữ bytes.

Chạy `python tools/verify.py --godot <exe>` và `tools/verify_native.py` khi sửa
runtime/world/UI. Export bằng `python tools/build_windows.py --godot <exe>`;
tool chạy cả debug/release từ thư mục tạm chỉ có binary/PCK/dependencies/licenses.
Build không cần Node/Python để người chơi chạy. Ghi visual gaps tách khỏi parity.
