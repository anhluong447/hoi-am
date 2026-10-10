# ADR 001 — Foundation Godot độc lập

Ngày: 2026-10-10. Trạng thái: áp dụng cho skeleton; platform/camera được review lại
khi có yêu cầu thiết bị hoặc evidence blockout mới.

## Bối cảnh

Người dùng chọn runtime Godot riêng ở hoi-am, giữ hai-vong làm tham chiếu. Hướng
world 2.5D, text không hardcode, Clean Architecture và file gọn. Source hiện có
hai ruleset và domain/session contracts, cùng UI conceptual/review evidence.

## Quyết định

1. GDScript là runtime code; JSON là authored data/locale source. Node chỉ phục vụ
   import một lần, không là runtime dependency. Keys cũ giữ ổn định.
2. Domain/application/shared dùng RefCounted và data, không Nodes/I/O/clocks.
   Main wire dependencies; view/world emit signals, controllers gọi session.
3. GameSession nhận transition/validator Callables có contract nhỏ; không DI container,
   autoload session, event bus, generic command framework hay ECS.
4. Scene/script đặt cùng folder theo feature trong outer layers. Runtime file cap
   200 nonblank lines. Thư mục feature chỉ tạo khi có implementation cụ thể.
5. PC Forward+ là giả định ban đầu dựa trên project đã được tạo và mục tiêu ánh
   sáng 3D, chưa phải người dùng đã chốt bỏ web/mobile. Camera chờ blockout thử.
6. UI cố định 1672×941 và world có gate độc lập. G2/G3 source còn mở giữ nguyên.
7. Reference/baseline copy có inventory/hash; catalog target được author độc lập.
   Source không sửa, old browser architecture không là cấu trúc bắt buộc của target.

## Hệ quả và giới hạn

Có thêm bước load/validate JSON và include export filter, nhưng không cần dựng
translation plugin hay duplicated JS/JSON runtime. Invariant tests chạy với engine
headless; không quảng cáo domain GDScript là engine-free executable.

Chưa lock final state/event/save schemas, actor camera mode, art production stack,
GPU budget hoặc native export. Các chapter có experiment/exit gate cho những mục
đó. Phiên bản skeleton không thêm mechanics giả để lấp các quyết định chưa có dữ liệu.
