# Chapter 06 — First playable trong phòng CLB

Trạng thái: chưa bắt đầu. Phụ thuộc: Chapters 02, 04, 05.
Mục tiêu: một lát cắt chạy xuyên domain/world/UI, không mở rộng content trước khi
command/state/input boundaries đã được kiểm chứng.

## Work packages

- [ ] C06.01: composition tạo gameplay session, world và controller; inject dependencies,
  nối local signals, không view/actor gọi global session.
- [ ] C06.02: flow vào phòng → đi đến NPC → prompt → thoại/lựa chọn → command thật
  đã port → HUD phản ánh snapshot. Dialogue-only intent không tự tiêu energy.
- [ ] C06.03: controller sở hữu modal/input priority; đóng thoại khôi phục world focus
  và input, không vừa confirm choice vừa di chuyển/trigger lại interaction.
- [ ] C06.04: thông báo rejection dùng catalog; không optimistic render outcome giả.
- [ ] C06.05: thay room/đóng view/cancel dialogue giải phóng signals/tweens/input subscriptions.
- [ ] C06.06: record action trace tích hợp và video; so state với headless replay.

## Đầu ra

Một flow mẫu có controller cụ thể trong `src/presentation/controllers/`, view
models nhỏ, gameplay composition và integration tests. Không đưa tất cả vào main.gd;
Main giữ vai trò wire/lifecycle.

## Exit gate

Kịch bản chạy lại từ initial fixture cho kết quả domain như nhau. Walking/animation
không đổi progression. Rejection không commit. Input/focus/dispose không lỗi khi
mở/đóng lặp lại; không leaked nodes/resources rõ rệt. M2 đạt dù production art còn mở.

## Handoff

Đây là mẫu để port feature tiếp theo: domain → session → controller → view/world.
Lưu/load hoàn chỉnh chờ Chapter 09; không fake persistence trong first playable.
