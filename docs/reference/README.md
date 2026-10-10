# Nguồn tham chiếu đã nhập

Source: project `hai-vong`, commit ghi trong [inventory](import-inventory.json).
Import đọc source, không chỉnh hoặc move file gốc. Game mới không cần checkout
hai-vong để boot; source được dùng để tạo thêm oracle fixtures trong các chapter sau.

## Tài liệu và artwork

- [Story bible proposal 0.3](hai-vong/game_story_bible.md): giữ nhãn proposal/đã chốt;
  không xem mọi đề xuất là feature đã implement hoặc canon.
- [Gameplay sandbox](hai-vong/GAMEPLAY-SANDBOX.md): hành vi mock của gameplay mới.
- [Rules sandbox công thức](hai-vong/RULES.md): ruleset riêng, không trộn với gameplay.
- [Playtest route](hai-vong/GAMEPLAY-ROUTE-PLAYTEST-2026-10-05.md): evidence lịch sử.
- [Bốn concept coastal](coastal-editorial-v1/README.md): ảnh/prompt được giữ nguyên.
- [Gameplay baseline](hai-vong/gameplay-baseline.json) và
  [formula baseline](hai-vong/sandbox-baseline.json): regression evidence có hash lock.
- [UI scope snapshot](specs/ui-scope.source.json) và
  [measured layout snapshot](specs/layouts.source.json): authoring references.

Architecture/development/roadmap của source không copy thành tài liệu hiện hành:
chúng mô tả browser/Canvas và tooling cũ. Những contract cần giữ được chuyển vào
[architecture mới](../ARCHITECTURE.md) và [roadmap migration](../migration/README.md).

## Tính nguyên vẹn

`policy: locked` trong inventory yêu cầu SHA-256 target bằng source lúc nhập.
Font Source Serif 4 nhập cả OFL/METADATA; concept, prompt, docs và baseline giữ byte.
Git attributes tắt line-ending normalization cho các snapshot/font source đã khóa.
Catalog là `policy: editable`: ES module đã xuất thành JSON và có thêm key quit;
inventory ghi source hash và target hash tại thời điểm nhập, không khóa authoring
catalog tương lai. Active concept references.json sửa roadmap link; bản gốc nằm
ở references.source.json, là snapshot không dùng làm active link contract.

`*.source.json` có thể chứa đường dẫn/ID review của source. Đó là dữ liệu lịch sử,
không phải import runtime hay tuyên bố asset/mask tương ứng đã được migrate.
Source docs dùng path code/browser URL lịch sử vẫn giữ ý nghĩa lịch sử; markdown
links của các tài liệu đã copy có các dependency cần thiết đặt cùng folder.

```powershell
python tools/check_reference.py
```

Tool kiểm tra độc lập với source checkout. Không reimport để overwrite reference;
thêm source version/inventory mới khi có lý do và giữ evidence cũ.
