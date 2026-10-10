# Chapter 02 — Gameplay domain và session

Trạng thái: chưa bắt đầu. Phụ thuộc: Chapter 01.
Mục tiêu: domain chạy headless có parity cho vòng ngày và commands đầu tiên.

## Work packages

- [ ] C02.01: port create_session và schema gameplay vào `src/domain/gameplay/`;
  definitions được inject, không đọc file trong domain.
- [ ] C02.02: port calendar/weekend/slot progression; commands school/endClub/sleep
  và guards trước khi nối world. Giữ action-driven clock.
- [ ] C02.03: port availability/effective stats và các primitive costs/guards;
  error/event codes + catalog key/parameters, không locale formatting trong rules.
- [ ] C02.04: port validator v1/v2, numeric/reference constraints, invalid save fixtures.
- [ ] C02.05: nối GameSession thật ở composition; một session chỉ một ruleset.
- [ ] C02.06: test successful/rejected commands, input immutability, no duplicate
  nightly processing và exact intermediate parity theo oracle.

## Đầu ra

Các file domain nhỏ theo calendar/people/actions/session/state_validation; content
schemas và tests. Không chuyển nguyên engine.js thành một GDScript khổng lồ.
Commands nghiệp vụ/personal chưa port được reject rõ ràng, không fake success.

## Exit gate

Traces đã chọn khớp, corrupted states không replace session, callers không mutate
owned state. Không Node/I/O/input/time dependencies. Headless session không cần
world hoặc UI. Full-policy parity còn chờ Chapters 07/08.

## Handoff

Nghiệp vụ sâu tiếp tục Chapter 07. First playable chỉ dùng subset commands có
implementation và evidence, không tạo energy/money số giả ở HUD live.
