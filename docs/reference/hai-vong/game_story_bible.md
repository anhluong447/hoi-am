# CLB BÁO CHÍ — GAME & STORY BIBLE ĐỀ XUẤT

**Phiên bản:** proposal 0.3 · **Ngày:** 2026-10-05.

**Cập nhật 0.3:** Làm rõ phỏng vấn mở hồ sơ có tốn energy, phát hiện phân công không phù hợp sau ngày đầu và đổi người làm lại, vai trò duyệt quyết định của Khuê, nâng cấp là bonus, phạm vi giảm stats khi phản bội tình cảm và quy tắc mock cho energy ngoài giờ. Cốt truyện tiếp tục để thảo luận sau.

**Cập nhật 0.2:** Hai luồng tác nghiệp báo chí đã được phân định rành mạch: cơ chế giao trọn hồ sơ cho đồng đội tự xử lý và cơ chế trực tiếp điều tra hồ sơ riêng của Khuê. Theo định hướng mới, bài viết độc lập của Khuê sẽ có trọng lượng cao hơn khoảng 50%, đồng thời tỷ trọng đóng góp xuyên suốt toàn bộ tựa game giữa Khuê và đồng đội được xác định ở mức 40% / 60%.

Tài liệu này đề xuất một thiết kế tổng thể cho tựa game kết hợp giữa thể loại mô phỏng làm báo (journalism) và hẹn hò (dating sim). Đây là bản đề xuất phục vụ thảo luận nội bộ, chưa phải thiết lập cốt truyện chính thức (canon) hay tài liệu đặc tả kỹ thuật đã qua kiểm chứng cân bằng gameplay.

* **\[Định hướng đã có\]**: Ý tưởng cốt lõi người dùng đã định hình.

* **\[Đề xuất\]**: Lựa chọn giải pháp từ bản bible này, có thể tinh chỉnh sau thảo luận.

* **\[Thử nghiệm\]**: Các thông số và công thức giả định cần đưa vào sandbox để đo đạc thực tế.

* **\[Cần chốt\]**: Những quyết định thiết kế còn mở, có ảnh hưởng trực tiếp đến gameplay hoặc phạm vi sản xuất.

* **\[Tạm chốt\]**: Lựa chọn đang dùng làm nền thiết kế, có thể điều chỉnh sau kiểm chứng.

* **\[Đã chốt\]**: Đạo diễn (tôi) đã chốt idea này, được sửa/accept từ mục `Cần chốt`.

Tài liệu `docs/v0.1/Draft.md` hiện là nguồn đề xuất công thức tính điểm làm báo, trong khi `docs/RULES.md` mô tả môi trường sandbox đang vận hành. Cả hai tài liệu trên đều chưa phản ánh đầy đủ vòng lặp gameplay (gameplay loop) được trình bày trong bible này. Bản bible không tự ý can thiệp hay thay đổi quy tắc và nội dung của sandbox hiện hữu.

## 1. Lời hứa của game

**\[Định hướng đã có\]** Người chơi hóa thân thành Diệp Khuê, chuyển đến trường THPT Tĩnh Tâm nhằm thực hiện di nguyện của người ông quá cố: tìm lại câu lạc bộ báo chí từng có một thời hoàng kim rực rỡ. Tuy nhiên, thứ đón nhận cậu chỉ là một căn phòng xập xệ xuống cấp, những chồng báo cũ phủ bụi thời gian và Lục Thanh Vân — người duy nhất còn bám trụ lại câu lạc bộ đến mức gần như cạn kiệt niềm tin rằng nó có thể tiếp tục tồn tại.

Đồng hành cùng Vân và những người bạn mới, Khuê từng bước vực dậy tờ báo trường, săn tìm những câu chuyện thực sự có giá trị, kiên cường đương đầu với các thế lực can thiệp từ bên ngoài và dần định hình cuộc sống học đường của riêng mình. Trong bộ máy ấy, Khuê giữ vai trò dẫn dắt đội phóng viên hiện trường, còn Vân đảm trách điều phối đội ngũ biên tập và xuất bản.

**\[Đã chốt\]** Câu hỏi triết lý xuyên suốt trò chơi:

> Khi cậu bước vào câu chuyện của một ai đó, nghĩa là cậu đang tìm kiếm sự thật để thấu hiểu họ, hay chỉ để hoàn tất bài báo của chính mình?

Trải nghiệm của người chơi cần khắc họa rõ ba chuyển biến cốt lõi: căn phòng sinh hoạt dần ấm lại sức sống; các thành viên trong đội ngày càng gắn kết và nâng cao bản lĩnh nghề nghiệp; mỗi số báo chất lượng được phát hành thực sự tạo ra sức lay động và thay đổi đời sống học đường.

Tông truyện chủ đạo mang đậm màu sắc học đường kết hợp đời thường hóm hỉnh, phát triển tình cảm theo tiết tấu chậm rãi (slow burn) đan xen áp lực công việc chân thực. Mặc dù các vụ việc điều tra đều để lại hệ quả và trách nhiệm rõ ràng, game vẫn dành trọn không gian cho những bữa ăn giản dị, những buổi tản bộ thảnh thơi và những mẩu đối thoại trêu đùa tại tòa soạn. Mối quan hệ tình cảm giữa các nhân vật luôn giữ trọn nét trong sáng của lứa tuổi học sinh.

## 2. Bối cảnh và mục tiêu học kỳ

**\[Đã chốt\]** Trò chơi sử dụng bối cảnh thành phố biển hư cấu **Hải Vọng** và ngôi trường **THPT Tĩnh Tâm**, lấy cảm hứng từ văn hóa Việt Nam.

Tập san của trường tạm thời mang tên **Hồi Âm**. **\[Đã chốt\]** Ông nội của Khuê từng là **giáo viên cố vấn**, đứng ra thành lập câu lạc bộ với các học trò thân tín nhất trong những năm tháng công tác tại trường.

Trong những năm gần đây, Hồi Âm đã đánh mất lượng độc giả trung thành, cạn kiệt nguồn lực vận hành và mất đi quyền chủ động tác nghiệp. Đúng lúc này, nhà trường chuẩn bị bước vào một kỳ thẩm định chất lượng quy mô lớn. Hội học sinh chủ trương uốn nắn mọi hoạt động ngoại khóa phục vụ mục tiêu đánh bóng hình ảnh nhà trường, trong khi phía Ban Giám thị lại siết chặt các quy trình thủ tục nhằm kiểm soát gắt gao hoạt động của câu lạc bộ.

**\[Tạm chốt\]** Khung thời gian chơi là 12 tuần lịch, tương đương 84 ngày như mục 4.2.

**\[Đề xuất\]** Trong học kỳ thử nghiệm này, nếu CLB chứng minh được giá trị thực tế của mình, nhà trường sẽ buộc phải xem xét duy trì phòng sinh hoạt cũng như cấp lại quyền phát hành chính thức ra ngoài khuôn khổ của trường. Kỳ hạn này đóng vai trò nhịp điệu thúc đẩy tiến độ tổng thể, chứ không mang hàm ý bắt buộc tuần nào nhóm cũng phải đăng bài điều tra tố cáo.

Thành quả sau 12 tuần sẽ được tổng kết độc lập trên ba phương diện:

| Trục đánh giá | Tiêu chí đo lường cụ thể | 
| ----- | ----- | 
| Tòa soạn | Khả năng duy trì vận hành ổn định, mức độ tín nhiệm từ độc giả và năng lực tự chủ của đội ngũ khi bước tiếp | 
| Điều tra | Mức độ xác thực và tầm vóc của các sự thật trọng yếu đã được chứng minh và công bố ra công chúng | 
| Quan hệ | Mạng lưới quan hệ mà Khuê đã dày công xây dựng, cùng những lựa chọn cảm xúc cá nhân của cậu | 

Một kết thúc mỹ mãn về con đường làm báo hoàn toàn có thể song hành với một kết cục độc thân. Ngược lại, việc chinh phục thành công một nhánh tình cảm cũng không tự động đảm bảo rằng các vụ án điều tra sẽ đi đến thắng lợi.

## 3. Các trụ cột thiết kế

1. **Chất lượng đầu vào định đoạt kết quả đầu ra:** Năng lực nhân sự, phương pháp tiếp cận, nguồn tư liệu thu thập cùng quy trình kiểm chứng chéo sẽ trực tiếp quyết định chất lượng bài báo. Khâu đóng gói cuối kỳ chỉ đóng vai trò hoàn thiện và mang lại điểm thưởng nhỏ.

2. **Vận hành hai luồng tác nghiệp song song:** Đồng đội sẽ tự chủ phụ trách trọn gói hồ sơ được giao trong vài ngày; trong khi đó, Khuê trực tiếp thực hiện các chuỗi nhiệm vụ chính (main quest) và nhiệm vụ phụ (sub quest) riêng biệt. Người chơi hoàn toàn không phải quản lý vi mô (micro-manage) từng thao tác vụn vặt của đồng đội.

3. **Phân bổ tài nguyên đúng mục đích:** Thời gian dùng để lựa chọn hoạt động; năng lượng (energy) giới hạn khối lượng công việc báo chí trong ngày; mức độ mệt mỏi ảnh hưởng trực tiếp đến hiệu suất cá nhân; tiền bạc phục vụ việc trang trải chi phí và mua sắm thiết bị chuyên dụng.

4. **Phát huy sở trường nhân sự linh hoạt:** Mỗi đồng đội đều sở hữu thế mạnh chuyên môn riêng biệt, đóng vai trò đòn bẩy hiệu suất chứ không tạo ra rào cản độc quyền biến họ thành nhân vật duy nhất có thể thực hiện một chức năng cơ bản.

5. **Mối quan hệ mở ra phương thức hiệp đồng mới:** Chỉ số cá nhân, kỹ năng nghề nghiệp, độ gắn kết (bond) và nhánh tình cảm (romance) mang lại những giá trị cơ chế khác nhau, tránh việc dồn mọi sự tiến triển vào một thanh điểm duy nhất.

6. **Hệ quả xác định trong phiên bản đầu:** Yếu tố rủi ro bắt nguồn từ sự thiếu hụt thông tin, sai lầm trong ra quyết định hoặc sắp xếp lịch trình không hợp lý. Trò chơi không phụ thuộc vào yếu tố ngẫu nhiên (RNG) để tạo bất ngờ cho mạch truyện.

7. **Đồng hành để chạm tới Good Ending:** Một phóng sự xuất sắc của riêng Khuê không thể cứu vãn một tòa soạn rệu rã; ngược lại, những bài viết đều đặn của đồng đội cũng không thể thay thế việc Khuê đích thân phơi bày các sự thật cốt lõi của cốt truyện.

## 4. Một ngày của Khuê

### 4.1. Ngày đi học

**\[Định hướng đã có\]** Từ thứ Hai đến thứ Sáu, buổi sáng dành cho việc học tập trên lớp. Buổi chiều được chia thành hai khung giờ: hai tiếng dành cho công việc quản lý CLB và hai tiếng dành cho sinh hoạt cá nhân. Buổi tối là khoảng thời gian tự do ngoài khuôn viên trường.

| Khung thời gian | Trải nghiệm Gameplay | Điều kiện kết thúc | 
| ----- | ----- | ----- | 
| Sáng | Học chính khóa; tương tác cốt truyện; tiếp xúc đối tượng; xem sơ lược hồ sơ miễn phí | Hết giờ học | 
| Chiều — CLB | Nghiên cứu hồ sơ, tiêu hao energy, phân công tác nghiệp, tham gia xử lý chuyên môn | Chủ động kết thúc hoặc khi cạn kiệt thời gian / energy | 
| Chiều — Cá nhân | Tham gia một buổi đi chơi (hangout), hẹn hò lãng mạn hoặc hoạt động phát triển cá nhân | Hoàn thành hoạt động | 
| Tối | Chọn một hoạt động ngoài phố: rèn luyện kỹ năng, làm thêm, gặp gỡ nhân chứng, điều tra ban đêm hoặc nghỉ ngơi | Trở về nhà; hồi phục chỉ số; hệ thống chuyển ngày | 

Các thao tác di chuyển, đọc lướt hồ sơ và chào hỏi xã giao thông thường sẽ không làm tiêu hao lượt hoạt động. Giao diện người dùng (UI) cần phân biệt rạch ròi giữa hành động thăm dò thông tin miễn phí và hành động xác nhận tiêu tốn tài nguyên.

**\[Đã chốt\]** Việc bắt chuyện miễn phí chỉ cung cấp góc nhìn tổng quan về vấn đề để cho phép người chơi quyết định có đầu tư vào đối tượng hay không. Bất kỳ dữ liệu nào đòi hỏi khâu chuẩn bị, kỹ năng khai thác chuyên sâu hay kiểm chứng thực địa đều phải được thiết kế thành tác vụ chính thức. Người chơi không thể thâu tóm toàn bộ tư liệu bài viết chỉ bằng cách bấm qua các chuỗi thoại miễn phí.

Nếu có một sự kiện đặc biệt chiếm dụng toàn bộ khung giờ của một buổi, hệ thống phải phát cảnh báo từ trước. Trò chơi không được phép tự động trừ lượt hangout cá nhân chỉ vì người chơi dừng lại quá lâu ở menu phân công. Trường hợp người chơi lựa chọn làm việc thêm giờ để đẩy nhanh tiến độ, hệ thống phải thông báo chính xác slot thời gian cá nhân hoặc slot buổi tối sẽ bị hoán đổi.

### 4.2. Cuối tuần

**\[Tạm chốt\]** Quy chuẩn học kỳ kéo dài 12 tuần lịch, tương đương 84 ngày (bao gồm 60 ngày đi học chính khóa). Còn lại về sau có extend thêm hay không thì sẽ tính thêm.

**\[Đã chốt\]** Thứ Bảy và Chủ nhật không diễn ra các buổi sinh hoạt CLB định kỳ. Thay vào đó, mỗi ngày cuối tuần bao gồm hai slot hoạt động ban ngày và một slot hoạt động buổi tối, phục vụ mục đích hangout, hẹn hò, rèn luyện kỹ năng, làm thêm kiếm sống hoặc nghỉ ngơi phục hồi. Các vụ điều tra trọng điểm có thể kích hoạt các cuộc hẹn đặc biệt vào cuối tuần, nhưng các sự kiện này sẽ chiếm dụng trực tiếp chính slot ban ngày hoặc buổi tối tương ứng, chứ không cấp thêm lượt điều tra miễn phí ngoài các hoạt động đã định.

**\[Đã chốt\]** Đồng đội không làm việc vào thứ Bảy và Chủ nhật, bao gồm tác nghiệp hồ sơ, viết, biên tập và xuất bản. Tiến độ công việc của họ tạm dừng trong hai ngày này và tiếp tục vào ngày làm việc kế tiếp; thời lượng hồ sơ được tính bằng ngày làm việc, không phải ngày lịch. Ví dụ, hồ sơ cần 2 ngày làm việc khởi động vào thứ Sáu sẽ hoàn thành vào thứ Hai nếu không có trở ngại. Hạn chót theo ngày lịch của đề tài vẫn giữ nguyên. Quy tắc này không ngăn Khuê tham gia các cuộc điều tra cuối tuần theo slot đã định.

**\[Định hướng đã có — bổ sung về sau\]** Ngoại lệ làm việc cuối tuần chỉ mở khi đồng đội có skill làm việc cuối tuần. Skill này chưa được coi là có sẵn trong phiên bản hiện tại; điều kiện mở khóa, phạm vi tác dụng và chi phí sẽ thiết kế sau.

### 4.3. Energy và khả năng làm việc

**\[Thử nghiệm\]** Mỗi buổi sinh hoạt CLB khởi đầu với 4 điểm energy làm báo định mức; số điểm này không được tích lũy sang các ngày tiếp theo. Energy đại diện cho mức độ tập trung và năng lực điều phối của Khuê, được sử dụng chung cho các hoạt động chuyên môn của tòa soạn.

**\[Đã chốt\]** Hành động bàn giao hồ sơ chỉ tiêu tốn energy vào thời điểm khởi động; sau đó, đồng đội sẽ tự giác triển khai công việc theo tiến độ đã thống nhất mà không cần người chơi phải thao tác lặp lại mỗi ngày. Ngược lại, khi Khuê trực tiếp điều tra hồ sơ cá nhân, energy sẽ bị trừ dần theo từng hành động cụ thể mà cậu thực hiện. Đọc và duyệt feedback, bao gồm chọn phương án xử lý trong feedback, không tốn energy. Nếu quyết định đó dẫn đến một hành động nghiệp vụ riêng có chi phí, chẳng hạn Khuê tự đi hỗ trợ hiện trường hoặc khởi động lại hồ sơ với người mới, chi phí chỉ tính khi thực hiện hành động riêng và phải được hiển thị trước; không tính phí cho thao tác duyệt tin nhắn.

**\[Thử nghiệm — mock ngoài giờ\]** Ngày đi học giữ quỹ 4 energy cho buổi CLB. Nếu chọn điều tra trong slot tối, Khuê nhận một quỹ riêng 2 energy chỉ dùng trong slot đó, không chuyển từ hoặc cộng ngược vào quỹ CLB. Cuối tuần, mỗi slot ban ngày hoặc buổi tối được chọn để điều tra cũng có quỹ riêng 2 energy. Mỗi hành động điều tra cơ bản tạm tốn 1 energy; dùng hết quỹ hoặc chủ động kết thúc sẽ kết thúc hoạt động của slot. Hangout, làm thêm và nghỉ ngơi sử dụng slot tương ứng nhưng không dùng energy báo chí. Quỹ ngoài giờ không tích lũy; mức mệt mỏi và chi phí hành động đặc biệt sẽ thiết kế sau. Đây là giả định để dựng mẫu, chưa phải thông số cân bằng đã chốt.

**\[Thử nghiệm\]** Mỗi nhân sự đồng đội chỉ nên đảm trách một hồ sơ chủ lực tại một thời điểm nhất định. Thời gian hoàn thành tiêu chuẩn dao động từ 2–3 ngày làm việc, ngoại trừ những đề tài đơn giản có thể hoàn thành nhanh hơn. Đây là giới hạn về tải trọng công việc (workload) nhằm phục vụ cân bằng cơ chế, tránh bắt người chơi phải sắp đặt lịch trình chi li theo từng giờ. Đội ngũ biên tập sở hữu lịch trình và công suất viết, biên tập, in ấn riêng biệt; hệ thống cần được cân bằng sao cho tránh tình trạng phân công một nhân sự cáng đáng liên tiếp ba tác vụ vụn vặt trong cùng một hồ sơ.

Quy mô nhân sự mở rộng giúp đa dạng hóa phương án phân bổ và tối ưu hóa việc bố trí đúng sở trường, song không đồng nghĩa với việc tổng điểm energy sẽ tự động nhân lên theo sĩ số thành viên. Một số kỹ năng lãnh đạo mở khóa về sau có thể giúp gia tăng quỹ energy tối đa, nhưng lượng điểm này sẽ không tăng thêm sau mỗi lần thăng cấp quan hệ nhằm ngăn chặn hiện tượng lạm phát chỉ số.

## 5. Vòng làm báo

```
Luồng đồng đội:
Khuê tìm đối tượng → Xem sơ lược miễn phí → Phỏng vấn mở hồ sơ (tốn energy)
→ Đánh giá câu chuyện đã hé lộ → Chọn nhân sự & giao trọn hồ sơ
→ Đồng đội tự tác nghiệp qua vài ngày → Phản hồi tiến độ sau mỗi ngày
-> Có thể sẽ có những lựa chọn cần Khuê approve -> Tiếp tục làm
-> Không phù hợp: báo ngay sau ngày làm việc đầu → Đổi người làm lại từ đầu (mất thêm một ngày làm việc nếu có người thay ngay)
→ Hoàn thành tư liệu → Đội soạn tiếp nhận xử lý → Xuất bản số báo

Luồng của Khuê:
Main quest / Sub quest → Trực tiếp điều tra, đối thoại, kiểm chứng
→ Khuê chấp bút viết bài → Đội soạn tiếp nhận xử lý → Xuất bản bài viết trọng lượng lớn

```

### 5.1. Đối tượng và đề tài

**\[Định hướng đã có\]** Đối tượng khai thác thông tin có thể là một NPC, một sự vật hoặc một chuỗi sự việc cụ thể. Mỗi tuần làm việc sẽ xuất hiện một nhóm đối tượng đặc trưng, đi kèm khung thời gian và phương thức tiếp cận riêng biệt.

**\[Đề xuất\]** Mỗi hồ sơ đề tài cần bao hàm các trường thông tin sau:

* Sự việc thực tế, các cá nhân liên quan, giá trị câu chuyện tiềm năng và các góc độ khai thác khả dĩ.

* Thời điểm xuất hiện, địa điểm hoặc nhân vật có thể tiếp cận, cùng các mốc thời hạn chót cụ thể.

* Những dữ liệu nắm bắt được ngay qua thao tác xem sơ lược; những dữ liệu chuyên sâu chỉ hé lộ sau khi thực hiện hành động nghiệp vụ.

* Danh mục hành động khả dụng, đi kèm điều kiện thực hiện, chi phí tài nguyên, yêu cầu kỹ năng và kết quả kỳ vọng.

  * Các điều kiện thông tin bắt buộc, nguồn tư liệu bổ trợ tùy chọn và tiêu chuẩn kiểm chứng chéo.

* Tiềm năng thu hút độc giả, mức độ nhạy cảm của vấn đề và sợi dây liên kết với các tuyến điều tra khác.

Trò chơi không áp dụng một kỳ hạn 5 ngày cứng nhắc cho mọi đề tài. Chẳng hạn, phóng sự về một trận đấu thể thao sẽ mất hoàn toàn tính thời sự nếu chậm trễ sau hai ngày; trong khi đó, một hồ sơ sai phạm tài chính có thể kéo dài suốt học kỳ nhưng nhân chứng then chốt lại chỉ xuất hiện duy nhất trong một buổi chiều. Cần phân định rạch ròi ba mốc thời gian: hạn chót tiếp cận nhân chứng, hạn chót thu thập tư liệu và hạn chót phát hành số báo.

### 5.2. Nhận đề tài

**\[Đã chốt\]** Xem sơ lược và chào hỏi miễn phí chỉ hé lộ đối tượng tiềm năng. Khuê phải bỏ một phần energy để tiến hành phỏng vấn mở hồ sơ; lúc đó đối tượng mới chia sẻ câu chuyện đủ sâu để người chơi đánh giá liệu có đáng viết báo và nên giao cho ai. Với đối tượng phi nhân vật, bước tương đương là khảo sát mở hồ sơ có tốn energy. Chi phí phỏng vấn và bàn giao cần hiển thị riêng; mức phí cụ thể còn thử nghiệm. Người được giao hồ sơ sẽ tự triển khai phỏng vấn chuyên sâu, thu thập tài liệu và xác minh thông tin, trong khi Khuê giữ quyền duyệt các quyết định cần ý kiến lead.

Trước khi bấm duyệt phân công, giao diện hiển thị stats nhân sự, thời gian dự kiến hoàn thành, các trở ngại đã nhận diện và chi phí energy khởi động. Không hiển thị điểm thu hút dự đoán hoặc nhãn khẳng định ai là lựa chọn đúng; người chơi đánh giá qua những gì đối tượng đã kể và hiểu biết về đồng đội.

**\[Đã chốt\]** Nếu người được giao không phù hợp với hồ sơ, họ sẽ báo ngay sau ngày tác nghiệp đầu tiên, trong feedback buổi tối. Khuê đổi sang một người khác còn khả dụng và người mới làm lại từ đầu; nếu bố trí được ngay thì chỉ mất thêm một ngày làm việc so với phân công đúng ban đầu. Không chuyển giao sản phẩm nghiệp vụ chưa hoàn chỉnh để người sau tiếp tục trên một nền tảng khai thác không phù hợp. Nếu chưa có người thay hoặc liên tiếp chọn sai, thời gian chờ vẫn có thể ảnh hưởng hạn chót. Việc bảo lưu hồ sơ tạm ngưng bên dưới không đồng nghĩa được kế thừa tiến độ tác nghiệp khi đổi người vì không phù hợp.

Những hồ sơ thuộc luồng nhiệm vụ chính hoặc nhiệm vụ phụ của Khuê sẽ do chính cậu trực tiếp xử lý thay vì ủy thác cho đồng đội. Đối với các đối tượng phi nhân vật, người chơi sẽ sử dụng lệnh "Khảo sát hiện trường" thay vì bắt buộc dùng lệnh "Phỏng vấn".

Người chơi có toàn quyền tiếp tục, tạm dừng hoặc hủy bỏ một hồ sơ được gán là side quest. Các tác vụ đã hoàn thành sẽ không được hoàn trả energy đã tiêu tốn; những hồ sơ tạm ngưng sẽ được bảo lưu tài liệu cho đến khi hết hạn thời sự hoặc bị thay đổi do các sự kiện cốt truyện phát sinh.

### 5.3. Đồng đội tự làm và feedback

**\[Định hướng đã có\]** Sau mỗi ngày tác nghiệp, đồng đội sẽ gửi báo cáo tiến độ (feedback). Bản tin này tập trung thông báo ngắn gọn về những tư liệu đã thu thập được, những mảnh ghép còn thiếu sót và ước tính thời gian hoàn thành còn lại, giải phóng người chơi khỏi việc phải duyệt lại những quy trình đang vận hành thuận lợi.

**\[Đã chốt\]** Feedback là một phần của vai trò lead: người chơi vẫn phải approve các đề nghị cần quyết định hoặc chọn phương án khác, chẳng hạn cấp thêm thời gian, chi viện công cụ, chuyển hướng bài viết hay đổi người phụ trách. Đồng đội tự thực hiện các bước nghiệp vụ nội bộ, nhưng hệ thống không tự quyết thay Khuê những lựa chọn thuộc trách nhiệm lead. Nhịp xuất hiện các quyết định sẽ được kiểm chứng trong sandbox.

**\[Đã chốt\]** Đọc và approve feedback hoặc chọn phương án khác trong tin nhắn không tốn energy, kể cả khi Khuê đã dùng hết energy trong ngày. Khi người chơi nhấn vào giường để đi ngủ, nếu còn tin nhắn đồng đội chưa xử lý, hệ thống hiện bảng thông báo còn tin nhắn cần duyệt và yêu cầu người chơi vào xử lý ngay. Không chuyển ngày khi còn tin nhắn chưa xử lý; sau khi duyệt hết, người chơi có thể tiếp tục đi ngủ. Quyết định duyệt không tạo thêm một ngày tác nghiệp cho đồng đội vào đêm đó. Đồng đội nghỉ cuối tuần không phát sinh feedback tiến độ mới do công việc tự chạy, trừ khi về sau có skill cho phép làm việc cuối tuần.

*Ví dụ minh họa:* Long được phân công điều tra về việc đóng cửa sân bóng. Sau ngày đầu, cậu ghi nhận được tiếng nói bức xúc từ phía học sinh nhưng chưa tiếp cận được người quản lý cơ sở vật chất. Lúc này, người chơi có thể chỉ đạo kế hoạch để Long tiếp tục bám đuổi, chuyển thành một bài phản ánh ngắn gọn hoặc đổi người khác.

Kết quả của từng khâu nghiệp vụ nội bộ sẽ được tóm tắt mạch lạc để giải trình cho chất lượng bài viết đầu ra. Người chơi không cần cắt cử thêm một phóng viên ảnh và một nhân sự thẩm định đi kèm cho mỗi hồ sơ của đồng đội. Kỹ năng cá nhân và trang bị chuyên dụng sẽ tự động nâng tầm hiệu quả công việc của người được giao phó.

### 5.4. Hành động trực tiếp trong hồ sơ Khuê

| Thao tác nghiệp vụ | Đòi hỏi kỹ năng điển hình | Thành quả thu nhận | 
| ----- | ----- | ----- | 
| Phỏng vấn sâu | Phỏng vấn, Hiểu chuyện | Lời trần tình chi tiết, động cơ cá nhân, các điểm mâu thuẫn | 
| Khám phá hiện trường | Điều tra | Dấu vết thực địa và mở ra manh mối tiếp cận mới | 
| Tác nghiệp ảnh | Ảnh | Nguồn tư liệu thị giác đắt giá, củng cố luận điểm | 
| Tra cứu hồ sơ | Tài liệu | Mốc thời gian chính xác, số liệu đối chiếu, giấy tờ xác thực | 
| Đối chiếu chéo nguồn tin | Tài liệu / Điều tra | Khẳng định tính đúng đắn hoặc bác bỏ một nghi vấn | 
| Tiếp cận người dè chừng | Hiểu chuyện | Giành được sự tin cậy, thấu hiểu giới hạn chia sẻ của họ | 
| Chất vấn người có quyền lực | Phỏng vấn / Bản lĩnh | Thu thập phát ngôn chính thức hoặc ghi nhận thái độ né tránh | 

Mỗi thành quả thu được là một dữ kiện hoặc tư liệu có định danh rõ ràng trong hồ sơ vụ việc. Việc lặp lại thao tác chụp cùng một khung cảnh sẽ không mang lại điểm tích lũy vô hạn. Mỗi mục tiêu điều tra đều mở ra nhiều phương án giải quyết linh hoạt: xin trích sao hồ sơ lưu trữ, tra cứu kho dữ liệu mở hoặc đối chất chéo với một nhân chứng thứ hai.

**\[Đã chốt\]** Khi chỉ số kỹ năng của Khuê chưa đạt ngưỡng yêu cầu, hệ thống sẽ giới hạn lượng thông tin thu được hoặc mở ra thêm một bước xử lý bổ sung, thay vì biến mọi tình huống thành kết quả thắng - thua trắng đen cơ học. Một số trở ngại mang tính tuyệt đối cần được hệ thống cảnh báo rõ ràng từ trước. Một hành động thất bại sẽ không bao giờ thưởng điểm ảo hay cung cấp chứng cứ giả mạo cho người chơi.

### 5.5. Viết, biên tập, xuất bản

**\[Định hướng đã có\]** Cả ba công đoạn này đều là nhiệm vụ chuyên môn được giao phó cho các nhân sự trong đội ngũ.

**\[Đã chốt\]** Khâu viết bài được tính toán chi tiết cho từng tác phẩm; trong khi đó, khâu biên tập và in ấn phát hành có thể gộp xử lý theo lô hoặc theo từng số báo nhằm tránh lặp lại cùng một thao tác thủ tục tới bốn lần. Giao diện tòa soạn vẫn thể hiện rõ ràng danh tính cây bút chấp bút, biên tập viên chịu trách nhiệm và người phụ trách khâu in ấn phát hành.

* **Chấp bút (Viết):** Định hình góc tiếp cận và sắp xếp hệ thống luận cứ, tư liệu; khâu này tuyệt đối không thể tự bịa ra những chứng cứ còn thiếu.

* **Biên tập:** Thẩm định tính chuẩn xác của các phát biểu, trau chuốt hình thức trình bày, giật tít thu hút và thiết lập phương án bảo vệ nguồn tin.

* **Xuất bản:** Hoàn thiện khâu chế bản in hoặc chuẩn bị nền tảng đăng tải, tổ chức phát hành đúng thời điểm ấn định.

Các công đoạn tác nghiệp vận hành theo chuỗi liên hoàn có tính phụ thuộc. Chỉ những hồ sơ đã hoàn tất khâu thu thập tư liệu mới được đưa vào hàng đợi của tổ biên tập; tuyệt đối không thể biên tập trên một bản thảo chưa thành hình. Người chơi phân bổ nhiệm vụ theo từng bài viết, theo đợt duyệt bài hoặc theo lịch phân ca của đội soạn, loại bỏ nhu cầu theo dõi từng thao tác nội bộ mỗi ngày.

Đối với các hồ sơ điều tra riêng của Khuê, cậu chịu trách nhiệm toàn diện từ khâu tìm kiếm thông tin đến khâu chắp bút. Sau đó, Vân cùng đội soạn vẫn có thể phối hợp biên tập và đưa bài viết vào số báo chung của tuần. **\[Đã chốt\]** Mọi bài viết đều bắt buộc phải thông qua quy trình phát hành của tòa soạn, trừ một vài trường hợp đặc biệt trong cốt truyện.

**\[Thử nghiệm\]** Định mức tiêu hao năng lượng và công suất xử lý của đội soạn hiện vẫn để ngỏ. Cần đưa vào thử nghiệm thực tế năng lực thông qua (throughput) của hệ thống khi tiếp nhận nhiều bài viết từ đồng đội cùng lúc với một phóng sự dài kỳ của Khuê trước khi chốt mức energy dành cho khâu viết, biên tập và xuất bản. Hệ thống không tự động áp đặt chi phí duy trì nội bộ phát sinh mỗi ngày lên một hồ sơ đã bàn giao trọn gói nếu giao diện khởi tạo ban đầu không đưa ra thông báo rõ ràng về chi phí này.

**\[Đề xuất\]** Thời điểm ra báo định kỳ được ấn định vào chiều thứ Sáu hàng tuần. Theo đó, các bài viết cần hoàn thành khâu chắp bút muộn nhất vào ngày thứ Năm, dành trọn vẹn ngày thứ Sáu cho công tác hiệu đính và in ấn phát hành. Những dữ liệu thu thập quá sát hạn chót sẽ được chuyển lưu sang số tiếp theo (nếu vẫn giữ được tính thời sự). Việc phát hành chậm trễ sẽ kéo theo những hệ quả thời điểm tức thì trong mạch truyện; người chơi không thể tua lại tuần cũ để đưa ra lựa chọn khác.

## 6. Chất lượng và điểm số

### 6.1. Đầu vào

**\[Đã chốt\]** Giá trị của một hồ sơ bài viết được đo lường toàn diện qua ba phương diện:

| Tiêu chí | Câu hỏi then chốt | 
| ----- | ----- | 
| Câu chuyện | Đề tài có đủ sức nặng, giàu ý nghĩa xã hội và sở hữu góc nhìn sắc sảo hay không? | 
| Xác thực | Các luận điểm và nhận định đưa ra được kiểm chứng chéo chặt chẽ đến mức độ nào? | 
| Tư liệu | Hệ thống nhân chứng, tư liệu hình ảnh và văn bản lưu trữ hỗ trợ có tương xứng và thuyết phục không? | 

Mỗi thể loại bài viết sẽ đặt ra những chuẩn mực khắt khe riêng biệt. Một bài viết chân dung nhân vật không bắt buộc phải đính kèm hóa đơn chứng từ; ngược lại, một phóng sự điều tra khuất tất tài chính sẽ trở nên rỗng tuếch nếu chỉ dựa vào một tấm ảnh bắt mắt cùng những lời trần tình thiếu cơ sở.

Điểm chất lượng nội dung được tích lũy thông qua các lợi thế nghiệp vụ cụ thể. Điểm chỉ số cá nhân quyết định chiều sâu khi khai thác; kỹ năng chuyên môn mở ra các hướng tiếp cận mới; vật phẩm bổ trợ giải quyết các chướng ngại tác nghiệp; trang bị chuyên dụng tối ưu hóa hiệu suất của công đoạn tương ứng. Trò chơi không cộng dồn điểm thưởng thụ động chỉ vì người chơi mang theo quá nhiều đồ nghề trong ba lô.

### 6.2. Khung tính thử

**\[Thử nghiệm — chưa kiểm chứng\]** Hệ thống tạm thời kế thừa thang điểm và đường cong tăng trưởng ban đầu, nhưng biến số $Q$ giờ đây sẽ phản ánh chất lượng của **toàn bộ chuỗi tác nghiệp**. Chất lượng bài viết của đồng đội phụ thuộc vào mức độ tương thích sở trường, năng lực cá nhân, kỹ năng hỗ trợ, công cụ trang bị và kết quả tự xử lý; trong khi đó, chất lượng bài của Khuê phụ thuộc trực tiếp vào từng bước điều tra thực tế mà người chơi đã thực hiện, chứ không đơn thuần chỉ kiểm tra chỉ số vào thời điểm nhận quest:

* Gọi $A$ là độ thu hút đã khai thác từ câu chuyện cùng các lợi thế nghiệp vụ độc lập.

* $Q_{\text{hồ sơ}} = \text{chất lượng khai thác} \times \text{mức đầy đủ tư liệu} \times \text{mức kiểm chứng phù hợp}$. Mức đầy đủ tư liệu đo việc đáp ứng các yêu cầu nội dung của hồ sơ, không bao gồm thưởng đóng gói ở khâu cuối.

* Công thức tính điểm cơ sở:
  

  $$
  \text{Điểm cơ sở} = 100\,000 \times \left(\frac{A}{10}\right)^2 \times Q_{\text{hồ sơ}}
  $$

* Hệ số bài viết: ấn định bằng $1{,}0$ đối với bài của đồng đội; xấp xỉ $1{,}5$ đối với bài điều tra riêng của Khuê.

* Công thức tính điểm phát hành cuối cùng:
  

  $$
  \text{Điểm phát hành} = \min\left(100\,000, \, \text{Điểm cơ sở} \times \text{Hệ số bài} \times (1 + \text{thưởng đóng gói})\right)
  $$

**\[Định hướng đã có\]** Bài viết độc lập của Khuê sở hữu trọng lượng cao hơn khoảng 50%. Hệ số $1{,}5$ là cách lượng hóa giả định ban đầu và cần được cân chỉnh lại trong quá trình lập trình; con số này không đồng nghĩa với việc một hồ sơ sơ sài của Khuê sẽ vượt mặt một bài viết chỉn chu do đồng đội thực hiện. Mức trần $100\,000$ điểm có thể khiến khoảng cách 50% bị thu hẹp đáng kể khi các bài viết đều chạm tới ngưỡng tối đa.

Mọi hệ số thành phần đều cần được chuẩn hóa toán học trước khi đưa vào code. Chất lượng bài của đồng đội căn cứ vào năng lực của người trực tiếp phụ trách, không ép người chơi phải ghép đôi thủ công từng cặp phóng viên - hỗ trợ cho mỗi khâu. Công thức tổng hợp sau cùng vẫn đang trong giai đoạn hoàn thiện.

**\[Thử nghiệm\]** Thưởng đóng gói bắt nguồn từ khâu chấp bút, biên tập và phân phối xuất sắc, dao động từ 0 đến 0,08 (0–8%); hệ số nhân tương ứng là 1,00–1,08. Phần thưởng này chỉ áp dụng một lần trong công thức điểm phát hành, không nằm trong $Q_{\text{hồ sơ}}$. Nếu thiếu vắng các khâu nghiệp vụ bắt buộc, bài viết sẽ bị từ chối cấp phép phát hành. Việc mạo hiểm phát hành một ấn bản chưa qua kiểm chứng đồng nghĩa với việc chấp nhận một lối rẽ rủi ro với những hệ lụy nhãn tiền, chứ không chỉ đơn thuần là việc nhận trọn điểm số rồi chịu một mức trừ phạt tượng trưng.

**\[Tạm chốt\]** Chỉ số "Độ gai góc" sẽ quyết định góc nhìn tiếp cận, mức độ công khai danh tính và khối lượng dữ liệu đưa lên mặt báo. Cơ chế này không thể tự động sản sinh thêm chứng cứ nếu người chơi chưa điều tra. Khối lượng bằng chứng khả dụng hoàn toàn phụ thuộc vào quá trình thực địa; người chơi là người quyết định sẽ công bố bao nhiêu phần trăm sự thật và che chắn nguồn tin bằng cách nào. Về mặt giao diện, mức độ gai góc nên được tinh gọn thành ba sự lựa chọn trực quan thay vì tiếp tục sử dụng thanh trượt phức tạp.

Cần phân định rạch ròi giữa điểm số của từng bài viết đơn lẻ và điểm số chung của toàn bộ kỳ phát hành. Trò chơi có thể tạm giữ cơ chế 4 vị trí (slot) bài viết làm nền tảng ban đầu; hệ số phân bổ điểm giữa các vị trí còn cần thiết kế và kiểm chứng cho quy trình mới.

### 6.3. Đóng góp toàn game: Khuê 40%, đồng đội 60%

**\[Định hướng đã có\]** Đóng góp của Khuê chiếm tỷ trọng khoảng 40% trong bức tranh tổng thể của toàn bộ tựa game; 60% còn lại thuộc về nỗ lực bền bỉ của các thành viên CLB. Bản bible quy ước đây là tỷ lệ trọng số dùng để đánh giá kết quả nghiệp vụ hướng tới Good Ending, chứ không phải tỷ lệ chia chác số lượng bài viết hay số lượng vị trí trên trang báo.

**\[Tạm chốt\]** Tiến hành đánh giá độc lập hai nhánh theo thang điểm chuẩn hóa trước khi tổng hợp:

* Gọi $K$ là kết quả định lượng của nhánh Khuê, được chuẩn hóa trên thang điểm $0 \dots 100$.

* Gọi $T$ là kết quả định lượng của nhánh đồng đội và tòa soạn, được chuẩn hóa trên thang điểm $0 \dots 100$.

* Chỉ số kết quả nghiệp vụ chung được xác định theo công thức:
  

  $$
  \text{Kết quả nghiệp vụ} = 0{,}40 \times K + 0{,}60 \times T
  $$

Hệ số bài viết $1{,}5$ đã được áp dụng trực tiếp trong quá trình chấm điểm bài viết khi phát hành, do đó tuyệt đối không nhân chồng thêm một lần nữa khi quy đổi $K$ và $T$. Cách thức tính toán chi tiết cho $K$ và $T$, các mốc quy chuẩn cùng ngưỡng điểm để đạt Good Ending vẫn cần thảo luận thêm; tránh việc cộng dồn điểm số thô của hai nhánh rồi mặc định gán cho nó tỷ lệ 40/60.

*Ví dụ minh họa:* Nếu $K = 100$ nhưng $T = 20$, điểm tổng kết chỉ đạt 52; ngược lại, nếu $K = 20$ và $T = 100$, kết quả cũng chỉ dừng ở mức 68. Cả hai trường hợp này đều phản ánh sự phát triển lệch lạc và không thể giúp người chơi chạm tay tới Good Ending.

**\[Tạm chốt\]** Để mở khóa Good Ending, người chơi bắt buộc phải thỏa mãn đồng thời các điều kiện tiên quyết của cả hai nhánh, song song với việc hoàn thành các mắt xích then chốt trong mạch truyện chính. Điểm số chót vót ở một nhánh không thể khỏa lấp tình trạng kiệt quệ của tòa soạn hoặc sự thiếu hụt các sự thật nền tảng ở nhánh còn lại. Đây là tiêu chuẩn thuần túy về mặt chuyên môn và hoạt động tổ chức, hoàn toàn không đòi hỏi người chơi phải hẹn hò hay đạt mức gắn kết tối đa với tất cả các nhân vật.

Tập thể đồng đội đóng góp qua nhịp điệu phát hành đều đặn, tích lũy điểm Uy tín và duy trì cỗ máy xuất bản trơn tru; trong khi đó, Khuê ghi dấu ấn qua các phóng sự điều tra mang tính bước ngoặt thúc đẩy cốt truyện. Một tuyến bài điều tra của Khuê có thể trải dài qua nhiều kỳ báo; trò chơi không ép buộc mỗi tuần Khuê đều phải có bài mới duy trì được tỷ trọng 40% trong suốt cả học kỳ.

### 6.4. Độ thu hút khi phát hành

**\[Định hướng đã có\]** Thang đo sức hút có mức trần $100\,000$ điểm, đi kèm các danh hiệu phản hồi tương ứng.

| Khoảng điểm | Danh hiệu đề xuất | 
| ----- | ----- | 
| 0 – 49 | Chẳng ai quan tâm | 
| 50 – 499 | Chưa thu hút | 
| 500 – 4.999 | Lác đác bàn tán | 
| 5.000 – 29.999 | Được nhắc đến | 
| 30.000 – 59.999 | Được quan tâm | 
| 60.000 – 89.999 | Lan được ra ngoài trường | 
| 90.000 – 100.000 | BANGER | 

Hệ thống danh hiệu phản ánh mức độ lan tỏa xã hội của số báo. Trong khi đó, chỉ số Uy tín lại đo lường mức độ tin tưởng lâu dài mà độc giả dành cho tờ báo trường. Một bài viết giật gân xây dựng trên thông tin sai lệch có thể tạo nên cơn sốt thảo luận dữ dội nhưng sẽ phá hủy hoàn toàn Uy tín; điểm số phát hành cao ngất ngưởng không đồng nghĩa với việc các quyết định nghiệp vụ trước đó là chuẩn mực.

## 7. Nhân vật và tổ chức đội

**\[Tạm chốt\]** Quy tụ 6 nhân sự nòng cốt nhằm đảm bảo tính khả thi trong khâu sản xuất nội dung. Tên gọi và một vài nét tính cách được kế thừa từ các bản thảo trước, song đây là những phiên bản nhân vật đã được tái thiết kế hoàn toàn và cần được phê duyệt lại. Thời điểm gia nhập dưới đây là các mốc giả định phục vụ thử nghiệm, chưa phải tình tiết cố định của kịch bản.

| Nhân vật | Tuần gia nhập thử | Sở trường chuyên môn | Vị trí phân công phổ biến | 
| ----- | ----- | ----- | ----- | 
| Diệp Khuê | Tuần 1 | Phỏng vấn, Điều tra | Trưởng ban phóng viên hiện trường | 
| Lục Thanh Vân | Tuần 1 | Tổ chức, Biên tập | Trưởng ban biên tập / xuất bản (vẫn có thể đi phỏng vấn) | 
| Đoàn Bảo Long | Tuần 1 | Hiểu chuyện, Tiếp cận cộng đồng | Săn tìm nguồn tin, Phỏng vấn cơ sở, Phát hành báo | 
| Hạ Tuyết Nhi | Tuần 3 | Xử lý tài liệu, Thẩm định kiểm chứng | Nghiên cứu dữ liệu, Chấp bút chuyên sâu | 
| Tạ Như Ngọc | Tuần 5 | Nhiếp ảnh, Cảm quan góc nhìn | Tác nghiệp ảnh, Phỏng vấn, Thiết kế trình bày | 
| Ngô Thiên Ân | Tuần 7 | Phân tích logic, Đối chiếu dữ liệu | Điều tra số liệu, Thẩm định chéo | 

### Diệp Khuê — Người mang theo kỳ vọng vay mượn từ người ông

Khuê là người có óc quan sát sắc sảo và nhạy bén trong việc đặt câu hỏi, song cậu khởi đầu cuộc hành trình với tâm lý gò bó: cố gắng phục dựng lại nguyên vẹn những gì người ông từng để lại. Vòng cung phát triển (arc) chính của Khuê là học cách đưa ra những lựa chọn để xây dựng một tờ báo mà tập thể hiện tại thực sự cần, ngay cả khi nó đi chệch khỏi hình mẫu di sản trong tâm tưởng của cậu. Khuê phải tự gánh vác trách nhiệm cho các quyết định nghiệp vụ của mình, chứ không chỉ đóng vai một người bạn tốt luôn đi dọn dẹp rắc rối cá nhân cho đồng đội.

### Lục Thanh Vân — Người ở lại quá lâu trong sự cô độc

Vân là người thầm lặng gánh vác những công việc hậu trường không mấy ai để ý: rà soát từng câu chữ, tìm kiếm nhà in giá rẻ, cân đối lịch trình và làm việc với các bên giải trình. Cô mang tâm lý sợ trao quyền bởi trong quá khứ đã từng chứng kiến nhiều người hứa hẹn giúp đỡ rồi lại lặng lẽ rời đi. Vòng cung của Vân là học cách mở lòng đặt niềm tin vào người khác và tìm lại cuộc sống riêng ngoài bốn bức tường tòa soạn.

Các buổi hangout của Vân bắt đầu từ những khoảng thời gian nghỉ ngơi hiếm hoi mà cô lúng túng không biết phải dùng vào việc gì. Tuyến tình cảm đặt ra một dấu hỏi tinh tế: liệu Khuê có nhìn nhận cô như một cô gái với những cảm xúc riêng, hay chỉ xem cô như người gác đền tận tụy của câu lạc bộ?

* *Kỹ năng nghề nghiệp đề xuất:* **Chốt số báo** — Giúp điều phối tiến độ nhịp nhàng hơn, nhưng không thể biến một tập tư liệu chắp vá thành một bài báo chất lượng.

* *Kỹ năng hiệp đồng đề xuất:* **Biên tập hai chiều** — Cho phép điều chỉnh góc tiếp cận bài viết sau khi nhận phản hồi từ đội phóng viên hiện trường mà không tốn quá nhiều công sức làm lại từ đầu.

### Đoàn Bảo Long — Người giỏi chuyện thiên hạ nhưng né tránh chuyện của mình

Long sở hữu khả năng khuấy động không khí tự nhiên và có trí nhớ tuyệt vời đối với những chi tiết vụn vặt mà người khác thường bỏ quên. Cậu phải bươn chải làm thêm để đỡ đần kinh tế gia đình, vì vậy sẽ có những buổi cậu vắng mặt theo lịch trình báo trước. Mức độ gắn kết giúp Khuê thấu hiểu những giới hạn riêng của Long để học cách san sẻ công việc, thay vì tìm cách xóa bỏ hoàn toàn trách nhiệm gia đình của cậu.

* *Kỹ năng đề xuất:* **Mở lời** — Mở ra các hướng tiếp cận khéo léo đối với những nguồn tin e ngại con đường chính thức.

* *Lưu ý:* Tuyến tình bạn của Long sở hữu trọng lượng đóng góp chuyên môn tương đương với các tuyến nhân vật nữ.

### Hạ Tuyết Nhi — Người đặt niềm tin vào văn bản hơn những lời hứa

Nhi sở hữu biệt tài tìm ra những cứ liệu then chốt ở những nơi không ai ngờ tới. Cô thường lấy sự đúng - sai rạch ròi trên giấy tờ làm lớp vỏ bọc để trốn tránh những va chạm cảm xúc đời thực. Vòng cung của Nhi là nhận ra rằng thấu hiểu một con người không đơn thuần chỉ là việc kiểm tra tính logic và nhất quán trong lời nói của họ.

Những buổi hẹn hò của Nhi diễn ra bình yên tại thư viện, tiệm sách cũ hoặc chia sẻ về một đoạn văn cô tâm đắc. Tuyến tình cảm đòi hỏi cả hai phải dám thẳng thắn bộc bạch những điều không thể che giấu sau những trang tài liệu ghi chép.

* *Kỹ năng đề xuất:* **Đối chiếu chéo** — Khai mở phương thức kiểm chứng một nguồn tin thông qua các tài liệu độc lập; kỹ năng này không thể tự động bóc trần mọi lời nói dối của NPC.

### Tạ Như Ngọc — Người thấu hiểu sức mạnh kể chuyện và che đậy của hình ảnh

Ngọc sở hữu tư duy thị giác xuất sắc, nắm bắt nhanh nhạy thị hiếu đám đông, nhưng lại luôn mang nỗi sợ bị lãng quên hoặc hình tượng cá nhân không còn được yêu thích. Vòng cung của Ngọc xoay quanh việc học cách phân định ranh giới giữa một khuôn hình lung linh và một bức ảnh chân thực, biết tôn trọng sự thật.

Các buổi gặp gỡ của cô là những chuyến săn tìm góc máy độc lạ hoặc những khoảnh khắc tĩnh lặng hiếm hoi khi cô rời xa mạng xã hội. Tuyến tình cảm không đòi hỏi Khuê phải sắm vai người hùng giải cứu danh tiếng cho cô; thay vào đó, nó mở ra thời khắc cô tự tin tự đứng lên trên đôi chân mình.

* *Kỹ năng đề xuất:* **Đúng khoảnh khắc** — Thu thập được tư liệu hình ảnh mang tính quyết định khi xuất hiện đúng thời điểm; dẫu vậy bức ảnh vẫn cần được đặt vào đúng ngữ cảnh và trải qua thẩm định chéo.

### Ngô Thiên Ân — Người luôn muốn thực tế phải khớp với mô hình

Ân có khả năng phát hiện những điểm dị biệt trong các bảng biểu thống kê, nhưng lại mắc tật xấu là dễ quy chụp những ai không thể trình bày rành mạch suy nghĩ của mình thành "dữ liệu lỗi". Vòng cung tình bạn của cậu là học cách lắng nghe, biết gặng hỏi thấu đáo và chấp nhận rằng thực tế cuộc sống luôn phức tạp hơn những trang số liệu.

* *Kỹ năng đề xuất:* **Xâu chuỗi** — Tìm ra mối liên hệ ngầm giữa các hồ sơ đã thu thập; kỹ năng này không tự tạo ra chứng cứ nếu đội ngũ chưa từng tiếp cận thực địa.

### Tuyến nhân vật đối trọng và người lớn

**\[Tạm chốt\]** Phan Gia Huy giữ chức vụ Chủ tịch Hội học sinh. Cậu nắm quyền điều phối các sự kiện, phê duyệt địa điểm sinh hoạt và đại diện cho tiếng nói học sinh, song không có quyền lực tuyệt đối để đơn phương đình bản tờ báo. Ban Giám thị cùng các cơ chế hành chính của trường sẽ nắm giữ phần quyền lực chế tài còn lại.

Huy luôn khao khát kiểm soát mọi luồng thông tin viết về trường Tĩnh Tâm. Ban đầu, cậu có thể thành tâm tin rằng việc bảo vệ thành tích chính là cách tốt nhất để bảo vệ học sinh. Chỉ khi lợi ích tập thể và sự thật trần trụi nảy sinh xung đột, những quyết định cụ thể của Huy mới thực sự bộc lộ giới hạn đạo đức của cậu.

Thầy giáo cố vấn hỗ trợ câu lạc bộ giữ vững tư cách pháp lý trong trường, nhưng thầy sẽ không đứng ra dập tắt mọi cuộc khủng hoảng thay cho học sinh. Những nhân chứng từng làm việc cùng ông nội Khuê sẽ giúp cậu hiểu rõ hơn về di sản quá khứ; tuy nhiên, mọi thông tin họ cung cấp vẫn cần được kiểm chứng cẩn trọng, bởi không phải ký ức nào của thế hệ đi trước cũng đều là chân lý bất biến.

## 8. Stat, skill và phát triển nghề

**\[Đề xuất\]** Thiết lập 6 chỉ số nghiệp vụ cơ bản cho nhân vật:

| Chỉ số | Mục đích sử dụng | 
| ----- | ----- | 
| Phỏng vấn | Khai thác lời kể, dẫn dắt câu chuyện và đặt câu hỏi trọng tâm | 
| Điều tra | Quan sát thực địa, phát hiện dấu vết và định hướng tìm kiếm manh mối | 
| Ảnh | Thu thập tư liệu hình ảnh và bằng chứng thị giác | 
| Tài liệu | Tìm kiếm, đọc hiểu và đối chiếu các văn bản, số liệu lưu trữ | 
| Hiểu chuyện | Lắng nghe, thấu cảm động cơ và mở rộng tiếp cận những người dè chừng | 
| Bản lĩnh | Giữ vững tâm lý trước áp lực đe dọa, dám chất vấn những chủ đề nhạy cảm | 

Tên tiếng Anh như `Investigation` hay `Interrogate` có thể được dùng cho cấu trúc mã nguồn sau này; tuy nhiên, giao diện tiếng Việt cần thống nhất một bộ thuật ngữ chuẩn mực. Tránh tạo ra hai thanh chỉ số trùng lặp chức năng như vừa có "Phỏng vấn" vừa có "Chất vấn" (Interrogate) khi chưa phân định rành mạch ranh giới chuyên môn giữa chúng.

Chỉ số nghiệp vụ tăng tiến thông qua kinh nghiệm thực hành đúng loại tác vụ và các buổi tập huấn có tiêu tốn chi phí. Trong khi đó, Kỹ năng (Skill) mang lại những phương thức tác nghiệp mới hoặc các hiệu ứng bổ trợ có điều kiện cụ thể. *Ví dụ:* "Gặng hỏi khi đối phương né tránh", "Đối chiếu chéo hai lời khai", "Phối hợp tác nghiệp theo cặp".

**\[Đề xuất\]** Đồng đội nâng cao năng lực qua quá trình làm việc thực tế và tham gia một số buổi bồi dưỡng chuyên môn tại CLB bằng suất hỗ trợ nâng cấp. Chỉ số gắn kết (Bond) giúp tăng mức độ sẵn sàng rèn luyện, thúc đẩy tinh thần hiệp đồng hoặc kích hoạt kỹ năng đặc thù; tuyệt đối không cộng dồn cơ học mọi chỉ số sau mỗi lần tặng quà. Các kỹ năng làm nghề căn bản không đòi hỏi Khuê phải bước vào mối quan hệ hẹn hò thì nhân vật đó mới phát huy được hiệu quả.

**\[Đã chốt\]** Nâng cấp là bonus, không phải điều kiện tiên quyết để hoàn thành tốt hồ sơ. Với năng lực cơ bản, một đồng đội phù hợp vẫn có thể làm tốt nhiệm vụ được giao. Độ phù hợp với task là yếu tố quan trọng nhất; nâng cấp tăng lợi thế chứ không thay thế việc chọn đúng người. Các buổi bồi dưỡng và phụ kiện được cấp qua suất hỗ trợ CLB mô tả ở mục 10, không yêu cầu thêm một ví tiền CLB riêng.

Bản bible này chưa ấn định các thông số số học cụ thể. Bảng phân bổ chỉ số, điểm kinh nghiệm (XP) và chi phí tài nguyên cần được thiết lập sau khi đã xây dựng xong một số hồ sơ tác nghiệp thực tế, tránh việc cân bằng hệ thống dựa trên những chỉ số không bao giờ được sử dụng trong game.

## 9. Bond, hangout và dating

**\[Định hướng đã có\]** Trò chơi cung cấp các hoạt động gặp gỡ (hangout) với cả nhân vật nam và nữ; riêng các nhân vật nữ khi đạt ngưỡng gắn kết nhất định sẽ mở ra cơ hội hẹn hò. Việc mở khóa cơ hội này không đồng nghĩa với việc mối quan hệ lãng mạn sẽ tự động hình thành.

**\[Đề xuất\]** Mỗi tuyến quan hệ được cấu trúc qua 5 bước tiến triển cốt truyện chặt chẽ thay vì việc cày điểm lặp lại đơn điệu: Làm quen $\rightarrow$ Tạo dựng lòng tin $\rightarrow$ Đối diện góc khuất cá nhân $\rightarrow$ Lựa chọn mang tính bước ngoặt $\rightarrow$ Gắn kết sâu sắc. Điểm bond đóng vai trò tích lũy điều kiện cần; các phân cảnh sự kiện cá nhân cùng các điều kiện cốt truyện tương ứng mới là chìa khóa mở ra bước tiếp theo.

**\[Thử nghiệm\]** Sau khi hoàn thành bước 3 hoặc bước 4 và kích hoạt sự kiện phù hợp, nhân vật nữ có thể chủ động tỏ tình hoặc mở lời gợi ý. Người chơi có toàn quyền lựa chọn duy trì tình bạn thuần khiết hoặc bước vào mối quan hệ yêu đương. Việc từ chối lời tỏ tình hoàn toàn không gây ảnh hưởng đến việc hoàn tất tuyến phát triển chuyên môn của nhân vật.

Tuyến hẹn hò sẽ tiếp tục mở ra những buổi đi chơi và các lựa chọn tình huống mới sau khi chính thức thành đôi, chứ không khép lại ngay sau thông báo "đã trở thành người yêu". Phần thưởng nhận được bao gồm các phân cảnh tương tác độc quyền, các đoạn thoại tình cảm, kết cục quan hệ riêng biệt cùng một số kỹ năng hiệp đồng đặc thù (nhưng không mang tính bắt buộc để thắng game).

**\[Đã chốt\]** Trong phạm vi phiên bản đầu tiên, trò chơi cho phép duy trì một hoặc nhiều mối quan hệ hẹn hò chính thức tại một thời điểm. Một khi đã tới thì không có đường lui; trước quyết định chấp nhận/tỏ tình sẽ có cảnh báo rằng lựa chọn có thể không rút lại được. Nếu Khuê duy trì nhiều mối quan hệ, sẽ có những phân đoạn bị phát hiện bắt cá hai tay và hậu quả giảm bond, giảm 20–30% stats chỉ đối với các nhân vật nữ đang trong mối quan hệ tình cảm với Khuê. Các nhân vật nữ ở quan hệ bạn bè hoặc bạn thân không bị ảnh hưởng bởi hình phạt này. Mức giảm stats thể hiện tổn thương tình cảm và suy giảm khả năng tập trung làm việc, từ đó ảnh hưởng kết quả bài báo.

**\[Cần chốt\]** Thời điểm áp dụng, thời hạn ảnh hưởng, cách hồi phục và cách kết hợp với các trạng thái khác còn cần thiết kế. Chưa xác định mức giảm stats là tạm thời hay vĩnh viễn, và chưa xác định quy tắc áp dụng lại hình phạt.

Những món quà phù hợp được trao tặng trong các buổi gặp gỡ sẽ giúp đẩy nhanh tiến độ gắn kết nhưng không thể giúp người chơi nhảy cóc qua các cột mốc cốt truyện. Việc vung tiền mua quà cáp không thể mua được sự đồng thuận hẹn hò. Việc lỡ hẹn một buổi gặp cần có phản ứng tự nhiên từ nhân vật; hệ thống không trừ điểm bond vô lý chỉ vì người chơi bận rộn không gặp họ trong một ngày.

## 10. Tiền, công cụ, vật phẩm và buổi tối

**\[Đã chốt\]** Phiên bản đầu nên áp dụng cơ chế một ví tiền duy nhất của Khuê nhằm tránh sự cồng kềnh của hai hệ thống ngân sách song song khi chưa mang lại sự khác biệt về lối chơi. Ngân sách của CLB sẽ được bổ sung bởi nhà trường dựa trên kết quả của đầu báo 2 tuần 1 lần, không phải bằng tiền mặt, mà là bằng số lượng các options cho phép lựa chọn thành viên để nâng cấp stats hoặc kỹ năng bằng việc cho học khóa học/mua phụ kiện. Quyết định chi tiêu cho câu lạc bộ, cho việc học tập hay cho đời sống cá nhân là một phần trong bài toán quản lý tài nguyên của người chơi. Các nguồn lực tài trợ quy mô lớn của tổ chức sẽ được mở khóa thông qua các sự kiện cốt truyện hoặc điểm Uy tín, chứ không bắt một học sinh phải tự gom tiền mua sắm cả xưởng in ấn.

| Hoạt động buổi tối | Lợi ích thu được | Cái giá phải trả | 
| ----- | ----- | ----- | 
| Làm thêm | Thu nhập tiền bạc, đôi khi mở ra cơ hội tiếp cận nhân chứng | Tiêu tốn slot tối; có thể tích lũy độ mệt mỏi | 
| Luyện hỏi / quan sát | Tích lũy kinh nghiệm nghề nghiệp | Tiêu tốn slot tối; có thể tốn kém chi phí | 
| Ăn uống / dạo phố | Cải thiện một chỉ số cụ thể hoặc hồi phục thể lực | Tốn tiền và mất slot tối | 
| Tiếp xúc nguồn tin đêm | Thu thập tư liệu độc quyền cho hồ sơ cụ thể | Mất slot tối và chấp nhận rủi ro đã cảnh báo | 
| Thăm hỏi người thân / bạn | Gia tăng độ gắn kết hoặc kích hoạt cảnh truyện | Mất slot tối và phụ thuộc điều kiện lịch trình | 
| Nghỉ ngơi tại nhà | Hồi phục thể lực và giảm mệt mỏi tối đa | Bỏ qua cơ hội tham gia các hoạt động khác | 

Một bữa ăn ngon không thể cùng lúc mang lại tiền tài, tăng mọi chỉ số, nâng điểm gắn kết và hồi phục thể lực tuyệt đối. Mỗi công việc làm thêm đều có khung giờ cố định và mức thù lao cụ thể; game không sa đà vào việc xây dựng minigame vụn vặt cho từng cửa hiệu trong bản đầu.

**\[Đã chốt\]** Trang bị bền vững giúp mở khóa hoặc gia tăng hiệu suất cho các tác vụ tương ứng: máy ghi âm, máy ảnh cơ, đèn flash, thiết bị lưu trữ. Vật phẩm tiêu hao đóng vai trò hỗ trợ tức thời cho một công việc cụ thể: pin sạc dự phòng, thẻ nhớ phụ, đạo cụ chuẩn bị hiện trường, đồ uống hồi phục. Tuyệt đối không tồn tại bất kỳ vật phẩm nào có thể biến một thông tin chưa qua kiểm chứng thành sự thật khách quan. Giới hạn số lượng vật phẩm có thể áp dụng phải được hiển thị rõ ràng trước khi người chơi bấm xác nhận.

Việc nâng cấp cơ sở vật chất CLB bao gồm sửa sang bàn ghế làm việc, bảo trì máy in và bổ sung kho tài liệu lưu trữ. Điểm Uy tín sẽ mở ra cơ hội và điều kiện để nâng cấp; tuy nhiên, người chơi vẫn là người quyết định có chi tiền đầu tư hay không. **Tránh mặc định việc nâng cấp cơ sở vật chất luôn cộng dồn +1 vào tất cả các tác vụ** như trong bản thiết kế cũ, bởi lẽ mỗi loại công cụ chỉ có thể phát huy tác dụng trong những phần việc chuyên biệt.

Mức độ mệt mỏi được tính toán riêng cho từng nhân vật và biến động theo cường độ của các hoạt động tham gia. Việc cạn kiệt energy làm báo không cản trở Khuê tham gia các buổi đi chơi cá nhân; tuy nhiên, một ca làm thêm quá sức vào buổi tối có thể kéo tụt hiệu suất làm việc của cậu vào ngày hôm sau. Cơ chế hồi phục, trần giới hạn mệt mỏi và các ngưỡng bắt buộc nghỉ ngơi cần được tính toán mô phỏng chi tiết theo chu kỳ 84 ngày. Tránh việc đưa vào các yếu tố ốm đau ngẫu nhiên trong phiên bản đầu tiên.

## 11. Sức ép, Uy tín và hậu quả

**\[Tạm chốt\]** Chỉ số Uy tín đo lường mức độ tin cậy và vị thế vững chắc của tờ báo trong lòng công chúng. Sức lan tỏa phản ánh mức độ quan tâm của độc giả đối với ấn bản phát hành; trong khi đó, Áp lực đại diện cho sự can thiệp và cản trở đến từ các thế lực đối trọng.

Áp lực cần được định lượng bằng con số đi kèm nguyên nhân cốt truyện rõ ràng: phản ứng này bắt nguồn từ bài viết nào, ai là người đứng sau phản đối và yêu sách cụ thể của họ là gì. Những đòn giáng từ phía Phan Gia Huy có thể là việc thu hồi địa điểm tổ chức sự kiện, trì hoãn khâu cấp phép in ấn, gây sức ép buộc một nhân chứng phải giữ im lặng hoặc triệu tập một cuộc họp giải trình căng thẳng.

Những tác động này phải được vận hành thông qua các cơ chế hệ thống minh bạch mà người chơi có thể nắm bắt được. Việc bị tước quyền sử dụng máy in của trường sẽ buộc CLB phải chuyển đổi phương án in ấn bên ngoài và gánh thêm chi phí tài chính, chứ không nhất thiết phải mặc định phạt giảm 50% điểm số của kỳ báo sau trong mọi trường hợp.

Khi Vân trực tiếp xuống hiện trường tác nghiệp, năng lực điều phối chung của tòa soạn sẽ bị suy giảm tương ứng. Tuy nhiên, nếu trong đội có nhân sự đủ năng lực thay thế và tiến độ biên tập vẫn được đảm bảo đúng hạn, hệ thống không được phép áp đặt hình phạt vô lý chỉ vì người vắng mặt mang tên Vân. Dẫu vậy, những kỹ năng điều phối đặc thù của Vân vẫn sẽ khiến sự vắng mặt của cô là một sự đánh đổi có sức nặng.

Trò chơi không tự động đánh giá một bài viết là "đầy đủ bằng chứng" chỉ dựa trên mức độ gai góc hay độ lan tỏa của nó. Một hồ sơ điều tra đạt chuẩn bắt buộc phải kết nối chính xác từng nhận định với các tư liệu đã qua kiểm chứng chéo. Để khép lại mạch truyện chính một cách thắng lợi, người chơi buộc phải tháo gỡ thành công các mắt xích trọng yếu, chứ không thể chỉ cày cuốc điểm số từ các đề tài phóng sự phụ.

Trường hợp giao diện vẫn duy trì một thanh chỉ số "Bằng chứng tổng hợp", thanh điểm này chỉ đóng vai trò tóm lược tiến độ trực quan. Các hồ sơ điều tra bắt buộc và những điều kiện công bố cụ thể vẫn phải trải qua khâu thẩm định độc lập.

## 12. Khung cốt truyện ba hồi

### Hồi 1 — Căn phòng chưa đóng cửa (Tuần 1 – 3)

Khuê đặt chân đến CLB Báo chí đúng vào thời điểm Vân đang chuẩn bị cho số báo mà nhiều khả năng sẽ là số báo phát hành cuối cùng. Cậu đề xuất một giai đoạn thử thách ngắn hạn, trước mắt là để thuyết phục nhà trường không niêm phong căn phòng sinh hoạt. Đồng hành cùng họ, Long giúp cả hai tìm kiếm những đề tài đời thường gần gũi nhưng nhận được sự quan tâm chân thực từ học sinh.

Những bài viết đầu tiên tập trung vào các chủ đề thiết thực: chất lượng bữa ăn căng tin, không gian tập luyện thể thao, nội quy phòng đọc thư viện hay chân dung một nhân viên thầm lặng trong trường. Thông qua các đề tài này, nhóm từng bước chuẩn hóa quy trình làm việc và tìm lại những độc giả trung thành đầu tiên. Cùng lúc đó, một tài liệu cũ do người ông để lại hé mở một manh mối điều tra lớn nhưng dữ liệu chưa đủ để đưa ra bất kỳ kết luận nào.

Cột mốc khép lại Hồi 1: Một số báo tạo nên tiếng vang lớn khiến toàn trường bàn tán; Phan Gia Huy xuất hiện và yêu cầu CLB phải chịu trách nhiệm giải trình về một nội dung nhạy cảm. Khuê buộc phải chứng minh bản lĩnh và phương pháp làm báo chân chính của mình, thay vì chỉ biết núp sau cái bóng danh tiếng của người ông. Ngay sau đó, Nhi bước vào câu lạc bộ xuất phát từ một dữ liệu cần được đối chứng chuyên môn.

### Hồi 2 — Tờ báo bắt đầu có tiếng nói (Tuần 4 – 7)

Uy tín gia tăng khiến số lượng đề tài gửi về vượt quá khả năng xử lý của câu lạc bộ. Ngọc và Ân lần lượt gia nhập thông qua những vụ việc tác nghiệp cụ thể. Việc tổ chức đội ngũ bài bản và thiết lập quy trình xuất bản quy củ trở thành yêu cầu sống còn. Mối quan hệ cá nhân giữa các thành viên bắt đầu chi phối cách họ mở lời nhờ cậy, chia sẻ tâm tư và phối hợp làm việc chung.

Trọng tâm điều tra của mạch chính: Các khoản chi tiêu tài chính mờ ám, những sự kiện phô trương thành tích và tập hồ sơ chuẩn bị cho đợt thẩm định chất lượng có nhiều điểm sai lệch so với thực tế đời sống học sinh. Những người trong cuộc không phải ai cũng sẵn sàng xuất hiện trên mặt báo; một số nhân chứng lo sợ hậu quả bị trả thù, trong khi một vài nguồn tin khác lại toan tính lợi dụng tờ báo để phục vụ mưu đồ cá nhân.

Cột mốc khép lại Hồi 2 **\[Tạm chốt\]**: Một phóng sự điều tra quan trọng đẩy toàn bộ CLB rơi vào một cuộc khủng hoảng nghiêm trọng. Nguyên nhân có thể bắt nguồn từ việc thiếu hụt chứng cứ xác thực, mất quyền tiếp cận hiện trường hoặc do nhà trường gia tăng sức ép trừng phạt. Nguồn gốc của cuộc khủng hoảng phải bắt nguồn từ chính những hành động trước đó của người chơi. Trò chơi không được ép Khuê phải phạm phải một sai lầm kịch bản cố định hay áp đặt sự im lặng nhằm xóa sạch mọi nỗ lực và lựa chọn tự do của người chơi.

### Hồi 3 — Tự chọn tờ báo mình muốn giữ (Tuần 8 – 12)

Cả đội phối hợp xâu chuỗi toàn bộ các mảnh ghép hồ sơ rải rác, tìm kiếm phương án công bố sự thật khả thi nhất đồng thời thiết lập lá chắn bảo vệ an toàn cho các nguồn tin. Trong giai đoạn này, Khuê bàng hoàng nhận ra di sản của người ông không hề hoàn hảo như cậu hằng tưởng tượng; một góc khuất trong quá khứ dường như đã bị che đậy hoặc không được kể lại trọn vẹn. Cậu đứng trước bài toán phải đưa ra quyết định dựa trên thực tại của chính mình, thay vì mù quáng bảo vệ danh tiếng quá khứ.

Các nhánh quan hệ cá nhân sẽ bước vào những phân cảnh lựa chọn then chốt trước khi cao trào diễn ra; trò chơi không dồn ép toàn bộ các cuộc hẹn hò vào tuần lễ cuối cùng. Mỗi nhân vật đều sở hữu lý do và lý tưởng riêng để bám trụ và cống hiến cho CLB, ngay cả khi họ không bước vào mối quan hệ tình cảm với Khuê.

Tuần 12 thiết lập một thời hạn chót mang tính sống còn để công bố phóng sự hoặc tham gia buổi điều trần quyết định. Phản ứng cuối cùng từ các bên liên quan sẽ được tính toán trực tiếp vào kết cục; tuyệt đối không tạo ra các điều kiện đình bản vô lý cho một "tuần 13" không hề tồn tại. Phân đoạn vĩ thanh (epilogue) sẽ khắc họa rõ nét tương lai của các thành viên, số phận của căn phòng sinh hoạt, cuộc sống của những người trong cuộc và cái kết cho những mối quan hệ cá nhân.

## 13. Một hồ sơ mẫu

**\[Đề xuất\]** "Căng tin tăng giá, khẩu phần giảm" — Một đề tài đời thường đóng vai trò cầu nối dẫn dắt vào những vấn đề thể chế lớn hơn. Bảng mô tả dưới đây là ví dụ minh họa cho một sub quest do chính Khuê trực tiếp thụ lý. Đối với các hồ sơ do đồng đội đảm nhiệm, các bước tác nghiệp nội bộ cũng diễn ra tương tự nhưng sẽ do nhân sự đó tự động triển khai và tóm tắt lại qua bản tin feedback, không yêu cầu người chơi phải phân công chi li từng dòng trong bảng.

| Các bước tác nghiệp | Thao tác và nhận thức của người chơi | Hệ quả nghiệp vụ thu nhận | 
| ----- | ----- | ----- | 
| Xem sơ lược | Lắng nghe học sinh than phiền; ghi nhận bảng niêm yết giá vừa thay đổi | Nắm bắt hiện tượng nhưng chưa rõ trách nhiệm thuộc về ai | 
| Phỏng vấn thực địa | Lắng nghe ý kiến từ phía học sinh và người trực tiếp bán hàng | Thu được hai luồng quan điểm đối lập nhưng chưa đủ dữ liệu đối chiếu | 
| Tác nghiệp ảnh | Chụp lại khẩu phần ăn thực tế và đối chiếu với bảng giá mới | Sở hữu tư liệu thị giác thực tế; chưa chứng minh được biến động chi phí | 
| Khai thác nhân viên | Tiếp cận khéo léo một nhân viên để tìm hiểu về việc đổi đơn vị cung ứng | Hé mở manh mối để truy tìm tài liệu hợp đồng nội bộ | 
| Tra cứu lưu trữ | Nghiên cứu các thông báo đấu thầu và hóa đơn được phép tiếp cận | Đánh giá tính trung thực của các thông cáo giải trình chính thức | 
| Chất vấn chính thức | Đặt câu hỏi trực tiếp với người phụ trách quản lý căng tin | Thu thập phản hồi chính thức hoặc ghi nhận thái độ từ chối trả lời | 
| Chấp bút & Biên tập | Lựa chọn những dữ liệu có đầy đủ bằng chứng kiểm chứng để công bố | Định hình góc tiếp cận và quyết định mức độ công khai danh tính | 

Hồ sơ này có thể dẫn tới ba sản phẩm báo chí đầu ra khác nhau: một bản tin vắn về biểu giá mới; một bài viết phản ánh tâm tư của học sinh về khẩu phần ăn; hoặc một phóng sự điều tra chuyên sâu về quy trình chỉ định thầu đơn vị cung ứng. Mức độ thu hút, độ khó tác nghiệp và rủi ro đi kèm sẽ tương ứng với chiều sâu thông tin thu thập được. Trò chơi không ép buộc mọi đề tài học đường đều phải biến thành một đại án tham nhũng chấn động.

*Mô phỏng một ngày tác nghiệp thực tế:* Khuê dành khung giờ CLB để thu thập thông tin cho sub quest căng tin; cùng lúc đó, Long tiếp tục bám sát hồ sơ sân bóng đã nhận từ trước, còn Vân tập trung biên tập một bài viết đã thu thập đủ tư liệu. Đến khung giờ cá nhân buổi chiều, Khuê chọn gặp gỡ Nhi; tối đến, cậu quyết định đi làm thêm kiếm tiền mua một chiếc máy ghi âm chuyên dụng thay vì dành thời gian luyện tập kỹ năng phỏng vấn. Chiếc máy ghi âm này sẽ tối ưu hóa hiệu suất cho các tác vụ tác nghiệp phù hợp sau này, chứ không tự động cộng dồn điểm số cho mọi bài viết ngay khi vừa mua sắm.

## 14. Kết thúc

**\[Đề xuất\]** Kết cục chung cuộc của trò chơi là sự kết tinh từ ba trụ cột thành quả: Năng lực vận hành tòa soạn, Chiều sâu các vụ điều tra và Mạng lưới quan hệ cá nhân.

**\[Định hướng đã có\]** Để chạm tay tới Good Ending, người chơi bắt buộc phải kết hợp nhịp nhàng giữa năng lực của Khuê và sức mạnh của tập thể đồng đội. Việc bỏ mặc đồng đội hoặc liên tục giao việc sai sở trường sẽ dẫn đến những bài viết kém chất lượng, số báo phát hành thảm hại và đẩy tòa soạn vào cảnh suy sụp; những bài viết xuất sắc của riêng cá nhân Khuê không thể gồng gánh thay cho cả một guồng máy rệu rã. Ngược lại, việc quản lý đồng đội mẫu mực nhưng lại xao nhãng mạch điều tra chính của Khuê cũng sẽ khiến trò chơi không thể đạt tới một kết cục trọn vẹn.

* **Tờ báo sống tiếp (Good Ending):** Bộ máy tòa soạn đủ năng lực tự vận hành vững vàng; các sự thật trọng yếu được phơi bày dựa trên những luận cứ đanh thép; CLB Báo chí bảo vệ thành công tiếng nói tự do của mình.

* **Cái giá của sự thật:** Cuộc điều tra đi đến thắng lợi trọn vẹn nhưng tòa soạn bị triệt hạ nguồn lực hoặc buộc phải dời khỏi khuôn viên trường; mạng lưới quan hệ cá nhân sẽ quyết định những ai sẽ tiếp tục kề vai sát cánh cùng Khuê trên chặng đường mới.

* **Tờ báo được phép tồn tại:** CLB giữ lại được căn phòng nhưng phải chấp nhận những thỏa hiệp và giới hạn kiểm duyệt ngặt nghèo; người chơi nhìn thấy rõ những điều mình đã nỗ lực làm được và những sự thật buộc phải bỏ qua.

* **Căn phòng khép lại:** Câu lạc bộ chính thức bị giải thể do không vượt qua được kỳ thẩm định. Tuy vậy, một số thành quả cá nhân và hồ sơ điều tra vẫn được lưu giữ; trò chơi không phủ nhận toàn bộ những nỗ lực mà người chơi đã cống hiến suốt học kỳ.

Mỗi nhân vật nữ đều sở hữu một đoạn kết vĩ thanh tương ứng theo nhánh tình bạn hoặc tình yêu lãng mạn. Tuyến nhân vật nam cũng sở hữu những kết cục phát triển cá nhân riêng biệt. Trò chơi chưa đề xuất các nhánh ẩn (secret route) ép buộc người chơi phải cày cuốc nhiều lần; ưu tiên hàng đầu là hoàn thiện một cấu trúc học kỳ 12 tuần với trải nghiệm trọn vẹn và mạch lạc ngay từ lần chơi đầu tiên.

## 15. Phạm vi kiểm chứng tiếp theo

**\[Đề xuất\]** Xây dựng một bản chơi thử nghiệm cắt dọc (vertical slice) kéo dài trong 2 tuần lễ trước khi bước vào sản xuất toàn diện nội dung cho 12 tuần của học kỳ:

* Mở khóa 3 nhân sự khởi đầu và đưa vào thử nghiệm thêm 1 nhân sự mới nhằm kiểm tra tính hiệu quả của cơ chế phân công.

* Triển khai đồng thời 1 hồ sơ phỏng vấn chuyên sâu, 1 hồ sơ khảo sát phi nhân vật và 1 bản tin vắn.

* Vận hành quy trình giao trọn gói hồ sơ, nhận bản tin feedback sau ngày đầu và đánh giá kết quả sau vài ngày; thử nghiệm song song cả hai kịch bản phân công tối ưu và phân công sai sở trường.

* Kiểm chứng duyệt feedback không tốn energy khi quỹ đã cạn; nhấn giường phải yêu cầu xử lý tin nhắn còn tồn trước khi chuyển ngày. Kiểm chứng hồ sơ và hàng đợi biên tập của đồng đội dừng cuối tuần, tiếp tục vào thứ Hai; chưa kích hoạt ngoại lệ skill làm việc cuối tuần.

* Triển khai 1 nhiệm vụ chính hoặc nhiệm vụ phụ do Khuê trực tiếp điều tra, áp dụng hệ số điểm bài viết xấp xỉ $1{,}5$.

* Đội ngũ biên tập tiến hành tiếp nhận hàng đợi bài viết và tổ chức xuất bản mà không phát sinh tình trạng quản lý vi mô từng thao tác.

* Chạy thử chu trình sinh hoạt: Sáng lên lớp / Chiều CLB / Chiều cá nhân / Buổi tối, kèm theo 1 ngày cuối tuần hoàn chỉnh và áp lực từ hạn chót xuất bản.

* Thiết kế 1 buổi hangout mở khóa kỹ năng, 1 cơ hội hẹn hò có quyền từ chối và 1 tình huống tặng quà.

* Trải nghiệm 1 ca làm thêm buổi tối, 1 buổi rèn luyện chỉ số, kiểm tra hiệu quả của 1 công cụ chuyên dụng và 1 vật phẩm tiêu hao.

* Đưa vào 1 tình huống gây sức ép từ bên ngoài với nguyên nhân rõ ràng và cung cấp các phương án ứng phó khác nhau.

Mục tiêu kiểm chứng tập trung vào việc đo lường: tổng khối lượng công việc, lượng energy dư thừa, tốc độ xử lý hồ sơ, sự chênh lệch hiệu quả giữa việc có hoặc không thăm dò đối tượng từ trước, tính khả thi khi điều động Vân rời tòa soạn đi tác nghiệp thực địa và mức độ hy sinh quỹ thời gian cá nhân. Tuyệt đối không đánh giá độ cân bằng của toàn bộ tựa game chỉ bằng việc sử dụng bot tự động chạy riêng phần làm báo.

Tiến hành kiểm chứng đối sánh giữa 3 phong cách chơi điển hình: người chơi chỉ tập trung vào Khuê, người chơi chỉ dựa dẫm vào đồng đội, và người chơi phối hợp hài hòa cả hai luồng tác nghiệp. Sử dụng tỷ trọng chuẩn hóa 40/60 cùng các điều kiện tiên quyết độc lập để kiểm định cơ chế mở khóa Good Ending, thay vì chỉ căn cứ vào tổng điểm phát hành cơ học. Hệ số phân bổ giữa các vị trí bài viết trong một số báo không chứng minh tỷ lệ đóng góp toàn game 40/60 của hai luồng tác nghiệp.

## 16. Những quyết định cần chốt

 1. Ông nội là giáo viên cố vấn đã chốt ở mục 2. Còn cần thống nhất tên gọi chính thức của Tập san (hiện tạm gọi Hồi Âm) và các chi tiết lịch sử của tờ báo trong quá khứ.

 2. Quy mô 12 tuần hiện tạm chốt, cuối tuần đã có trong vòng chơi; cần kiểm chứng dung lượng nội dung và quy tắc mock energy ngoài giờ trước khi chốt thông số.

 3. Cân bằng chi phí năng lượng khởi động và can thiệp hồ sơ, số lượng hồ sơ tối đa mỗi người có thể phụ trách cùng lúc và định mức công suất của tổ biên tập.

 4. Thống nhất nhịp độ xuất bản hàng tuần, số lượng vị trí bài viết trên mỗi số báo và tải trọng công việc của chuỗi tác vụ: Viết – Biên tập – In ấn phát hành.

 5. Duyệt danh sách 6 nhân sự đề xuất, thời điểm gia nhập của từng người, lựa chọn 3 tuyến nhân vật nữ có thể hẹn hò và phạm vi phát triển của tuyến dating.

 6. Cơ chế nhiều mối quan hệ và quyết định tình cảm không thể rút lại đã chốt. Cần thiết kế điều kiện phát hiện, mức giảm bond, chọn mức giảm stats trong khoảng 20–30%, thời hạn ảnh hưởng và cách hồi phục cho các nhân vật nữ đang hẹn hò với Khuê.

 7. Chuẩn hóa hình thức nâng cấp chỉ số và kỹ năng, định vị vai trò cụ thể của các buổi hangout và xác định phần thưởng cơ chế thu được từ nhánh tình cảm.

 8. Một ví tiền cá nhân và suất hỗ trợ nâng cấp CLB mỗi hai tuần đã chốt. Cần xác định số suất, tiêu chí cấp và danh mục nâng cấp; bảo đảm nhân sự có năng lực cơ bản phù hợp vẫn làm tốt mà không bắt buộc nâng cấp.

 9. Hoàn thiện kịch bản điều tra ở giai đoạn cao trào cuối kỳ, quyền lực pháp lý thực tế của Phan Gia Huy và Ban Giám thị, cùng các mắt xích chứng cứ bắt buộc phải thu thập.

10. Thống nhất phương án điều chỉnh mức độ nhạy cảm: lựa chọn theo từng mảnh nội dung cụ thể hay tiếp tục sử dụng thanh trượt "Độ gai góc".

11. Xác lập phương pháp chuẩn hóa toán học cho hai biến số $K$ và $T$ cùng các ngưỡng điều kiện riêng biệt để hiện thực hóa tỷ trọng đóng góp 40/60; làm rõ cách thức hệ số bài viết $1{,}5$ của Khuê tương tác với mức trần $100\,000$ điểm phát hành.

Các công thức tính điểm cụ thể, nhịp độ tích lũy mệt mỏi, mức thù lao làm thêm, biểu điểm kinh nghiệm (XP), giá cả quà tặng, số lượng đề tài xuất hiện mỗi tuần cùng các ngưỡng kích hoạt kết cục sẽ chỉ được chốt chính thức sau khi bản chơi thử nghiệm cắt dọc hoàn tất việc kiểm chứng hài hòa cả khâu tác nghiệp báo chí lẫn đời sống cá nhân của nhân vật.
