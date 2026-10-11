# Animation UI thoại — 2026-10-11

Người dùng chấp nhận UI tĩnh và chốt scope animation của hội thoại. Giữ art,
font, bố cục và hit bounds đã có; không sửa HUD/world hoặc reference baseline.
Các static diagnostics trước đây giữ nguyên; yêu cầu mới không phụ thuộc G2 cũ.

## Hành vi

- Mở theo nhịp wave → paper/harbor → flowers → notebook → speaker/body. Các lớp
  chồng thời gian, khoảng 450 ms cho khung; body bắt đầu typewriter ở 280 ms.
- Chữ chạy 40 composite characters/giây, nghỉ tại dấu câu. Hai glyph passes
  crossfade trong 120 ms: tail được blur thật bằng shader trên viewport trong suốt;
  phần đã đọc trở nên sắc nét. Toàn bộ đoạn được shape trước để không nhảy dòng.
  Khi hoàn tất, dùng lại Label gốc, tắt viewport và internal processing của các pass.
- Bấm/Enter/A trong lúc mở, chuyển câu hoặc chạy chữ chỉ hoàn tất câu. Lựa chọn
  mở lần lượt sau đó; bấm dồn trong entrance không phát command. Lần kích hoạt
  tiếp theo mới dispatch stable choice ID hoặc continue đúng một lần.
- Hover và keyboard focus phóng visual tới 1.04× trong 150 ms, crossfade giấy
  thường/vàng và màu chữ, mũi tên dịch 3 px. Những nút khác trở về scale 1.0.
  Hit targets không scale/reflow. Rời chuột trả visual về keyboard/default selection.
- Chuyển câu giữ view/paper/foreground và phase idle; fade copy cũ 80 ms, copy mới
  140 ms, tên speaker chỉ fade-out khi đổi người. Chọn đáp án không dựng lại panel.
- Đóng rút các choices từ cuối lên đầu, rồi copy, notebook/flowers, paper và wave;
  hoàn tất khoảng 320 ms. Đóng giữa typewriter giữ nguyên phần đang đọc, không
  bật toàn bộ câu chưa đọc. Input world chỉ được trả sau `closed`; modal replacement
  không nhận callback mở khóa từ view đã bỏ.
- Idle: wave hai nhịp lệch nhau, biên độ 3 px, shimmer nhẹ; hoa đung đưa 0.35°.
  Giấy/notebook/chữ đứng yên, continue indicator chỉ nhịp nhẹ sau câu không có choices.
- Reduced motion: nội dung/choices hiện đủ ngay, không blur/typewriter/scale/idle,
  đóng ngay; giữ màu/focus và kết quả domain như chế độ thường.

## Code và authoring

Tuning nằm trong [dialogue.json](../../../content/ui/dialogue.json), được kiểm số
hữu hạn, duration/period/padding và coverage component trong content checks.
View orchestration, component construction, structural/idle motion, choice motion
và glyph reveal có owner riêng, runtime files không quá 200 nonblank lines.
Không đưa clock/tween vào domain/session hoặc thêm save field.

Chạy F5 → UI preview → **Mở lại chuyển cảnh**, hoặc mở playable và nói chuyện với Vân.
Trong preview, chọn đáp án chuyển sang câu phản hồi để xem giữ panel khi đổi câu.
Capture fixture tĩnh giữ API đồng bộ, không tự chạy motion.

Shader được viết riêng cho texture/glyph hiện có. Tham khảo nguyên lý
[sóng nhiều lớp của cin3366](https://godotshaders.com/shader/texture-based-liquid-effects/),
[liquid wave của PWira](https://godotshaders.com/shader/2d-liquid-wave/),
[RichTextEffect](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html)
và [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html).
Không nhập art hoặc code của các shader tham khảo.

## Evidence và giới hạn

Current: [video-v3](dialogue-motion-v3.mp4), [captures-v5](captures-v5/),
[verification/profile summary](evidence.json) và [byte inventory](inventory.json).
689 headless contracts, 64 native interaction/resize checks và 19 native motion
checks pass, cùng policy/reference/content checks. Windows debug/release export
và self-check trong thư mục sạch cũng pass. Source `hai-vong` không thay đổi.

Motion captures có 19 frames: opening, glyph reveal, hover/focus, blur A/B ở cùng
text clock, next line, idle hai thời điểm, reverse exit, playable và reduced motion.
Video 1280×720, 60 FPS, 499 frames/8.317 s. Dùng nút replay để xem nhịp lâu hơn hoặc
tune tốc độ; video review không thay thế xem trên máy thật.

Profile-v5 chạy riêng, không export/test/encode song song, bỏ GPU timing counters
để kiểm ảnh hưởng của instrumentation. Đây là frame interval thực, cap 120 FPS:

| Mode | 1280×720 median / p95 (ms) | 1920×1080 median / p95 (ms) |
| --- | --- | --- |
| Dialogue UI hidden, flat backdrop | 8.576 / 22.273 | 10.218 / 44.776 |
| Static | 9.115 / 18.600 | 16.367 / 64.976 |
| Idle | 17.899 / 44.616 | 16.825 / 63.853 |
| Typewriter | 17.398 / 66.019 | 8.312 / 8.552 |

Mẫu vẫn dao động, kể cả khi dialogue UI ẩn. Chưa đủ dữ liệu để tách cost của
effect khỏi scheduling/driver/load hoặc chốt FPS ổn định; không quy mọi spike
cho máy và không coi row typewriter tốt nhất là chứng nhận 120 FPS. Giữ v1–v5
và samples đầy đủ. V4 có headless verification đồng thời ở đầu mẫu nên chỉ dùng
để thử profiler, không dùng làm benchmark acceptance. Không dừng editor của người dùng.

Các captures/video/logs và profile được inventory theo version. Video dùng fixed
60 FPS simulation để đánh giá nhịp, không chứng minh FPS thực. Native input được
inject qua window transform; chưa dùng tay cầm vật lý. Các profile là mẫu ngắn
trên RTX 3050 Ti laptop, Forward+ D3D12, có editor cùng project đang mở.

Captures-v1 có lỗi probe: vùng 1672×941 bị đọc trực tiếp trên bitmap 1280×720,
và mouse skip đọc vị trí global thay vì vị trí event đã transform. Bản v2 sửa cả
hai; v3 thêm replay cancellation; v4 kiểm reverse choice exit và dừng glyph processing.
V4 còn phát hiện empty-row exit tạo tween không có tweener dù 19 assertions pass;
log guard từ chối run. V5 thêm empty-row guard và qua cả assertions/log guard.
Giữ các version cũ, không sửa hoặc ghi đè bằng kết quả mới.
