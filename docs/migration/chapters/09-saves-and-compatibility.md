# Chapter 09 — Save/load và compatibility

Trạng thái: chưa bắt đầu. Phụ thuộc: Chapters 07/08 và world location contract.
Mục tiêu: save native có version, validate trước replace và import nguồn cũ có kiểm soát.

## Work packages

- [ ] C09.01: khóa envelope/state/world versions riêng, ruleset/content_version/location
  IDs và optional spatial restore. Không gộp 3D coordinates vào pure gameplay schema.
- [ ] C09.02: FileAccess save adapter tại infrastructure, injected vào application use
  case bởi Main; ghi temp → commit/backup, xử lý read/write failure.
- [ ] C09.03: port legacy raw gameplay v1/v2 và `{state, world}` import qua explicit
  JSON file; không giả định Godot đọc được browser localStorage tự động.
- [ ] C09.04: mapping tile/world cũ sang room/spawn mới; unknown map hoặc vị trí
  không còn hợp lệ dùng safe spawn, không teleport vào collider.
- [ ] C09.05: load pipeline decode → migrate → validate → replace; file corrupt,
  incompatible ruleset/version hoặc missing content không thay session đang sống.
- [ ] C09.06: save slot UI, timestamp hiển thị từ catalog template; không catalogize IDs.
- [ ] C09.07: round-trip, old fixtures, corrupted fields, wrong ruleset, missing location,
  interrupted write và semantic state equality tests.

## Đầu ra

Versioned save contract, migration adapters/fixtures, save service/use case và
load/confirm UI. Document unsupported historical schemas và backup behavior.

## Exit gate

Không data loss khi reject load hoặc ghi thất bại. World restore sau validated
session, gameplay/formula keys/slots tách nhau. Chạy save/load trong editor và
native build ở Chapter 12; validator review cho từng field mới.

## Quyết định có ảnh hưởng

Nếu bỏ legacy display-name fields hoặc đổi command/event schema, cần explicit
migration và compatibility tests. Không tăng version tùy tiện chỉ vì đổi renderer.
