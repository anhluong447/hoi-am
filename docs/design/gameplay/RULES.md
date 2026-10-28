# Bộ luật thực thi của sandbox

Nguồn: `docs/history/formula/Draft.md`, `docs/history/formula/sym.py`. Giữ nguyên hai file nguồn để
đối chiếu lịch sử. `sym.py` là mô phỏng v2 gốc (tài liệu gọi nhầm là `sim_v2.py`),
không phải oracle tuyệt đối cho các quyết định chuẩn hóa dưới đây.

## Công thức

Tham số: `content/sandbox/balance.js` (facade `src/core/config.js`). Hàm thuần:
`src/core/rules.js`. Đây là ruleset sandbox công thức; ruleset gameplay/pixel mới
dùng `content/gameplay/balance.js` và `src/domain/`, không dùng chung lịch hay điểm.

- Hiệu suất = `1 - 0.5 * fatigue / 100`.
- N = `0.6 * PV_reporter * efficiency_reporter + 0.4 * need_supporter * efficiency_supporter`.
- Khuê tự hỗ trợ: dùng sở trường Khuê ×0,5 ở thành phần thứ hai.
- Q = `clamp(1 + (N + equipment - difficulty - difficultyOffset - 1) / 10, 0, 1.4)`.
- Q <0,6: điểm/áp lực/bằng chứng bằng 0; vẫn mất energy, tăng mệt, ghi nhận việc.
- Điểm = `min(100000, 100000 * (attraction / 10)^2 * Q * (0.85 + 0.30 * grit))`.
- Áp lực = `basePressure * (0.5 + grit)`.
- Bằng chứng = `12 * Q * (0.5 + grit)`, chỉ bài mạch chính.
- Điểm báo = `min(100000, 0.8*a1 + 0.25*a2 + 0.12*a3 + 0.08*a4)`;
  sau đó nhân phạt Vân và đình bản.
- Uy tín trước đòn = `clamp(0.7*R + 0.3*paperScore/1000 - 2*emptySlots - blankPenalty, 0, 100)`.
  BlankPenalty là 5 khi không có bài có điểm, còn lại 0.
- Áp lực trước đòn = `0.85*oldPressure + publishedPressure`.

## Quyết định làm rõ

| Vấn đề | Quy tắc sandbox |
|---|---|
| Gai góc | Biên tập trước phát hành; Q giữ từ phỏng vấn |
| Bài không đăng | Không cộng bằng chứng/áp lực; công việc vẫn gây mệt và phạt Vân |
| Số bài trong tuần | Không giới hạn ở bốn; chỉ bài đăng bị giới hạn |
| Dàn trang | Chọn bài, engine xếp theo điểm; kéo để chọn, không đổi trọng số bằng thứ tự kéo |
| Bài thất bại | Không được chọn đăng, không tạo bài có điểm cho slot |
| Tự hỗ trợ | Chỉ Khuê khi không còn người khác rảnh; không cần hai người rảnh |
| Thăm dò | Chỉ đề tài đã xuất hiện, luôn trừ energy, không nhìn đề tài ngày mai |
| Huy khẩn cấp | Kiểm tra cuối tuần; `pressure >= threshold`, không giữa ngày |
| Đòn trùng lịch | Chỉ một đòn; khẩn cấp ưu tiên mức 2 |
| Trang bị | Max Uy tín cập nhật trước phạt Huy, giống v2 gốc; mốc giữ vĩnh viễn |
| Vân vắng | Đếm mọi lần tham gia tuần, kể cả thất bại/không đăng; tối đa 25% |
| Hồi mệt | Sau báo và Huy, hồi đêm −10 rồi cuối tuần −30; không hồi hai lần |
| Dữ liệu | 96 đề tài, lặp ba nhóm mẫu; xem sơ có sai lệch cố định |
| Bond/romance | Chưa triển khai, không đưa state game cũ vào |

## Thứ tự cuối tuần

1. Chọn tối đa bốn bài thành công, sắp điểm, áp trần điểm và các hệ số phạt.
2. Cập nhật Uy tín trước đòn và Uy tín cao nhất để mở trang bị.
3. Cộng bằng chứng bài đăng; hao hụt áp lực cũ rồi cộng áp lực bài đăng.
4. Kiểm tra lịch tuần 3/7 hoặc ngưỡng 100/130/160 theo hồi.
5. Phạt Uy tín 3/6/10; mức 1/2 tăng khó tối đa +2; mức 2 đình bản tuần sau.
   Giữ 30% áp lực sau đòn. Đình bản cũ tiêu thụ bởi số báo vừa phát hành.
6. Cập nhật chuỗi Uy tín 0; hồi mệt; xóa bài cũ, chuyển ngày và reset energy.
7. Hai tuần liên tiếp Uy tín 0 → giải thể. Sau ngày 60: đủ 200 bằng chứng và
   Uy tín 55 → thắng; đủ bằng chứng nhưng Uy tín thấp → thắng đắng; còn lại bại.

## Giới hạn

Tám chiến thuật là heuristic, không chứng minh tối ưu. Tự chơi chọn một mức
gai góc chung mỗi tuần; người chơi có thể chọn khác cho từng bài. Cần playtest
sau khi có dữ liệu và lịch nhân vật thật.

Các hàm hành động trả state mới, giữ đầu vào nguyên vẹn. UI, lưu và mô phỏng
dùng chung core. Test đối chiếu S04, vòng ngày/tuần, xuất bản, mức đòn,
kết cục, save/load và chạy đủ các chính sách.
