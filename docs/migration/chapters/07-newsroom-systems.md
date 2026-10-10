# Chapter 07 — Hồ sơ, đồng đội và xuất bản

Trạng thái: chưa bắt đầu. Phụ thuộc: Chapters 02 và 06.
Mục tiêu: port vòng nghiệp vụ hiện có bằng các handler nhỏ với hành vi đúng source.

## Work packages

- [ ] C07.01: open/assign, availability, progress/quality và mismatch feedback.
- [ ] C07.02: reassign/cancel/short/continue; reset đúng progress, days, attempts,
  metrics và không tính thêm energy khi approve.
- [ ] C07.03: editorial queue/capacity, working days/weekend, staff absence và deadlines.
- [ ] C07.04: select/write/publication, trọng số và packaging của gameplay ruleset;
  một lần nightly processing, thứ Sáu chốt số và không phát hành lại khi chờ approve.
- [ ] C07.05: reports/log/message view models; text key/parameters, legacy text
  compatibility giữ riêng ở adapter nếu cần.
- [ ] C07.06: UI panels theo feature, không nối outcome logic vào Button/scene.
- [ ] C07.07: replay policies và routes đã port; so đủ fields với source, chờ
  personal handlers ở Chapter 08 trước khi tuyên bố toàn bộ policies pass.

## Đầu ra

Domain modules journalism/cases/editorial/publication/reports, authored balance,
controller/panels và fixtures cho deadline/reassignment/publication boundaries.

## Exit gate

Tất cả nghiệp vụ đã chọn khớp traces, duplicate sleep/approve không gây effects
lặp. Không có formula-sandbox scoring/calendar imports. Sai khác float dùng tolerance
đã ghi, không làm tròn để che lỗi. Metrics và reports phải đối chiếu, không chỉ final score.

## Handoff

Giữ mock tuning/lịch source. Rebalance hoặc thay đổi cơ chế để phù hợp story mới
là proposal riêng, không lẫn vào migration.
