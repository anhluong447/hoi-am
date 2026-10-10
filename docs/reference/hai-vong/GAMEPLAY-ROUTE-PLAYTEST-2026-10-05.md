# Chơi thử năm route sandbox vòng ngày

Ngày: 2026-10-05. Bản chơi: `gameplay.html`, cấu hình mặc định 14 ngày.

Chơi bằng các nút, dropdown, bản đồ và bảng feedback của giao diện thật
trong Chrome headless. Không ghi đè state/save, không gọi lệnh engine để
chơi, không chỉnh cấu hình. Read-only state được dùng để ghi nhật ký và
theo dõi thông tin tiến độ; lựa chọn hồ sơ theo câu chuyện hiện ra sau bước
phỏng vấn trả phí, không xếp hạng bằng attraction ẩn. Dùng hàm summary
chỉ để đọc chỉ báo cuối lượt.

Năm route hoàn tất, tổng 807 lần bấm, 70 ngày lịch. Artifact:
[trace JSON](gameplay-route-playtest-2026-10-05.json).

## Kết quả

| Route | Bài Khuê / đồng đội đã đăng | K | T | Tổng 40/60 | Ngưỡng mock | Tiền cuối |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| Phối hợp, không nâng cấp | 2 / 5 | 77,9 | 96,0 | 88,8 | Đạt | 300 |
| Sự nghiệp + hẹn hò Vân | 2 / 5 | 85,0 | 99,8 | 93,8 | Đạt | 510 |
| Giao sai rồi cứu hồ sơ | 2 / 4 | 77,9 | 76,8 | 77,2 | Đạt | 300 |
| Hẹn hò Vân và Nhi | 2 / 5 | 77,9 | 84,3 | 81,7 | Đạt | 2.100 |
| Trì hoãn đến thứ Sáu | 2 / 2 | 77,3 | 38,4 | 53,9 | Không đạt | 300 |

Đây là ngưỡng phối hợp của mock, không phải Good Ending đã chốt.
Các route có hoạt động và số hồ sơ khác nhau; không quy toàn bộ chênh lệch
điểm giữa chúng cho một yếu tố như hẹn hò hoặc đổi người.

## Các quyết định đã thử

- **Phối hợp:** Long xử lý đề tài cộng đồng, Nhi xử lý tài liệu; tuần hai
  thêm hồ sơ ảnh cho Ngọc. Khuê tự điều tra và viết một bài mỗi tuần.
  Không dùng công cụ/nâng cấp, không hẹn hò. Chọn nghỉ ngơi ở slot tự do.
- **Sự nghiệp + đời sống:** giữ cùng năm hồ sơ đồng đội, hangout 16 lần,
  làm thêm 7 lần, luyện stat 7 lần, tặng một quà, mua công cụ ảnh cho Khuê,
  dùng hai suất CLB nâng stat tài liệu Nhi. Hẹn hò Vân ngày 6, sau ba lần
  hangout; không tự động thành đôi khi đủ bond.
- **Cứu hồ sơ:** ngày 1 giao hồ sơ tài liệu cho Long. Long báo không phù
  hợp ngay tối đó, đổi sang Nhi miễn phí qua feedback; Nhi làm lại từ đầu
  ngày 2, hoàn tất ngày 3, vẫn kịp số thứ Sáu. Một lần sai sớm không làm
  sụp vòng chơi. Route này không lấy hồ sơ ảnh tuần hai.
- **Hai mối quan hệ:** hẹn hò Vân ngày 3, Nhi ngày 6; phát hiện khi lên
  giường ngày 6. Nhi giảm hiệu suất và không đủ phù hợp với hồ sơ tài liệu
  tuần hai; ngày 8 chọn chuyển thành tin ngắn. Áp lực cảm xúc có tác động
  nghiệp vụ thật, nhưng đội còn các nguồn bài khác nên vẫn đạt ngưỡng mock.
- **Trì hoãn:** chỉ giao hồ sơ vào thứ Sáu. Hồ sơ tuần đầu nghỉ cuối tuần,
  hoàn tất thứ Hai, được xử lý và đăng ở số tuần hai. Hồ sơ tuần hai chưa
  thành bài để đăng trước khi lát cắt kết thúc. Có bài Khuê tốt vẫn không
  bù được T thấp.

Tất cả các route đều duyệt được tin nhắn khi energy bằng 0. Bảng tin chặn
chuyển ngày, đồng đội không tiến hành thêm công việc trong khi đang duyệt.

## Những điểm cần kiểm chứng tiếp

**1. Điểm trung bình số báo tạo động cơ bỏ bài hợp lệ.** Route phối hợp
có bốn bài tuần hai: 39.137, 51.118, 78.934 và 28.754 điểm. Số báo đạt
49.486. Tính đối chiếu nếu không đăng bài ảnh 28.754 thì trung bình thành
56.396. Đây là phép tính phản thực từ các bài đã chơi, chưa phải một route
curation riêng. Route trì hoãn cũng có Uy tín 14, cao hơn route phối hợp
11, mặc dù T thấp và không đạt ngưỡng kết thúc. K/T giữ được điều kiện hai
nhánh, nhưng sức hút/Uy tín hiện chưa phản ánh đầy đủ sức khỏe tòa soạn.
Nên thử cách tổng hợp có đóng góp dương hoặc mức đáp ứng nội dung số báo,
thay vì chốt ngay công thức trung bình này.

**2. Workload mock còn nhẹ.** Route phối hợp và route đời sống đều chỉ
dùng 20/40 energy CLB. Cả hai hoàn thành hai quest Khuê, năm bài đồng đội;
không phải dùng slot tối/cuối tuần điều tra. Chưa có bằng chứng rằng quỹ
energy của game thật quá lớn: quest chỉ có bốn bước và một lần viết,
nguồn tin không có lịch hẹn. Nên thử quest nhiều ngày, có cửa sổ tiếp cận
và một việc cần chọn bỏ, trước khi giảm energy hoặc tăng số hồ sơ đại trà.

**3. Feedback chạy đúng nhưng quyết định còn đơn giản.** Route phối hợp
có 10 lần approve, chủ yếu tiếp tục hoặc xác nhận nhận bài. Chỉ mismatch
buộc đổi người; còn thiếu tình huống nguồn tin xin ẩn danh, chọn thêm tư
liệu hay giữ deadline, hoặc chuyển góc tiếp cận. Giữ luật duyệt miễn phí
trước ngủ, bổ sung một tình huống có lựa chọn có sức nặng để kiểm chứng
vai trò lead, không chỉ tăng số tin nhắn.

**4. Khi chưa có người thay phù hợp, thiếu lựa chọn hoãn.** Route hai
mối quan hệ gặp Nhi không đủ phù hợp ngày 8; Ân chưa gia nhập. Feedback
hiện chỉ có đổi người/rút gọn/hủy, không cho tạm dừng chờ nhân sự. Điều
này giới hạn khả năng quản lý thời điểm. Cần thiết kế rõ nếu muốn cho
người chơi chờ, với công việc tạm dừng nhưng deadline ngày lịch vẫn chạy.

**5. Tiền và mệt mỏi chưa gây nhiều đánh đổi.** Route sự nghiệp còn 510đ
sau học, công cụ và quà; route hai mối quan hệ làm thêm 12 lần còn 2.100đ.
Mệt cuối ngày tối đa 14 trong hai route này, nên nghỉ ngơi không trở thành
lựa chọn cấp thiết. Đây là kết quả của lịch/giá/hồi phục mock, chưa phải
chỉ định giảm thu nhập hoặc tăng mệt. Cần đưa hoạt động đêm gắn với nguồn
tin vào cùng lịch để quan sát đánh đổi tiền/thông tin/phục hồi.

Hẹn hò Vân được mở ngày 6 vì ngưỡng mock thấp. Kết quả này chỉ kiểm chứng
điều kiện và quyền chủ động chọn, không kiểm chứng nhịp slow burn của truyện.

Ưu tiên vòng thử tiếp theo: công thức điểm số báo, một quest có lịch nguồn
tin và một feedback có lựa chọn thực sự. Không thay các luật đã chốt về
approve miễn phí, nghỉ cuối tuần hoặc đổi người làm lại.

## Chạy lại

Mở `tools/gameplay-playtest.html`, hoặc chạy:

```powershell
python tools/run_browser_tests.py --url http://localhost:8080/tools/gameplay-playtest.html --output-prefix playtest
python tools/report_gameplay_playtest.py
```

Playtest không thay đổi save của người chơi. Nội dung/công thức runtime
được giữ nguyên trong lần đánh giá này.
