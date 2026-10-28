# BÁO CÁO THẨM ĐỊNH KỊCH BẢN & TIÊU CHUẨN BIÊN TẬP NỘI DUNG MỞ ĐẦU
## DỰ ÁN HỒI ÂM (CLB BÁO CHÍ TĨNH TÂM)

* **Vị trí thực hiện:** Editor / Script Editor (Trưởng ban Biên tập Kịch bản)
* **Người nhận báo cáo:** Project Lead / Narrative Director
* **Phiên bản tài liệu:** v1.0 (Master Editorial Audit & Standardized Opening Script)
* **Ngày hoàn thành:** 2026-10-12
* **Tài liệu căn cứ:** `docs/history/narrative/game_story_bible.md` (Story Bible v1.0), `docs/engineering/ARCHITECTURE.md`, `AGENTS.md`.

---

## 1. TỔNG QUAN THẨM ĐỊNH (EXECUTIVE SUMMARY)

Là Script Editor của dự án, tôi đã tiến hành rà soát đối chiếu toàn diện giữa **Story Bible v1.0** với toàn bộ hệ thống tài liệu tiền nhiệm (`Draft.md`, `GDD-Attack.md`, `GDD-Defense.md`, `BIBLE-CLB-BAO-CHI-PROPOSAL.md`), cấu trúc mã nguồn hiện hành và quy chuẩn tác nghiệp nghiêm ngặt tại `AGENTS.md`.

### Đánh giá chung:
Nội dung mở đầu (Prologue và Ngày 1 của Tuần 1 - Hồi 1) giữ vai trò "cánh cửa sinh tử" quyết định toàn bộ trải nghiệm người chơi:
1. **Thiết lập lời hứa cốt lõi (Core Promise):** Chuyển dịch từ một góc phòng hoang tàn, rệu rã sang một tòa soạn học đường đầy sức sống, nơi sự thật được tìm kiếm bằng lòng trắc ẩn chứ không phải sự thù hận.
2. **Khởi tạo mâu thuẫn trung tâm (Central Conflict):** Cuộc đối đầu giữa khát vọng cất lên tiếng nói chân thật của học sinh với bộ máy kiểm soát thông tin bưng bít của nhà trường phục vụ Kỳ kiểm định chất lượng 5 năm và quyền lợi của Tập đoàn Hải Vọng Corp.
3. **Định hình nhịp điệu sinh hoạt (Core Game Loop):** Vận hành tự nhiên chu kỳ 4 khung giờ: Sáng (Học chính khóa) $\rightarrow$ Chiều Tòa soạn (Quản lý CLB) $\rightarrow$ Chiều Cá nhân (Hangout/Lắng nghe) $\rightarrow$ Tối (Đời sống phố cảng Hải Vọng).

---

## 2. BÁO CÁO THẨM ĐỊNH TÍNH NHẤT QUÁN VỚI STORY BIBLE v1.0

Tôi đã kiểm tra và chuẩn hóa 5 trụ cột Lore cốt lõi, loại bỏ hoàn toàn các dị bản cũ:

| Trụ cột Lore | Trạng thái thẩm định | Diễn giải chuẩn mực theo Story Bible v1.0 |
| :--- | :---: | :--- |
| **Sự cố năm 2011** | **CHUẨN HÓA** | 15 năm trước (2011), vụ sập giàn giáo trong quá trình thi công Nhà Tập luyện Thể chất cũ khiến 2 công nhân bị thương nặng và 1 học sinh trực nhật suýt mất mạng. Hồ sơ phóng sự của Thầy Diệp về việc rút ruột công trình của nhà thầu sân sau liên kết lãnh đạo trường bị tịch thu thô bạo. |
| **Thầy Diệp Văn Trí** | **CHUẨN HÓA** | Cựu giáo viên môn Ngữ văn kiêm Giáo viên Cố vấn sáng lập CLB Báo chí & tập san Hồi Âm 15 năm trước. Đã loại bỏ triệt để dị bản cũ phân vân ông là học sinh. Ba di vật trao lại: Máy ghi âm Sony cassette cổ, Sổ tay tác nghiệp bìa da ố vàng, Thẻ hội viên danh dự số 001. Di ngôn: *"Báo chí là công cụ thức tỉnh, không phải công cụ trừng phạt"*. |
| **Hải Vọng Corp** | **CHUẨN HÓA** | Tập đoàn kinh tế lớn nhất Hải Vọng, chủ đầu tư khu đô thị mới ven biển, công ty mẹ của nhà thầu xây dựng năm 2011 và là đơn vị tài trợ gói nâng cấp hàng chục tỷ đồng cho trường Tĩnh Tâm. |
| **THPT Tĩnh Tâm** | **CHUẨN HÓA** | Trường cấp ba công lập trọng điểm trên đồi nhìn ra vịnh biển Hải Vọng. Loại bỏ hoàn toàn tên trường nhầm lẫn trong các bản thảo cũ ("Chu Văn An"). |
| **Kỳ kiểm định 5 năm** | **CHUẨN HÓA** | Kỳ thẩm định Kiểm định chất lượng giáo dục toàn diện 5 năm/lần của Sở Giáo dục và Hội đồng Thẩm định Thành phố. Ban Giám hiệu muốn đạt chuẩn "Trường Chất lượng cao Trọng điểm Quốc tế", tạo áp lực bưng bít thông tin lên Ban Giám thị (Thầy Giám thị Trần) và Hội học sinh (Phan Gia Huy). |
| **Căn phòng số 3 & Hạn 7 ngày** | **CHUẨN HÓA** | Phòng sinh hoạt CLB cuối dãy nhà C cổ kính. CLB ngừng xuất bản 6 tháng, Thầy Giám thị Trần ra tối hậu thư thu hồi phòng trong 7 ngày làm kho chứa đồ. Lục Thanh Vân là người duy nhất bám trụ. Khuê xuất hiện nhận trách nhiệm, cam kết ra số báo mới vào chiều thứ Sáu. |

---

## 3. BẮT LỖI LOGIC & XỬ LÝ MÂU THUẪN (CONTRADICTION & LOGIC BUG CATCHING)

Trong quá trình thẩm định các bản thảo trước đây, tôi phát hiện 5 lỗi logic/mâu thuẫn nghiêm trọng và đã đưa ra giải pháp xử lý triệt để:

### Lỗi 1: Động cơ nhân vật chính bị hiểu nhầm thành "Báo thù cá nhân"
* **Lỗi phát hiện:** Bản nháp cũ có xu hướng miêu tả Khuê như một "thám tử tư học đường" chuyển trường để trả thù cho sự nghiệp bị dập tắt của người ông, dễ đẩy nhân vật vào sự hằn học, cay cú.
* **Biên tập chuẩn hóa:** Bám sát tuyệt đối di ngôn của Thầy Diệp Văn Trí: *"Đừng đến Tĩnh Tâm với sự căm phẫn hay ảo tưởng về việc phục thù cho ông... Hãy làm điều đó vì những đứa trẻ đang bị lãng quên trong ngôi trường ấy."* Khuê đến trường với tâm thế của một người quan sát lắng nghe, kiếm tìm sự thật để thấu cảm và thức tỉnh lương tri.

### Lỗi 2: Thẩm quyền hành chính bị gán sai cho Hội học sinh
* **Lỗi phát hiện:** Một số đoạn nháp mô tả Phan Gia Huy (Chủ tịch Hội học sinh) có quyền tịch thu phòng hoặc ra lệnh đuổi học thành viên CLB.
* **Biên tập chuẩn hóa:** Học sinh cấp ba không thể có quyền lực hành chính tối cao như vậy. Thẩm quyền pháp lý và kỷ luật được trả về đúng cho **Thầy Giám thị Trần** và Hội đồng Kỷ luật nhà trường. Phan Gia Huy chỉ đóng vai trò là "cánh tay mặt" định hướng dư luận, đại diện cho triết lý "bảo vệ trật tự bằng sự che đậy", tạo sức ép chính trị mềm.

### Lỗi 3: Mâu thuẫn giữa thời hạn 7 ngày và nhịp phát hành tuần
* **Lỗi phát hiện:** Tối hậu thư ghi 7 ngày nhưng gameplay quy định phát hành báo vào chiều thứ Sáu.
* **Biên tập chuẩn hóa:** Ngày 1 của học kỳ bắt đầu vào sáng Thứ Hai. Chiều thứ Sáu (Ngày 5) là hạn chót nộp bản in duyệt phát hành (chiếm trọn 5 ngày đi học chính khóa). Hai ngày cuối tuần (Thứ Bảy, Chủ Nhật) là thời gian số báo lan tỏa và nhà trường đánh giá kết quả, khép lại trọn vẹn chu kỳ 7 ngày lịch. Logic cốt truyện và logic cơ chế ăn khớp 100%.

### Lỗi 4: Quá tải thông tin (Exposition Dump) về Đại án 2011 trong Ngày 1
* **Lỗi phát hiện:** Bản thảo cũ có xu hướng để nhân vật nói hết mọi bí mật của Hải Vọng Corp và vụ sập giàn giáo ngay trong buổi chiều đầu tiên, làm triệt tiêu cảm giác tò mò và biến phân cảnh thành bài giảng giải thích dài dòng.
* **Biên tập chuẩn hóa:** Màn mở đầu chỉ hé lộ "manh mối cấp 1" (chiếc tủ sắt gỉ sét của Thầy Diệp được mở khóa, tập hồ sơ cũ có tiêu đề vụ tai nạn 2011 và cuộn băng cassette dang dở). Đề tài thực tế cần giải quyết trong Tuần 1 là đề tài vừa sức học sinh: **Suất cơm căng tin tăng giá, phần ăn teo tóp** (Side Case A của Long) và **Căn phòng số 3** (Main Case của Khuê).

### Lỗi 5: Độc quyền hóa nhân sự (Role Exclusivity Trap)
* **Lỗi phát hiện:** Quy định cứng nhắc chỉ có Vân mới được viết, chỉ có Long mới được hỏi.
* **Biên tập chuẩn hóa:** Tôn trọng Trụ cột thiết kế số 4 của Story Bible: Sở trường là đòn bẩy hiệu suất chứ không phải rào cản độc quyền. Vân làm Lead Biên tập nhưng vẫn có thể đi phỏng vấn thực địa khi cần; Khuê là Lead Phóng viên nhưng vẫn có thể cùng Vân dọn dẹp và tổ chức trang báo.

---

## 4. KIỂM SOÁT NHỊP ĐIỆU (PACING CONTROL)

Nhịp điệu mở đầu được thiết kế theo mô hình **Đợt sóng cảm xúc (Emotional Wave)**, tuyệt đối tránh hai thái cực: vội vã lao vào đại án (rushing) hoặc lê thê giải thích luật chơi (dragging).

```
[Sáng Ngày 1]               [Chiều CLB Ngày 1]            [Chiều Cá nhân]         [Tối Ngày 1]
Cổng trường & Áp lực ──────► Xung đột & Tối hậu thư ──────► Trà tắc & Lắng nghe ─► Quán ốc & Di vật
(Thiết lập bối cảnh)         (Cao trào kích hoạt)          (Giãn nhịp / Đồng cảm)  (Mở rộng thế giới)
```

1. **Buổi Sáng (8:00 – 12:00) — Tiếng gọi của biển và Cánh cổng khép chặt:**
   * Mở đầu bằng chuyến xe buýt ven vịnh Hải Vọng: gợi mở không gian duyên hải và 3 di vật của người ông.
   * Chạm mặt Thầy Giám thị Trần tại cổng trường: cảm nhận ngay không khí ngột ngạt của Kỳ kiểm định 5 năm.
2. **Buổi Chiều — Tòa soạn (13:30 – 15:30) — Căn phòng chưa đóng cửa:**
   * Bước vào Căn phòng số 3: cảm giác hoang phế, bụi bặm.
   * Gặp Lục Thanh Vân và đối mặt với tối hậu thư thu hồi phòng của Thầy Trần.
   * Khoảnh khắc quyết định: Khuê chìa thẻ hội viên của ông, cam kết ra số báo trong 7 ngày, mở khóa chiếc tủ sắt 2011.
3. **Buổi Chiều — Cá nhân (16:00 – 18:00) — Ly trà tắc lúc 17:30:**
   * Điểm dừng cảm xúc (Emotional Breather): Sau va chạm nảy lửa là sự tĩnh lặng dịu dàng.
   * Khuê phụ Vân dọn dẹp phòng, chia nhau ly trà tắc tan đá, thấu hiểu nỗi sợ bị bỏ rơi của Vân (khởi động tuyến quan hệ Rank 1).
4. **Buổi Tối (19:00 – 22:30) — Hương vị phố cảng và Cuộn băng lịch sử:**
   * Không khí đời thường ấm áp tại quán ốc vỉa hè của mẹ Long bên bến cá.
   * Long mang đến nguồn tin nóng hổi đầu tiên về Căng tin trường.
   * Trở về phòng trọ đêm: tiếng sóng biển, ánh hải đăng quét qua cửa sổ, bật cuộn băng cassette của Thầy Diệp. Kết thúc Ngày 1 đầy dư âm và thôi thúc bước vào Ngày 2.

---

## 5. TIÊU CHUẨN GIỌNG VĂN THUẦN VIỆT & BÁO CHÍ DUYÊN HẢI (STYLE GUIDE)

### 5.1. Màu sắc duyên hải miền Trung (Coastal Atmosphere)
* Tận dụng tối đa chất liệu giác quan: vị mặn của gió biển rát nhẹ nơi khóe môi, ánh nắng gắt trên đồi cát, mùi ốc xào me thơm nồng, tiếng còi tàu cá cập bến sớm, ngọn hải đăng quét nhịp nhàng trong đêm.
* Phương tiện và sinh hoạt mang đậm nét học trò miền biển: chiếc xe cup 50cc cà tàng, quán trà tắc chân dốc trường, cuốn sổ tay bìa da ố vàng, những bậc thang đá rêu phong nhìn xuống vịnh.

### 5.2. Sự trong sáng của ngôn ngữ học đường thuần Việt
* **CẤM:** Không dùng các từ ngữ lạm dụng convert hoặc phong cách light novel/anime cường điệu (như "senpai", "chủ tịch hắc ám", "đại nhân", "crash out", "dìm hàng", "buff bẩn").
* **CHUẨN:** Sử dụng hệ thống danh xưng học đường Việt Nam tự nhiên, đúng mực:
  * Học sinh xưng hô với thầy cô: *"Dạ thưa thầy/cô", "Em xin phép..."*
  * Học sinh cùng trang lứa: *"Cậu – mình"* (lịch sự, thân thiết giữa Khuê và Vân/Nhi); *"Mày – tao"* (tự nhiên, bộc trực kiểu anh em đường phố giữa Long và Khuê).
  * Chức danh chính thức: *"Ban Giám thị", "Hội trưởng Hội học sinh", "Trưởng ban Phóng viên", "Trưởng ban Biên tập", "Giáo viên Cố vấn"*.

### 5.3. Tinh thần báo chí chân chính (Journalistic Integrity)
* Lời thoại và văn bản phản ánh rõ nghiệp vụ báo chí thực thụ: không quy chụp cảm tính, luôn đòi hỏi chứng cứ, nhân chứng, phản hồi đa chiều và phương án bảo vệ nguồn tin.
* Sử dụng chính xác thuật ngữ chuyên môn: *"tập san", "số báo", "tòa soạn", "nguồn tin cơ sở", "kiểm chứng chéo", "chế bản in", "bản thảo", "phản hồi chính thức"*.

---

## 6. KỊCH BẢN PHÂN CẢNH MỞ ĐẦU CHUẨN MỰC (MASTER OPENING SCRIPT)

Dưới đây là 8 phân cảnh hoàn chỉnh cấu trúc Scene Graph, sẵn sàng tương thích với runtime engine:

### Phân cảnh 1: Chuyến xe buýt đến Hải Vọng (`prologue_bus_arrival`)
* **Bối cảnh:** Xe buýt đường dài uốn lượn ven đèo nhìn xuống vịnh Hải Vọng rực nắng.
* **Nhân vật:** Diệp Khuê (`khue`).
* **Cấu trúc thoại:**
  * `start` [khue · serious]: Mùi gió biển mằn mặn ùa qua khe cửa kính xe buýt. Vịnh Hải Vọng hiện ra dưới chân đèo, xanh ngắt và lấp lánh dưới nắng sớm. $\rightarrow$ `relics`
  * `relics` [khue · investigate]: Trong ba lô, ba di vật của ông nội vẫn nằm ngay ngắn: chiếc máy ghi âm cassette Sony cũ, cuốn sổ tay tác nghiệp sờn gáy, và tấm thẻ hội viên số 001 của CLB Báo chí Tĩnh Tâm. $\rightarrow$ `memory`
  * `memory` [khue · neutral]: Lời trăn trối của Thầy Diệp Văn Trí như vẫn còn văng vẳng: “Báo chí không phải là công cụ trừng phạt hay phục thù. Hãy làm điều đó vì những đứa trẻ đang bị lãng quên trong ngôi trường ấy.” $\rightarrow$ `determination`
  * `determination` [khue · lead_found]: THPT Tĩnh Tâm... Cháu đã đến rồi đây, thưa ông. *(Hết phân cảnh)*

### Phân cảnh 2: Cổng trường THPT Tĩnh Tâm (`prologue_school_gate`)
* **Bối cảnh:** Cổng trường cấp ba Tĩnh Tâm trên đỉnh đồi, băng rôn đỏ rực về Kỳ kiểm định 5 năm.
* **Nhân vật:** Thầy Giám thị Trần (`teacher`), Diệp Khuê (`khue`).
* **Cấu trúc thoại:**
  * `start` [teacher · neutral]: Đứng lại! Em kia, học sinh mới chuyển trường đúng không? Sao giờ này còn đứng ngơ ngác ở cổng? $\rightarrow$ `inspection`
  * `inspection` [teacher · neutral]: Nhìn tấm băng rôn trên đầu kia đi: Kỳ kiểm định chất lượng 5 năm toàn diện đang bắt đầu. Toàn trường đang dốc sức để đạt chuẩn quốc tế và đón gói tài trợ từ Hải Vọng Corp. $\rightarrow$ `warning`
  * `warning` [teacher · neutral]: Tuyệt đối chấp hành nội quy, không tụ tập gây mất trật tự, và đừng tò mò những chuyện không phận sự. Rõ chưa? $\rightarrow$ `decision`
  * `decision` [khue · serious]: Thầy Giám thị Trần quét ánh mắt nghiêm nghị đầy dò xét...
    * *Lựa chọn A:* Dạ vâng, em chào thầy. Em sẽ về lớp ngay ạ. $\rightarrow$ `polite`
    * *Lựa chọn B:* Thưa thầy, em nghe nói trường mình từng có CLB Báo chí Hồi Âm rất nổi tiếng...? $\rightarrow$ `inquire`
  * `polite` [khue · neutral]: Dạ thưa thầy, em hiểu rồi ạ. Em là học sinh mới, xin phép thầy vào nhận lớp. $\rightarrow$ `polite_end`
  * `polite_end` [teacher · neutral]: Tốt. Biết điều thì mới học yên ổn ở Tĩnh Tâm được. Đi nhanh lên! *(Hết)*
  * `inquire` [khue · questioning]: Thưa thầy Giám thị, em nghe nói trường mình từng có CLB Báo chí Hồi Âm nổi tiếng khắp thành phố...? $\rightarrow$ `inquire_end`
  * `inquire_end` [teacher · neutral]: Hừ! Nhắc đến cái hội đó làm gì? Một nhóm rắc rối đã chết từ lâu rồi. Đừng dại mà bén mảng đến góc dãy nhà C! *(Hết)*

### Phân cảnh 3: Căn phòng số 3 dãy nhà C (`prologue_room_number_3`)
* **Bối cảnh:** Hành lang cổ kính dãy nhà C, phòng sinh hoạt xập xệ ngập bụi và giấy nháp.
* **Nhân vật:** Diệp Khuê (`khue`), Lục Thanh Vân (`van`).
* **Cấu trúc thoại:**
  * `start` [khue · investigate]: Hành lang cuối dãy nhà C cổ kính vắng lặng như tờ. Biển đồng trước cửa đã xỉn màu: “Phòng sinh hoạt số 3 — CLB Báo chí Hồi Âm”. $\rightarrow$ `enter`
  * `enter` [khue · neutral]: Cánh cửa khẽ cọt kẹt mở. Bên trong, bụi mờ lơ lửng trong vạt nắng chiều. Hàng chồng báo cũ phủ bụi, máy in khô mực... và một cô gái đang cặm cụi gạch xóa bản thảo. $\rightarrow$ `van_notice`
  * `van_notice` [van · serious]: Ai đó? Nếu cậu đến tìm đồ thất lạc hay thu gom giấy vụn thì nhầm chỗ rồi. Ở đây không có gì cả. $\rightarrow$ `introduce`
  * `introduce` [khue · happy]: Chào cậu. Mình là Diệp Khuê, học sinh mới chuyển đến. Mình muốn đăng ký tham gia CLB Báo chí Hồi Âm. $\rightarrow$ `van_sigh`
  * `van_sigh` [van · neutral]: Tham gia sao? Cậu đến muộn cả mấy tháng rồi. CLB này... chỉ còn mỗi mình mình, và sắp bị xóa sổ đến nơi. *(Hết)*

### Phân cảnh 4: Tối hậu thư của Thầy Giám thị Trần (`prologue_ultimatum_confrontation`)
* **Bối cảnh:** Phòng số 3. Thầy Giám thị Trần bước vào với kẹp hồ sơ kỷ luật.
* **Nhân vật:** Thầy Giám thị Trần (`teacher`), Lục Thanh Vân (`van`), Diệp Khuê (`khue`).
* **Cấu trúc thoại:**
  * `start` [teacher · neutral]: Lục Thanh Vân! Tôi đã bảo hạn chót dọn dẹp phòng là hôm nay rồi cơ mà? $\rightarrow$ `paper`
  * `paper` [teacher · neutral]: Đây là thông báo chính thức của Ban Giám thị: CLB Báo chí ngừng ra báo suốt 6 tháng qua. Phòng số 3 sẽ bị thu hồi làm kho chứa thiết bị thể thao mới do Hải Vọng Corp tài trợ. $\rightarrow$ `van_protest`
  * `van_protest` [van · serious]: Thưa thầy! Hồi Âm là truyền thống mười lăm năm của trường! Chỉ vì các anh chị khóa trước tốt nghiệp mà thầy vội niêm phong... $\rightarrow$ `teacher_cut`
  * `teacher_cut` [teacher · neutral]: Truyền thống không nuôi nổi thành tích! Trong kỳ kiểm định này, trường không cần một góc phòng bừa bộn và những kẻ thích bới lông tìm vết. $\rightarrow$ `decision`
  * `decision` [khue · serious]: Vân cắn chặt môi, mắt ngấn nước nhưng bất lực trước tờ quyết định...
    * *Lựa chọn A:* Chìa thẻ hội viên của Thầy Diệp và viện dẫn quy chế bảo hộ CLB. $\rightarrow$ `card`
    * *Lựa chọn B:* Đứng ra nhận trách nhiệm và cam kết xuất bản số báo mới trong 7 ngày. $\rightarrow$ `promise`
  * `card` [khue · lead_found]: Thưa thầy Trần, em có thẻ hội viên danh dự của Thầy Diệp Văn Trí. Quy chế trường nêu rõ: CLB chỉ giải thể nếu không thể xuất bản số báo định kỳ. $\rightarrow$ `challenge`
  * `promise` [khue · questioning]: Xin thầy cho chúng em đúng 7 ngày! Đến chiều thứ Sáu, chúng em sẽ phát hành một số báo Hồi Âm chất lượng phục vụ toàn trường. $\rightarrow$ `challenge`
  * `challenge` [teacher · neutral]: 7 ngày? Hai đứa học sinh với căn phòng hoang tàn này đòi ra báo sao? Được, tôi cho các người đúng hạn chiều thứ Sáu! Không có báo nộp duyệt, tự tay dọn đồ biến khỏi đây! $\rightarrow$ `end`
  * `end` [van · serious]: Thầy Trần bỏ đi rồi... Cậu có biết mình vừa cam kết điều gì không, Diệp Khuê? *(Hết)*

### Phân cảnh 5: Chiếc tủ sắt và Manh mối 2011 (`prologue_locked_cabinet`)
* **Bối cảnh:** Góc phòng số 3 sau khi Thầy Trần rời đi.
* **Nhân vật:** Lục Thanh Vân (`van`), Diệp Khuê (`khue`).
* **Cấu trúc thoại:**
  * `start` [van · serious]: 7 ngày để ra một số báo hoàn chỉnh... Máy in thì kẹt giấy, không có phóng viên hiện trường, tiền quỹ thì rỗng túi. Cậu liều lĩnh quá đấy. $\rightarrow$ `khue_calm`
  * `khue_calm` [khue · serious]: Nếu không nhận kèo, hôm nay căn phòng này đã bị dán giấy niêm phong rồi. Cậu nhìn chiếc tủ sắt ở góc phòng kia xem. $\rightarrow$ `cabinet_look`
  * `cabinet_look` [van · neutral]: Đó là tủ tài liệu lưu trữ từ thời Thầy Diệp Văn Trí. Sau vụ tai nạn sập giàn giáo năm 2011, hồ sơ bị niêm phong, chẳng ai mở được ổ khóa gỉ sét đó. $\rightarrow$ `unlock`
  * `unlock` [khue · lead_found]: Cạch! Chiếc chìa khóa trong cuốn sổ tay bìa da của ông vừa khít ổ khóa. Cánh cửa sắt kẽo kẹt mở ra... $\rightarrow$ `revelation`
  * `revelation` [van · happy]: Kỳ diệu thật... Những bản thảo gốc của Hồi Âm thời hoàng kim! Và cả tập hồ sơ điều tra dở dang về sự cố năm 2011... $\rightarrow$ `agreement`
  * `agreement` [khue · happy]: Chúng ta có nền tảng rồi. Mình sẽ làm Trưởng ban Phóng viên đi săn tìm câu chuyện thực tế, còn cậu phụ trách Trưởng ban Biên tập và chế bản in. Được chứ? $\rightarrow$ `agreement_end`
  * `agreement_end` [van · happy]: Được! Lục Thanh Vân này chưa từng biết đầu hàng. Chúng ta sẽ làm cho cả trường Tĩnh Tâm phải lắng nghe Hồi Âm trở lại! *(Hết)*

### Phân cảnh 6: Ly trà tắc lúc 17:30 (`prologue_afternoon_teatime`)
* **Bối cảnh:** Chiều muộn 17:30 tại phòng số 3 đã được dọn sạch bụi, nắng hoàng hôn vàng rực.
* **Nhân vật:** Lục Thanh Vân (`van`), Diệp Khuê (`khue`).
* **Cấu trúc thoại:**
  * `start` [van · neutral]: Phù... Cuối cùng cũng quét sạch bụi ba dãy bàn. Này Khuê, uống chút trà tắc đi. Quán dưới dốc trường ngon lắm, dù đá tan gần hết rồi. $\rightarrow$ `khue_thanks`
  * `khue_thanks` [khue · happy]: Cảm ơn cậu. Vị chua ngọt của tắc với vị chát nhẹ của trà... giúp tỉnh táo hẳn sau một buổi dọn dẹp mệt nhoài. $\rightarrow$ `van_confide`
  * `van_confide` [van · serious]: Thật lòng mà nói, một năm qua mình cô đơn lắm. Từng có nhiều người hứa ở lại, nhưng khi thấy áp lực kỷ luật và kỳ kiểm định, họ đều lặng lẽ rút lui... $\rightarrow$ `khue_promise`
  * `khue_promise` [khue · serious]: Mình chuyển về Hải Vọng không phải để làm khách qua đường. Mình sẽ cùng cậu đi tới cùng con đường này, Vân à. $\rightarrow$ `van_smile`
  * `van_smile` [van · happy]: Cảm ơn cậu... Đã lâu lắm rồi mới có người thực sự tin vào căn phòng này. Ngày mai chúng ta bắt tay vào việc nhé! *(Hết)*

### Phân cảnh 7: Quán ốc cảng cá & Manh mối đầu tiên (`prologue_evening_harbor_stall`)
* **Bối cảnh:** 20:00 tối tại quán ốc vỉa hè của mẹ Long bên cảng cá Hải Vọng tấp nập.
* **Nhân vật:** Đoàn Bảo Long (`long`), Diệp Khuê (`khue`).
* **Cấu trúc thoại:**
  * `start` [long · happy]: Ô kìa Khuê! Học sinh mới chuyển trường mà đã biết mò ra tận cảng cá ăn ốc rồi à? Ngồi đây, ngồi đây, tao lấy cho đĩa ốc hương xào me đặc biệt! $\rightarrow$ `khue_greet`
  * `khue_greet` [khue · happy]: Long đấy à? Quán của nhà cậu đông khách thật đấy. Vừa ngồi xuống đã nghe mùi ốc nướng thơm nức mũi. $\rightarrow$ `long_news`
  * `long_news` [long · serious]: Tao nghe tin đồn ngoài hành lang rồi nhé: Mày dám đứng ra nhận kèo 7 ngày với Thầy Giám thị Trần để giữ phòng số 3 đúng không? Gan cùng mình đấy con trai! $\rightarrow$ `khue_ask`
  * `khue_ask` [khue · investigate]: Cậu quen biết rộng khắp trường, có chuyện gì đáng để Hồi Âm lên tiếng mở màn số báo tuần này không? $\rightarrow$ `long_reveal`
  * `long_reveal` [long · happy]: Có ngay! Vụ nóng hổi đây: Căng tin trường vừa dán bảng giá mới, tăng 30% mà cơm hộp lại teo tóp, thức ăn nguội ngắt! Học sinh đang kêu trời mà không ai dám ý kiến. $\rightarrow$ `cooperation`
  * `cooperation` [khue · lead_found]: Một đề tài sát sườn đời sống học sinh! Long, cậu có muốn gia nhập Hồi Âm làm trinh sát nguồn tin không? $\rightarrow$ `long_join`
  * `long_join` [long · happy]: Chốt kèo luôn! Tao phụ trách mảng cơ sở đường phố cho. Ăn ốc nhanh đi, mai tao dẫn mày đi tiếp cận các bạn khối 10 phỏng vấn! *(Hết)*

### Phân cảnh 8: Đêm Hải Vọng & Cuộn băng dang dở (`prologue_night_reflection`)
* **Bối cảnh:** 22:30 đêm tại phòng trọ của Khuê nhìn ra ngọn hải đăng quét sáng ngoài vịnh biển.
* **Nhân vật:** Diệp Khuê (`khue`).
* **Cấu trúc thoại:**
  * `start` [khue · neutral]: 22:30. Ngoài cửa sổ phòng trọ, ngọn hải đăng Hải Vọng quét từng vệt sáng đều đặn trên mặt biển đêm tĩnh lặng. $\rightarrow$ `tape`
  * `tape` [khue · serious]: Tách! Chiếc máy cassette Sony cổ bắt đầu quay cuộn băng. Giọng nói quen thuộc của Thầy Diệp vang lên giữa tiếng rè rè của thời gian... $\rightarrow$ `tape_voice`
  * `tape_voice` [khue · investigate]: “Biên bản ghi âm hiện trường năm 2011: Giàn giáo sập không phải vì thiên tai, mà vì kết cấu thép kém chất lượng của nhà thầu sân sau liên kết...” $\rightarrow$ `notebook`
  * `notebook` [khue · lead_found]: Khuê ghi vào cuốn sổ tay da: “Ngày 1 kết thúc. Căn phòng số 3 chưa đóng cửa. Hạn chót còn 6 ngày. Mục tiêu ngày mai: Khởi động hồ sơ Căng tin cùng Long và Vân.” $\rightarrow$ `sleep`
  * `sleep` [khue · happy]: Một khởi đầu nhiều thử thách, nhưng ngọn lửa của Hồi Âm đã chính thức được thắp lại bên bờ biển Hải Vọng. *(Hết phân cảnh mở đầu)*

---

## 7. DANH MỤC TECHNICAL IDs & TEXT STRINGS DỰ KIẾN (CATALOG SPECIFICATION)

Tuân thủ nguyên tắc `AGENTS.md` (không hardcode chuỗi người chơi đọc trong mã nguồn), toàn bộ văn bản của 8 phân cảnh trên được gán technical IDs cấu trúc ngữ nghĩa rõ ràng, sẵn sàng đưa vào `content/locales/vi.js`:

```json
{
  "content.dialogue.prologue.bus_arrival.title": "Chuyến xe buýt đến Hải Vọng",
  "content.dialogue.prologue.bus_arrival.start": "Mùi gió biển mằn mặn ùa qua khe cửa kính xe buýt. Vịnh Hải Vọng hiện ra dưới chân đèo, xanh ngắt và lấp lánh dưới nắng sớm.",
  "content.dialogue.prologue.bus_arrival.relics": "Trong ba lô, ba di vật của ông nội vẫn nằm ngay ngắn: chiếc máy ghi âm cassette Sony cũ, cuốn sổ tay tác nghiệp sờn gáy, và tấm thẻ hội viên số 001 của CLB Báo chí Tĩnh Tâm.",
  "content.dialogue.prologue.bus_arrival.memory": "Lời trăn trối của Thầy Diệp Văn Trí như vẫn còn văng vẳng: “Báo chí không phải là công cụ trừng phạt hay phục thù. Hãy làm điều đó vì những đứa trẻ đang bị lãng quên trong ngôi trường ấy.”",
  "content.dialogue.prologue.bus_arrival.determination": "THPT Tĩnh Tâm... Cháu đã đến rồi đây, thưa ông.",

  "content.dialogue.prologue.school_gate.title": "Cổng trường THPT Tĩnh Tâm",
  "content.dialogue.prologue.school_gate.start": "Đứng lại! Em kia, học sinh mới chuyển trường đúng không? Sao giờ này còn đứng ngơ ngác ở cổng?",
  "content.dialogue.prologue.school_gate.inspection": "Nhìn tấm băng rôn trên đầu kia đi: Kỳ kiểm định chất lượng 5 năm toàn diện đang bắt đầu. Toàn trường đang dốc sức để đạt chuẩn quốc tế và đón gói tài trợ từ Hải Vọng Corp.",
  "content.dialogue.prologue.school_gate.warning": "Tuyệt đối chấp hành nội quy, không tụ tập gây mất trật tự, và đừng tò mò những chuyện không phận sự. Rõ chưa?",
  "content.dialogue.prologue.school_gate.decision": "Thầy Giám thị Trần quét ánh mắt nghiêm nghị đầy dò xét...",
  "content.dialogue.prologue.school_gate.choice_polite": "Dạ vâng, em chào thầy. Em sẽ về lớp ngay ạ.",
  "content.dialogue.prologue.school_gate.choice_inquire": "Thưa thầy, em nghe nói trường mình từng có CLB Báo chí Hồi Âm rất nổi tiếng...?",
  "content.dialogue.prologue.school_gate.polite_resp": "Dạ thưa thầy, em hiểu rồi ạ. Em là học sinh mới, xin phép thầy vào nhận lớp.",
  "content.dialogue.prologue.school_gate.polite_end": "Tốt. Biết điều thì mới học yên ổn ở Tĩnh Tâm được. Đi nhanh lên!",
  "content.dialogue.prologue.school_gate.inquire_resp": "Thưa thầy Giám thị, em nghe nói trường mình từng có CLB Báo chí Hồi Âm nổi tiếng khắp thành phố...?",
  "content.dialogue.prologue.school_gate.inquire_end": "Hừ! Nhắc đến cái hội đó làm gì? Một nhóm rắc rối đã chết từ lâu rồi. Đừng dại mà bén mảng đến góc dãy nhà C!",

  "content.dialogue.prologue.room_number_3.title": "Căn phòng số 3 dãy nhà C",
  "content.dialogue.prologue.room_number_3.start": "Hành lang cuối dãy nhà C cổ kính vắng lặng như tờ. Biển đồng trước cửa đã xỉn màu: “Phòng sinh hoạt số 3 — CLB Báo chí Hồi Âm”.",
  "content.dialogue.prologue.room_number_3.enter": "Cánh cửa khẽ cọt kẹt mở. Bên trong, bụi mờ lơ lửng trong vạt nắng chiều. Hàng chồng báo cũ phủ bụi, máy in khô mực... và một cô gái đang cặm cụi gạch xóa bản thảo.",
  "content.dialogue.prologue.room_number_3.van_notice": "Ai đó? Nếu cậu đến tìm đồ thất lạc hay thu gom giấy vụn thì nhầm chỗ rồi. Ở đây không có gì cả.",
  "content.dialogue.prologue.room_number_3.introduce": "Chào cậu. Mình là Diệp Khuê, học sinh mới chuyển đến. Mình muốn đăng ký tham gia CLB Báo chí Hồi Âm.",
  "content.dialogue.prologue.room_number_3.van_sigh": "Tham gia sao? Cậu đến muộn cả mấy tháng rồi. CLB này... chỉ còn mỗi mình mình, và sắp bị xóa sổ đến nơi.",

  "content.dialogue.prologue.ultimatum_confrontation.title": "Tối hậu thư của Thầy Giám thị Trần",
  "content.dialogue.prologue.ultimatum_confrontation.start": "Lục Thanh Vân! Tôi đã bảo hạn chót dọn dẹp phòng là hôm nay rồi cơ mà?",
  "content.dialogue.prologue.ultimatum_confrontation.paper": "Đây là thông báo chính thức của Ban Giám thị: CLB Báo chí ngừng ra báo suốt 6 tháng qua. Phòng số 3 sẽ bị thu hồi làm kho chứa thiết bị thể thao mới do Hải Vọng Corp tài trợ.",
  "content.dialogue.prologue.ultimatum_confrontation.van_protest": "Thưa thầy! Hồi Âm là truyền thống mười lăm năm của trường! Chỉ vì các anh chị khóa trước tốt nghiệp mà thầy vội niêm phong...",
  "content.dialogue.prologue.ultimatum_confrontation.teacher_cut": "Truyền thống không nuôi nổi thành tích! Trong kỳ kiểm định này, trường không cần một góc phòng bừa bộn và những kẻ thích bới lông tìm vết.",
  "content.dialogue.prologue.ultimatum_confrontation.decision": "Vân cắn chặt môi, mắt ngấn nước nhưng bất lực trước tờ quyết định...",
  "content.dialogue.prologue.ultimatum_confrontation.choice_card": "Chìa thẻ hội viên của Thầy Diệp và viện dẫn quy chế bảo hộ CLB.",
  "content.dialogue.prologue.ultimatum_confrontation.choice_promise": "Đứng ra nhận trách nhiệm và cam kết xuất bản số báo mới trong 7 ngày.",
  "content.dialogue.prologue.ultimatum_confrontation.card_resp": "Thưa thầy Trần, em có thẻ hội viên danh dự của Thầy Diệp Văn Trí. Quy chế trường nêu rõ: CLB chỉ giải thể nếu không thể xuất bản số báo định kỳ.",
  "content.dialogue.prologue.ultimatum_confrontation.promise_resp": "Xin thầy cho chúng em đúng 7 ngày! Đến chiều thứ Sáu, chúng em sẽ phát hành một số báo Hồi Âm chất lượng phục vụ toàn trường.",
  "content.dialogue.prologue.ultimatum_confrontation.challenge": "7 ngày? Hai đứa học sinh với căn phòng hoang tàn này đòi ra báo sao? Được, tôi cho các người đúng hạn chiều thứ Sáu! Không có báo nộp duyệt, tự tay dọn đồ biến khỏi đây!",
  "content.dialogue.prologue.ultimatum_confrontation.end": "Thầy Trần bỏ đi rồi... Cậu có biết mình vừa cam kết điều gì không, Diệp Khuê?",

  "content.dialogue.prologue.locked_cabinet.title": "Chiếc tủ sắt và Manh mối 2011",
  "content.dialogue.prologue.locked_cabinet.start": "7 ngày để ra một số báo hoàn chỉnh... Máy in thì kẹt giấy, không có phóng viên hiện trường, tiền quỹ thì rỗng túi. Cậu liều lĩnh quá đấy.",
  "content.dialogue.prologue.locked_cabinet.khue_calm": "Nếu không nhận kèo, hôm nay căn phòng này đã bị dán giấy niêm phong rồi. Cậu nhìn chiếc tủ sắt ở góc phòng kia xem.",
  "content.dialogue.prologue.locked_cabinet.cabinet_look": "Đó là tủ tài liệu lưu trữ từ thời Thầy Diệp Văn Trí. Sau vụ tai nạn sập giàn giáo năm 2011, hồ sơ bị niêm phong, chẳng ai mở được ổ khóa gỉ sét đó.",
  "content.dialogue.prologue.locked_cabinet.unlock": "Cạch! Chiếc chìa khóa trong cuốn sổ tay bìa da của ông vừa khít ổ khóa. Cánh cửa sắt kẽo kẹt mở ra...",
  "content.dialogue.prologue.locked_cabinet.revelation": "Kỳ diệu thật... Những bản thảo gốc của Hồi Âm thời hoàng kim! Và cả tập hồ sơ điều tra dở dang về sự cố năm 2011...",
  "content.dialogue.prologue.locked_cabinet.agreement": "Chúng ta có nền tảng rồi. Mình sẽ làm Trưởng ban Phóng viên đi săn tìm câu chuyện thực tế, còn cậu phụ trách Trưởng ban Biên tập và chế bản in. Được chứ?",
  "content.dialogue.prologue.locked_cabinet.agreement_end": "Được! Lục Thanh Vân này chưa từng biết đầu hàng. Chúng ta sẽ làm cho cả trường Tĩnh Tâm phải lắng nghe Hồi Âm trở lại!",

  "content.dialogue.prologue.afternoon_teatime.title": "Ly trà tắc lúc 17:30",
  "content.dialogue.prologue.afternoon_teatime.start": "Phù... Cuối cùng cũng quét sạch bụi ba dãy bàn. Này Khuê, uống chút trà tắc đi. Quán dưới dốc trường ngon lắm, dù đá tan gần hết rồi.",
  "content.dialogue.prologue.afternoon_teatime.khue_thanks": "Cảm ơn cậu. Vị chua ngọt của tắc với vị chát nhẹ của trà... giúp tỉnh táo hẳn sau một buổi dọn dẹp mệt nhoài.",
  "content.dialogue.prologue.afternoon_teatime.van_confide": "Thật lòng mà nói, một năm qua mình cô đơn lắm. Từng có nhiều người hứa ở lại, nhưng khi thấy áp lực kỷ luật và kỳ kiểm định, họ đều lặng lẽ rút lui...",
  "content.dialogue.prologue.afternoon_teatime.khue_promise": "Mình chuyển về Hải Vọng không phải để làm khách qua đường. Mình sẽ cùng cậu đi tới cùng con đường này, Vân à.",
  "content.dialogue.prologue.afternoon_teatime.van_smile": "Cảm ơn cậu... Đã lâu lắm rồi mới có người thực sự tin vào căn phòng này. Ngày mai chúng ta bắt tay vào việc nhé!",

  "content.dialogue.prologue.evening_harbor_stall.title": "Quán ốc cảng cá & Manh mối đầu tiên",
  "content.dialogue.prologue.evening_harbor_stall.start": "Ô kìa Khuê! Học sinh mới chuyển trường mà đã biết mò ra tận cảng cá ăn ốc rồi à? Ngồi đây, ngồi đây, tao lấy cho đĩa ốc hương xào me đặc biệt!",
  "content.dialogue.prologue.evening_harbor_stall.khue_greet": "Long đấy à? Quán của nhà cậu đông khách thật đấy. Vừa ngồi xuống đã nghe mùi ốc nướng thơm nức mũi.",
  "content.dialogue.prologue.evening_harbor_stall.long_news": "Tao nghe tin đồn ngoài hành lang rồi nhé: Mày dám đứng ra nhận kèo 7 ngày với Thầy Giám thị Trần để giữ phòng số 3 đúng không? Gan cùng mình đấy con trai!",
  "content.dialogue.prologue.evening_harbor_stall.khue_ask": "Cậu quen biết rộng khắp trường, có chuyện gì đáng để Hồi Âm lên tiếng mở màn số báo tuần này không?",
  "content.dialogue.prologue.evening_harbor_stall.long_reveal": "Có ngay! Vụ nóng hổi đây: Căng tin trường vừa dán bảng giá mới, tăng 30% mà cơm hộp lại teo tóp, thức ăn nguội ngắt! Học sinh đang kêu trời mà không ai dám ý kiến.",
  "content.dialogue.prologue.evening_harbor_stall.cooperation": "Một đề tài sát sườn đời sống học sinh! Long, cậu có muốn gia nhập Hồi Âm làm trinh sát nguồn tin không?",
  "content.dialogue.prologue.evening_harbor_stall.long_join": "Chốt kèo luôn! Tao phụ trách mảng cơ sở đường phố cho. Ăn ốc nhanh đi, mai tao dẫn mày đi tiếp cận các bạn khối 10 phỏng vấn!",

  "content.dialogue.prologue.night_reflection.title": "Đêm Hải Vọng & Cuộn băng dang dở",
  "content.dialogue.prologue.night_reflection.start": "22:30. Ngoài cửa sổ phòng trọ, ngọn hải đăng Hải Vọng quét từng vệt sáng đều đặn trên mặt biển đêm tĩnh lặng.",
  "content.dialogue.prologue.night_reflection.tape": "Tách! Chiếc máy cassette Sony cổ bắt đầu quay cuộn băng. Giọng nói quen thuộc của Thầy Diệp vang lên giữa tiếng rè rè của thời gian...",
  "content.dialogue.prologue.night_reflection.tape_voice": "“Biên bản ghi âm hiện trường năm 2011: Giàn giáo sập không phải vì thiên tai, mà vì kết cấu thép kém chất lượng của nhà thầu sân sau liên kết...”",
  "content.dialogue.prologue.night_reflection.notebook": "Khuê ghi vào cuốn sổ tay da: “Ngày 1 kết thúc. Căn phòng số 3 chưa đóng cửa. Hạn chót còn 6 ngày. Mục tiêu ngày mai: Khởi động hồ sơ Căng tin cùng Long và Vân.”",
  "content.dialogue.prologue.night_reflection.sleep": "Một khởi đầu nhiều thử thách, nhưng ngọn lửa của Hồi Âm đã chính thức được thắp lại bên bờ biển Hải Vọng."
}
```

---

## 8. TIÊU CHUẨN BIÊN TẬP CHO CÁC PHÂN ĐOÀN KẾ TIẾP (EDITORIAL CHECKLIST)

Khi triển khai kịch bản cho các tuần tiếp theo (Tuần 2 đến Tuần 12), toàn bộ đội ngũ biên kịch cần tự kiểm tra theo checklist sau:

- [ ] **Nhất quán Lore:** Có mâu thuẫn với Story Bible v1.0 về vụ sập giàn giáo 2011, vai trò của Thầy Diệp Văn Trí, Hải Vọng Corp hay THPT Tĩnh Tâm không?
- [ ] **Động cơ nhân vật:** Nhân vật hành động vì sự thức tỉnh, lẽ phải và sự thấu cảm, hay vì trả thù/hung hăng?
- [ ] **Quy chuẩn thời gian:** Có tuân thủ đúng chu kỳ 4 khung giờ ngày thường (Sáng - Chiều CLB - Chiều Cá nhân - Tối) và 2 ngày cuối tuần không?
- [ ] **Phân tách Technical IDs:** Mọi câu thoại, nhãn lựa chọn, thông báo hệ thống đã được phân tách thành Technical ID chưa? Đã chuẩn bị đưa vào `content/locales/vi.js` chưa?
- [ ] **Ngôn ngữ thuần Việt:** Đã loại bỏ hết từ ngữ sính ngoại, convert hay ngôn ngữ manga/anime cường điệu chưa? Có giữ được chất mặn mà của thành phố biển miền Trung không?
- [ ] **Kiểm chứng kỹ thuật:** Đã kiểm tra tính toàn vẹn của Scene Graph (mọi node `next` và `choices` đều trỏ tới node hợp lệ, speaker nằm trong danh sách đăng ký) chưa?
