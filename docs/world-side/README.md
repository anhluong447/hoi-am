# World 2D side-scroll — tiến độ

Workstream theo [ADR 005](../decisions/005-side-scroll-2d.md), thiết kế ở
[2026-10-28-side-scroll-environment-design.md]
(../superpowers/specs/2026-10-28-side-scroll-environment-design.md), kế hoạch
mốc ở `docs/superpowers/plans/2026-10-28-side-scroll-environment-e0-e2.md`.
Trạng thái từng mốc ở [status.json](status.json).

## Mốc

- **E0 Nền tảng docs**: branch mới, nhập docs thiết kế từ hai-vong
  (`docs/design/`, nguồn ghi ở `docs/design/SOURCES.json`), decision record 005,
  cập nhật AGENTS/ARCHITECTURE/DEVELOPMENT/ART-DIRECTION. HD-2D đánh dấu archived
  ở `docs/world-hd2d/status.json`.
- **E1 Prototype rủi ro**: đo render worst-case (HDR 2D + glow + nhiều lớp +
  light + blur + hạt bụi) trên máy dev thật.
- **E2 World2D core + greybox**: schema/validator phòng, room loader, actor/
  camera, cửa, interaction, save envelope v2, bảy phòng hộp xám đi lại được.
- **E3 Beauty corner**: Phòng số 3 với placeholder AI đủ lớp, lighting bốn
  buổi, không khí, foreground, đo thời gian làm từng loại asset.
- **E4 Phủ placeholder 6 phòng còn lại**: theo kit/quy trình chốt ở E3.

Mỗi mốc dừng để người dùng review trước khi sang mốc tiếp; xem điều kiện qua
mốc đầy đủ trong design doc mục 8.
