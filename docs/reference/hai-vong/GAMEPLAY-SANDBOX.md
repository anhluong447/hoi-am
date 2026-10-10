# Sandbox vòng chơi theo bible

Mở <http://localhost:8080/gameplay.html>. Bản này kiểm chứng bible mới;
`sandbox.html` vẫn là công cụ đo công thức cũ, với save riêng.

## Một ngày

1. Nhấn **Đi học → buổi CLB**. Có 4 energy mock.
2. Xem đề tài miễn phí, trả 1 energy phỏng vấn mở hồ sơ. Câu chuyện hé lộ
   nhu cầu nghiệp vụ; không hiển thị điểm thu hút trước khi làm.
3. Trả 1 energy giao trọn hồ sơ cho đồng đội, hoặc vào bảng **Khuê** để
   trực tiếp điều tra quest. Khuê phải lấy đủ bốn loại tư liệu rồi chấp bút.
4. Kết thúc CLB, chọn một hoạt động chiều và một hoạt động tối bằng bản đồ:
   hangout/hẹn hò, học, làm thêm, điều tra hoặc nghỉ ngơi.
5. Nhấn giường. Đồng đội gửi feedback; bảng tin nhắn yêu cầu duyệt trước
   khi chuyển ngày. Duyệt/đổi phương án trong tin nhắn tốn **0 energy**.
6. Nhấn giường sau khi duyệt hết để đi ngủ. Nhấn lại trước lúc duyệt không
   khiến đồng đội làm thêm ngày công hay phát hành lại cùng một số.

Hồ sơ chuẩn cần 2 ngày làm việc. Người không phù hợp báo sau ngày đầu;
đổi người làm lại từ đầu, mất thêm 1 ngày làm việc nếu chọn đúng người thay.
Đồng đội nghỉ thứ Bảy/Chủ nhật, bao gồm đội soạn; thứ Hai tiếp tục.
Khuê vẫn có hai slot ban ngày và một slot tối cuối tuần. Skill làm cuối tuần
chưa mở. Các thời hạn đề tài theo ngày lịch vẫn tiếp tục chạy.

## Nội dung và tham số mock

- Mặc định 14 ngày. Trong **Debug** có thể đổi `days` thành 84 hoặc một bội
  số 7 từ 14–84; áp dụng tạo lượt mới.
- Khuê, Vân, Long và Nhi mở từ đầu để kiểm tra hai hồ sơ song song. Ngọc
  gia nhập ngày 8, Ân ngày 10; đây không phải lịch gia nhập chính thức.
- Ba nhóm hồ sơ mỗi tuần, một quest riêng Khuê; nội dung minh họa lặp theo
  tuần. Base stat phù hợp đủ làm tốt; không bắt buộc nâng cấp.
- Đồng đội tối đa một hồ sơ đang xử lý/người. Skill hiệp đồng sau hai
  hangout cộng 0,5 vào nghiệp vụ hồ sơ. Công cụ cộng 1 đúng loại nghiệp vụ.
- Đội soạn do Vân điều phối: tư liệu đến ngày hôm trước, tối đa 3 bài/ngày;
  thứ Sáu chốt số, bài hoàn tất viết/biên tập trước đó được phát hành.
  Đợt tác nghiệp của Vân khiến hàng đợi chờ; chưa có người thay điều phối
  trong mock này. Lựa chọn đăng tối đa bốn bài; thứ tự theo hàng đợi.
- Q đo chất lượng tư liệu; bài Khuê ×1,5; thưởng đóng gói 4%, đúng một lần.
  Số báo dùng trung bình điểm các bài đã chọn, chưa có trọng số slot cuối cùng.
- Mỗi slot điều tra ngoài giờ có 2 energy riêng. Đồ uống 50đ thêm 1 energy,
  tối đa một lần/ngày. Energy không tích lũy.
- Làm thêm 150đ, học 80đ/+0,5 stat, công cụ 220đ, quà 60đ. Quà không tăng
  mốc sự kiện; bond ≥3 và ít nhất hai hangout mở cơ hội hẹn hò tự nguyện.
- Nếu hẹn hò nhiều người, sự kiện phát hiện khi lên giường giảm 2 bond,
  giảm 25% stats chỉ ở các bạn gái đang hẹn hò. Thời hạn/hồi phục chưa
  mô phỏng; hiệu ứng giữ đến hết lượt thử, không làm mất base stats.
- Mỗi hai tuần nhận 1 suất CLB, thêm 1 nếu sức hút đạt 30.000. Một suất
  tăng 0,5 stat đồng đội. Hỗ trợ là bonus, không điều kiện nhận hồ sơ.

## Đọc kết quả

**Báo cáo** có số báo đã phát hành, lượt approve/đổi người, energy dư,
nhật ký và K/T. Nút **Xuất lượt thử** xuất toàn bộ trạng thái, công thức
và metrics để đối chiếu. Save dùng `clb-bao-chi.gameplay.v1`.

K là tổng chất lượng quest Khuê đã viết và phát hành so với một quest chất
lượng 1/tuần; không nhân lại hệ số bài 1,5. T là tổng
chất lượng bài đồng đội đã phát hành so với hai bài chất lượng 1/tuần.
Chuẩn hóa tối đa 100, tổng `0,4K + 0,6T`; ngưỡng phối hợp mock: mỗi nhánh
ít nhất 50 và tổng ít nhất 60. Đây là thước thử, không phải điều kiện Good
Ending chính thức hay kết luận cân bằng của toàn game.

Cốt truyện thật, lựa chọn bảo vệ danh tính, giờ xuất hiện nhân chứng, các
đòn phản công theo áp lực và phục hồi sau phản bội chưa triển khai.
Uy tín/áp lực hiện chỉ là chỉ báo mock. Bản thử tập trung vào lịch sinh hoạt,
phân công đúng sở trường, feedback, tiến độ đội soạn và đánh đổi thời gian.

## Kiểm chứng

Bộ kiểm thử trình duyệt hiện có 47 kiểm tra, gồm kiểm tra công thức cũ và
bản vòng chơi mới. Luồng UI thực tế kiểm tra mở/giao hồ sơ, hoạt động trên
bản đồ, bảng feedback, duyệt khi energy bằng 0, ngủ, save/load khi còn tin
nhắn và bố cục rộng 390px. Engine kiểm tra đổi người, cuối tuần, deadline
đội soạn, tư liệu quest, trang bị, tình cảm và lượt phối hợp đủ 84 ngày.

[Baseline mock](gameplay-baseline.json) lưu ba chiến thuật 14 ngày và lượt
phối hợp 84 ngày. Hai cách chơi chỉ một nhánh không đạt ngưỡng thử nghiệm;
phối hợp hai nhánh đạt. Các lượt tự động dùng hoạt động nghỉ ngơi để cô lập
tiến độ làm báo; chưa chứng minh cân bằng giữa nghề nghiệp, tiền và dating.

Chạy server, sau đó `python tools/run_browser_tests.py` và
`python tools/report_gameplay.py` để cập nhật kiểm tra và baseline.

[Playtest năm route qua UI](GAMEPLAY-ROUTE-PLAYTEST-2026-10-05.md) bổ sung
hangout, hẹn hò, làm thêm, luyện stat, cứu hồ sơ và trì hoãn deadline vào
vòng chơi. Trace từng ngày được lưu để đối chiếu các kết luận.
