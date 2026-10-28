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
  Evidence: [e1-stress-v1](evidence/e1-stress-v1/README.md) — chỉ tham chiếu RTX; đo iGPU
  hoãn theo quyết định người dùng 2026-10-28, khuyến nghị đặt theo thiết kế casual.
- **E2 World2D core + greybox**: schema/validator phòng, room loader, actor/
  camera, cửa, interaction, save envelope v2, bảy phòng hộp xám đi lại được.
  **Hoàn tất kỹ thuật, chờ người dùng review**: 1129 headless/455 native checks,
  28 ảnh bốn buổi; [evidence v3](evidence/e2-greybox-v3/README.md).
- **E3 Beauty corner**: Phòng số 3 với placeholder AI đủ lớp, lighting bốn
  buổi, không khí, foreground, đo thời gian làm từng loại asset.
- **E4 Phủ placeholder 6 phòng còn lại**: theo kit/quy trình chốt ở E3.

Mỗi mốc dừng để người dùng review trước khi sang mốc tiếp; xem điều kiện qua
mốc đầy đủ trong design doc mục 8.

Review E2: F5 → **Bắt đầu chơi**, dùng A/D hoặc trái/phải để đi, E để tương tác
với cửa/target, M để travel tới trường/CLB/nhà, Esc mở sổ tay. Cổng trường nối
phòng giám thị và hành lang; hành lang nối lớp, căng tin và Phòng số 3. Art hiện
tại là greybox; E3 mới dựng beauty corner sau phản hồi.
