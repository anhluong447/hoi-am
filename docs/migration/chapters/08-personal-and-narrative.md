# Chapter 08 — Đời sống, quest, dialogue và màn quản lý

Trạng thái: chưa bắt đầu. Phụ thuộc: Chapter 07.
Mục tiêu: port phần còn lại của vòng gameplay và các màn menu/dossier thực dụng.

## Work packages

- [ ] C08.01: activity/date/gift/tool/boost/upgrade, fatigue/recovery/bond/romance;
  guards và tuning từ content, giữ giới hạn/lịch/mốc mock.
- [ ] C08.02: quest Khuê, tư liệu cần thu thập, chấp bút, metrics và report K/T;
  không dùng nội dung đoạn thoại để suy ra technical outcome.
- [ ] C08.03: dialogue graph interpreter nhỏ cho graph đã có: node/choice/condition/
  intent ID, validator và controller; tránh tạo narrative engine tổng quát.
- [ ] C08.04: nối map/location lựa chọn personal actions với travel presentation;
  travel không tự đổi calendar nếu command contract không quy định.
- [ ] C08.05: menu/dossier/team/report scenes theo feature và native coastal composition;
  preview text dài, absent portrait, keyboard/focus/modal stack.
- [ ] C08.06: hoàn tất 4 gameplay policies, gồm run 84 ngày, routes và rejected
  action traces; xuất target results vào artifacts, không sửa reference baseline.

## Đầu ra

Gameplay handler/content packs đầy đủ cho behavior hiện có; quản lý/thoại UI có
state thật; full gameplay parity report phân biệt numeric/IDs/events/display differences.

## Exit gate

Policies/traces khớp và schema validators đầy đủ. Dialogue definitions không có
missing references/loops không chủ ý. Các thay đổi story/ending chính thức chưa
được chốt vẫn không implement chỉ vì có trong proposal bible.

## Handoff

Menu/dossier visual gaps và motion đi Chapter 11. Save/load theo schema đầy đủ
đi Chapter 09. Full parity ở đây không đồng nghĩa production balance đã được nghiệm thu.
