# Native save contract và formula state v2

Ngày: 2026-10-10.

Gameplay giữ state v3 của ADR 002. Native envelope v1 có `kind: hoi-am-save`,
`ruleset`, `content_version: 1`, `saved_at`, `state`, `world`. World v1 có
`location_id`, `room_id`, optional `position: [x,y,z]`; coordinates không đi vào
gameplay state. Load decode → migrate → validate → replace → restore world sau
physics frame; room không khớp hoặc vị trí bị chặn dùng spawn authored.

Gameplay hỗ trợ raw v1/v2, `{state, world}` và browser envelope
`press-gameplay-save` v1, mode gameplay/pixel. Người chơi chọn file JSON; không đọc
localStorage. Tọa độ tile được bỏ ở adapter; unknown map dùng location an toàn.
Envelope/version/content/ruleset không tương thích bị reject trước replacement.

Formula dùng state **v2**, cùng technical kind `press-club-sandbox`. Khác source
v1: staff/subject names và paper labels thành catalog keys; journal dùng text key
và parameters. Numeric behavior và IDs giữ nguyên. Comparator chỉ chuyển các
display fields về source shape và version 1 để so đối chứng. Role display string
không còn trong state; công thức không dùng role. Không hỗ trợ import sandbox v1
localized trong chapter này; save native formula có namespace/envelope riêng.

Formula validator chấp nhận roster đầy đủ hoặc solo benchmark, giữ cả fatigue
keys như source. Join-week patches và config knobs hợp lệ vẫn có thể chạy trong
sandbox. Đây là khác biệt validator có chủ đích: source save validator từ chối
solo dù simulation hỗ trợ solo. Gameplay không đọc các handler/config này.

File store ghi `.tmp`, flush/close và đọc kiểm tra JSON, chuyển bản hiện tại sang
`.bak`, rồi commit temp. Nếu commit rename thất bại, thử khôi phục backup; nếu
filesystem cũng chặn rollback, backup vẫn giữ revision trước. Load không tự dùng
temp hoặc âm thầm thay bằng backup; có thể chọn `.bak` qua import file. Không hứa
transaction bền trước mọi lỗi phần cứng. Session không đổi khi read/write/load lỗi.

JSON có thể đổi representation int/float sau round-trip. `JsonData.equivalent`
so scalar numeric theo giá trị và recursively giữ đúng keys/order/types còn lại;
không dùng tolerance cho migration save. File store dùng full float precision.
Parity source dùng tolerance 1e-8 cho float, exact cho integer/IDs/events.
