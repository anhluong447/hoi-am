# TÀI LIỆU THIẾT KẾ CƠ CHẾ: GIAI ĐOẠN THỦ (PHIÊN ĐIỀU TRẦN GIAO BAN)
* **Dự án:** CLB Báo Chí (Tập San Tĩnh Tâm)
* **Phân hệ:** Hệ thống Tranh luận / Phiên họp Giao ban (Debate & Hearing System)
* **Phiên bản tài liệu:** v2.1 (Nguồn Bằng chứng Side/General & quality trong THỦ)
* **Người phê duyệt cốt lõi:** Nel (Lead Designer)
* **Ngày cập nhật:** 2026-10-22
* **Phạm vi tài liệu:** Đặc tả chi tiết cơ chế **Giai đoạn THỦ (Defense State)** trong phiên giao ban định kỳ. Giai đoạn **CÔNG (Offense State - Cao trào vạch trần)** được quy hoạch ở tài liệu thiết kế riêng biệt.
* **Đồng bộ thiết kế:** [Story Bible v2, mục 5.4](../narrative/game_story_bible_v2.md#54-bằng-chứng-cho-thủ-và-quality-của-quest). Bản cập nhật này sửa đặc tả; runtime, save và baseline hiện hành chưa thay đổi.

---

## 1. QUY ƯỚC QUẢN LÝ THIẾT KẾ (DESIGN CONVENTIONS)

Mọi điều khoản và thông số trong tài liệu được gán nhãn nghiêm ngặt nhằm phục vụ quá trình phối hợp liên ngành:
* **`[CHỐT]`**: Quyết định thiết kế bất biến từ Lead Designer (Nel). Không tự ý thay đổi nếu không có chỉ thị trực tiếp.
* **`[ĐỀ XUẤT]`**: Phương án kỹ thuật tối ưu hóa rút ra từ mô phỏng toán học và logic hệ thống, chờ Lead duyệt.
* **`[GIẢ ĐỊNH]`**: Tham số vận hành tạm thời phục vụ mô hình cân bằng; có thể tinh chỉnh sau khi playtest.
* **`[MỞ]`**: Hạng mục chưa ấn định, cần phối hợp thảo luận với đội Biên kịch (Narrative), Kỹ thuật (Dev) và Giao diện (UI/UX).

---

## 2. BỐI CẢNH TỰ SỰ & MỤC TIÊU TRẢI NGHIỆM

### 2.1 Bối cảnh tự sự (Narrative Context)
* **Không gian & Vị thế:** Phiên họp giao ban định kỳ quy tụ đại diện toàn bộ các CLB trong trường, dưới sự chủ trì của Ban Giám hiệu (BGH). BGH giữ vai trò trọng tài trung lập tuyệt đối: không can thiệp trừ khi trật tự nghị trường bị phá vỡ hoặc xuất hiện vi phạm quy chế nghiêm trọng.
* **Xung đột chủ đạo:** Trong khi các CLB khác vượt qua phần báo cáo thuận lợi, CLB Báo chí lập tức trở thành tâm điểm công kích của Hội Học Sinh (HHS). Nhân vật chính (**Khuê**) bị đẩy vào thế phòng ngự bị động: buộc phải chứng minh tính chuẩn xác, khách quan và đạo đức tác nghiệp của các bài báo thường kỳ (*General Articles*).
* **Tiến trình đối đầu theo Hồi:**
  * Mỗi hồi kết thúc bằng một phiên giao ban nảy lửa với một ủy viên cốt cán của HHS (các "tay chân" dưới quyền Hội trưởng Huy).
  * Phiên điều trần ở Hồi cuối cùng là màn đối đầu trực diện với Trùm cuối: **Hội trưởng Huy**. `[CHỐT]`
  * **Lịch đồng bộ với [Bible, mục 12.1.1](../narrative/game_story_bible_v2.md#1211-boss-theo-hồi-và-tuyến-main-bắt-buộc) và [GDD-Attack, mục 9.2](GDD-Attack.md#92-danh-mục-boss--đặc-trưng-chiến-đấu-theo-hồi):** Hồi 1 — Khoa, Tuần 3; Hồi 2 — Linh, cuối Tuần 7; Hồi 3 — Huy, Tuần 12. Tuần 8 là khủng hoảng sau trận Linh và mở xung đột với Huy. Tuyến CÔNG của mỗi Boss bám Main bắt buộc; bài thường/thẻ THỦ vẫn theo nguồn Side/General bên dưới. `[CHỐT]`
* **Ranh giới tài nguyên giữa THỦ và CÔNG:**
  * **Tính độc lập tuyệt đối:** Bằng chứng dùng trong THỦ là tư liệu minh oan cho các bài báo thường (*General Articles*) đến từ **Side Quest và General Quest**. General Articles là nhóm bài được bảo vệ, không đồng nghĩa với riêng loại General Quest. Bằng chứng dùng trong CÔNG là tài liệu điều tra ngầm đặc biệt; hai kho hoạt động độc lập, tuyệt đối không dùng chéo. Main Quest không cấp thẻ THỦ. `[CHỐT]`
  * **Cầu nối giai đoạn:** THỦ đóng vai trò "cửa ải sinh tồn". Người chơi phải bảo vệ thành công vị thế chính danh của CLB thì mới đủ tư cách kích hoạt CÔNG để lật ngược tình thế.

```
┌────────────────────────────────────────────────────────────────────────┐
│                          VÒNG LẶP TUẦN CHƠI                            │
│  [Side/General completed] ──> [Lưu thẻ THỦ + Bàn giao tự động]          │
│                          ──> [Xuất bản bài thường] ──> [Mang thẻ THỦ]  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Tài nguyên mang vào)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                     PHIÊN ĐIỀU TRẦN GIAO BAN                           │
│  ┌─────────────────────────────────┐   Vượt qua   ┌─────────────────┐  │
│  │ GIAI ĐOẠN THỦ (Bài báo General) │ ───────────> │  GIAI ĐOẠN CÔNG │  │
│  │ Thanh Phán Quyết > 0            │ (Cấp Tim buff│ (Vạch trần HHS) │  │
│  └─────────────────────────────────┘  khởi điểm)  └─────────────────┘  │
│            │ Thất bại (≤ 0)                                            │
│            ▼                                                           │
│     [GAME OVER / ĐÌNH BẢN]                                             │
└────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Mục tiêu cảm xúc & Tâm lý gameplay
* **Trọng lực của vòng lặp tuần (Weight of Freedom Phase):** Phiên điều trần là bài kiểm tra thực lực (*combat check*) đúc kết từ mọi hành vi phỏng vấn, chụp ảnh, đối soát số liệu trong tuần. Người chơi thu thập hời hợt sẽ đối mặt với cảm giác nghẹt thở khi bị dồn vào chân tường.
* **Cảm giác giằng co công lý (Tug-of-War Dynamic):** Duy trì sự căng thẳng liên tục thông qua việc kiểm soát **Thanh Phán Quyết (Verdict Gauge)** trong biên độ hẹp $[-100, +100]$.

---

## 3. BẢNG NGUYÊN TẮC VẬN HÀNH CỐT LÕI (CORE RULESET)

| Mã luật | Nội dung cơ chế | Trạng thái | Diễn giải kỹ thuật & Hệ quả |
| :---: | :--- | :---: | :--- |
| **R01** | HHS công kích trước bằng Cáo buộc mang lượng Sát thương ($Dmg$) cố định. | `[CHỐT]` | $Dmg$ trừ trực tiếp vào Thanh Phán Quyết ngay khi xuất hiện. Đòn đánh luôn trúng, không phụ thuộc vào bằng chứng đối phó sau đó. |
| **R02** | Người chơi phản hồi bằng $01$ Bằng chứng duy nhất từ kho lưu trữ. | `[CHỐT]` | Mỗi Cáo buộc chỉ được đối đầu bằng một bằng chứng; không hỗ trợ cộng dồn thẻ. |
| **R03** | Khắc chế cố định theo cặp `(Cáo buộc - Loại bằng chứng)`, rồi tính điểm theo quality. | `[CHỐT]` | Vẫn có **Win / Normal / Lose**, không RNG. Side quality cao được nhiều điểm hơn General khi chọn đúng cặp Win; quality không biến chọn sai thành đúng. Bảng điểm tạm ở mục 5.1.2. |
| **R04** | Điểm ròng mỗi lượt: $\Delta = Điểm_{\text{Bằng chứng}} - Dmg_{\text{Cáo buộc}}$. | `[CHỐT]` | Điểm ròng dương khi điểm thẻ vượt Dmg. Win quality cao có thể đảo thế; General đúng cặp Win vẫn có thể lỗ trước cáo buộc Nặng. Normal giảm thiệt hại; Lose khiến thanh sụt giảm nghiêm trọng. |
| **R05** | Phân tầng Cáo buộc thành hai cấp độ: **Nhẹ** và **Nặng**. | `[CHỐT]` | Cáo buộc Nặng sở hữu $Dmg$ vượt trội, tạo biến động nhịp độ bất ngờ trong phiên họp. |
| **R06** | Biên độ Thanh Phán Quyết cố định trong đoạn $[-100, +100]$. | `[CHỐT]` | Giá trị mặc định khi bắt đầu phiên là $0$ `[GIẢ ĐỊNH]`. |
| **R07** | **Trần cứng (Hard Cap) $+100$:** Mọi điểm số vượt trần đều bị hủy bỏ. | `[CHỐT]` | Triệt tiêu khả năng "farm" tích lũy điểm an toàn quá sớm để chủ quan ở giai đoạn cuối. |
| **R08** | **Đáy $-100$ kích hoạt Lượt Vớt:** Cho phép cứu sinh duy nhất $01$ lần/phiên. | `[CHỐT]` | Chạm đáy lần thứ hai tại bất kỳ thời điểm nào $\rightarrow$ Xử thua ngay lập tức. |
| **R09** | Bản chất Lượt Vớt: Thử thách đối thoại về "Lý tưởng & Đạo đức làm báo". | `[CHỐT]` | Vượt qua: Hồi phục cố định $+50$ điểm (đưa thanh về $-50$); Thất bại: Thua cuộc tức thì (Game Over). |
| **R10** | Điều kiện vượt qua THỦ: Thanh Phán Quyết đạt giá trị $> 0$ sau khi giải quyết toàn bộ Cáo buộc. | `[CHỐT]` | Kết thúc danh sách Cáo buộc với điểm số $\le 0$ bị phán quyết Đình bản (Game Over). |
| **R11** | Chuyển đổi buff sang CÔNG: Điểm dương cuối THỦ chuyển hóa thành **Thêm Tim**. | `[CHỐT]` | Tim dùng để đỡ sai sót trong CÔNG; chia theo bậc định sẵn, có ngưỡng trần tối đa. |
| **R12** | Phản ứng đám đông (Atmosphere): Phản hồi qua Audio/Visual theo thời gian thực. | `[CHỐT]` | Hoàn toàn đóng vai trò không khí thị giác/thính giác, không tác động trực tiếp lên cơ chế điểm số. |
| **R13** | Chuyển giao thế trận tự động: Hoàn thành bảo vệ bài General $\rightarrow$ Tự động vào CÔNG. | `[CHỐT]` | HHS đuối lý chuyển sang công kích điều tra ngầm $\rightarrow$ Mở màn giai đoạn CÔNG. |
| **R14** | Hai nguồn thẻ THỦ: Side Quest quality cao nhất; General Quest quality thường. | `[CHỐT]` | Quest completed tự lưu thẻ cụ thể, kể cả khi đồng đội tự chạy General. Thẻ dùng để bảo vệ bài thường đã xuất bản; không lấy thẻ điều tra ngầm thay thế. |

---

## 4. QUY TRÌNH MỘT LƯỢT TRANH LUẬN (TURN-BY-TURN FLOW)

Mỗi Cáo buộc từ Hội Học Sinh được thực thi nghiêm ngặt theo chuỗi 7 bước:

```
                  [BƯỚC 1: HHS KHỞI TẠO CÁO BUỘC]
                                 │
                   HHS tung Cáo buộc (Nhẹ hoặc Nặng)
                   Trừ sát thương ngay lập tức:
                   Thanh = Clamp(Thanh - Dmg, -100, 100)
                                 │
                                 ▼
                 [BƯỚC 2: KIỂM TRA ĐÁY KHẨN CẤP]
                                 │
                    Thanh ≤ -100 xảy ra?
                     ├─ ĐÃ dùng Lượt Vớt ───────> [THUA NGAY (GAME OVER)]
                     ├─ CHƯA dùng Lượt Vớt ─────> [KÍCH HOẠT LƯỢT VỚT]
                     │                                   │
                     │                           Thành công: Thanh = -50
                     │                           Thất bại: THUA NGAY
                     └─ Thanh > -100 (An toàn)
                                 │
                                 ▼
                [BƯỚC 3: NGƯỜI CHƠI CHỌN BẰNG CHỨNG]
                                 │
                   Người chơi chọn 01 Thẻ từ kho
                   (Nếu hết sạch thẻ: Tự động phạt Lose = -20)
                                 │
                                 ▼
             [BƯỚC 4: TÍNH ĐIỂM HIỆU LỰC & CẬP NHẬT THANH]
                                 │
                   Đối chiếu cặp, sau đó áp quality:
                     ├─ WIN    : Side +50 / General +20
                     ├─ NORMAL : +20 cho cả hai quality
                     └─ LOSE   : -20 đến 0 điểm
                   (Điểm tạm theo bảng 5.1.2; không RNG)
                   Cộng dồn và kẹp trần/đáy:
                   Thanh = Clamp(Thanh + Điểm_Thẻ, -100, 100)
                                 │
                                 ▼
                 [BƯỚC 5: KIỂM TRA ĐÁY HẬU PHẢN BIỆN]
                                 │
                   (Phòng trường hợp ăn Lose làm sụt về -100)
                   Xử lý Lượt Vớt tương tự Bước 2 nếu chưa dùng.
                                 │
                                 ▼
                   [BƯỚC 6: TIÊU HAO & ĐỒNG BỘ UX]
                                 │
                   - Thẻ đã chọn chuyển vào Discard Pile (Mất quyền dùng lại)
                   - Cập nhật hiệu ứng Đám đông tương ứng mốc điểm mới
                                 │
                                 ▼
               [BƯỚC 7: KIỂM TRA ĐIỀU KIỆN KẾT THÚC THỦ]
                                 │
                     ├─ Còn Cáo buộc ──> Lặp lại Bước 1 với câu hỏi kế tiếp
                     └─ Hết Cáo buộc ──>
                            ├─ Thanh > 0  ──> [THẮNG THỦ] Chuyển Tim -> Vào CÔNG
                            └─ Thanh ≤ 0  ──> [THUA CUỘC] Game Over
```

---

## 5. HỆ THỐNG DỮ LIỆU & CƠ CHẾ THÀNH PHẦN

### 5.1 Hệ thống Bằng chứng (Evidence System)
Bằng chứng là tài nguyên hữu hạn được chuyển hóa trực tiếp từ kết quả tác nghiệp trong tuần tự do của Khuê và đồng đội. **Quality ở đây là bậc chất lượng Bằng chứng của quest**, tách biệt với điểm chất lượng bài báo khi phát hành.

#### 5.1.1 Nguồn thẻ, bàn giao và điều kiện mang vào THỦ `[CHỐT]`

| Nguồn quest | Quality Bằng chứng THỦ | Vai trò |
| :--- | :--- | :--- |
| **Side Quest** | **Cao nhất** (`high`) | Khuê trực tiếp tác nghiệp; tạo bộ tư liệu bảo vệ bài thường. Đúng loại chất vấn có thể lấy điểm cao nhất, bù cho cost và thời gian đầu tư lớn hơn. |
| **General Quest** | **Thường** (`standard`) | Tin bài ngắn, chủ yếu giao đồng đội tự làm; tạo thẻ THỦ cụ thể ở mức điểm thông thường, bên cạnh hưởng ứng và XP. Khuê tự làm vẫn giữ quality thường. |

* Mỗi Side/General hoàn thành phải tự lưu **ít nhất một thẻ THỦ cụ thể** từ tư liệu quest thực sự thu được. Đầu ra này là bắt buộc, độc lập với item thưởng tùy chọn; không cần thêm story riêng cho General.
* Mỗi thẻ có ID ổn định, quest nguồn, bài báo liên quan, loại Bằng chứng, quality và kho THỦ. Content phải khai báo các đầu ra này; bản thiết kế không tự bổ sung field vào save.
* Khi quest completed, lưu thẻ và tự bàn giao tư liệu sang đội xuất bản. Bàn giao không xóa thẻ lưu trữ; feedback hoàn thành cho biết các thẻ đã nhận. Không có bước người chơi duyệt hoặc nhặt thẻ thủ công, không cấp trùng khi xem lại feedback hay khi phát hành.
* Khi mở phiên THỦ, chỉ lấy thẻ gắn với **bài thường đã xuất bản thuộc phạm vi phiên**. Quest đang làm, chưa đủ tư liệu hoặc bài chưa xuất bản không tự sinh thẻ dùng ngay trong phiên.
* Side có đầu mối điều tra ngầm phải định nghĩa tư liệu CÔNG riêng, tách ID và mục đích khỏi bộ thẻ THỦ; không tự sao chép một bằng chứng sang cả hai kho. Main Quest và kho CÔNG không phải nguồn thẻ THỦ.

#### 5.1.2 Quality và khắc chế là hai bước riêng

1. Xác định **Win / Normal / Lose** bằng cặp cáo buộc và loại/nội dung tư liệu phù hợp. Cùng là Ảnh hoặc Nhân chứng không có nghĩa mọi thẻ đều liên quan tới cáo buộc.
2. Tra điểm theo quality; sau đó áp R04. **Side đúng cặp Win phải có điểm cao hơn General đúng cùng cặp** `[CHỐT]`.

| Kết quả đối chiếu | Side — quality cao nhất | General — quality thường |
| :--- | :---: | :---: |
| **Win** — đúng loại chất vấn, đủ sức phản bác | **+50** | **+20** |
| **Normal** — chỉ giảm thiểu, chưa phản bác trọn vẹn | **+20** | **+20** |
| **Lose** — sai loại, lạc đề hoặc không giải đáp được cáo buộc | **-20 đến 0**, cố định theo cặp | **-20 đến 0**, cố định theo cặp |

Các con số trong bảng là **`[GIẢ ĐỊNH]` để playtest**, thay cho cách áp +50 cho mọi thẻ Win trước ngày 2026-10-22. Win/Normal là mức phù hợp, không phải tên quality. Không nhân quality lên điểm Lose; không cộng thưởng Side cho câu hỏi Mitigation Only hoặc Unavoidable Hit. Các bảng/ví dụ +50 bên dưới dùng thẻ Side quality cao; General đúng cặp Win chỉ nhận +20 theo bảng này.

Mục tiêu là tạo động lực mạnh để chơi thêm Side Quest và chuẩn bị đa dạng loại Bằng chứng. General cung cấp tài nguyên thường xuyên, nhưng cày số lượng General không mặc nhiên đủ thắng mọi phiên, nhất là khi có nhiều cáo buộc Nặng. Không áp quota Side hoặc khóa tiến truyện theo số Side hoàn thành; khả năng vượt THỦ và mức đầu tư cần thiết phải được kiểm chứng khi cân bằng.

#### 5.1.3 Nhóm Bằng chứng và tiêu hao

* **Phân loại 5 nhóm Bằng chứng `[GIẢ ĐỊNH]`:**
  1. **Số liệu (Data / Metric):** Thống kê khảo sát, biên bản kiểm kê số lượng, bảng biểu phân tích sai lệch.
  2. **Nhân chứng (Witness):** Lời khai trực tiếp, phát biểu ghi âm của học sinh, nhân viên lao công, cán sự lớp.
  3. **Tài liệu / Văn bản (Document):** Biên bản có mộc đỏ, đơn xin phê duyệt, hóa đơn chứng từ, quy chế chính thức.
  4. **Hình ảnh (Photo):** Ảnh chụp hiện trường, tư liệu đối chứng góc rộng/cận cảnh.
  5. **Vật chứng (Physical Item):** Mẫu vật thu thập tại chỗ, hóa đơn xé dở, linh kiện trang thiết bị hỏng hóc.
* **Quy tắc sử dụng:**
  * **Tiêu hao một lần:** Mỗi thẻ Bằng chứng chỉ được kích hoạt **01 lần duy nhất** trong toàn bộ giai đoạn THỦ. `[GIẢ ĐỊNH]`
  * **Phạt cạn kiệt tài nguyên:** Nếu người chơi hết thẻ mà HHS vẫn tiếp tục chất vấn, hệ thống tự động gán trạng thái *"Không thể xuất trình bằng chứng"*, áp mức phạt cố định **Lose (-20 điểm)** cho lượt đó. `[GIẢ ĐỊNH]`

### 5.2 Phân cấp Cáo buộc & Cấu trúc Sát thương (Accusations & Damage)
* **Phân cấp Sát thương ($Dmg$):**
  * **Cáo buộc Nhẹ:** Gây $10 - 20\ Dmg$ (trung bình 15). Tập trung vào thể thức trình bày, cách dùng từ ngữ mang tính cảm xúc, lỗi trích dẫn nhỏ.
  * **Cáo buộc Nặng:** Gây $35 - 40\ Dmg$ (trung bình 38). Tấn công trực diện vào tính chân thực, nghi vấn gian lận dữ liệu, xâm phạm đời tư, vi phạm đạo đức tác nghiệp. `[ĐỀ XUẤT]`
  * **Tỷ lệ xuất hiện:** Cáo buộc Nặng chiếm khoảng $15\% - 30\%$ tổng số lượt tranh luận. `[ĐỀ XUẤT]`

* **Phân bổ cấu trúc phản biện (Logic Depth):**
  Để loại bỏ tình trạng giải đố một màu, hệ thống cáo buộc được thiết kế theo 3 cấu trúc phản biện:
  1. **Cáo buộc Tiêu chuẩn (Standard - $\approx 65\%$):** Tồn tại ít nhất 1 cặp loại Bằng chứng đạt Win (Side +50 / General +20), 1-2 cặp Normal (+20), còn lại là Lose. Đây là cấu trúc câu hỏi, không đảm bảo kho người chơi có sẵn thẻ đúng.
  2. **Cáo buộc Giảm thiểu thiệt hại (Mitigation Only - $\approx 25\%$):** `[CHỐT]` Hoàn toàn **không có phương án Win** (tối đa là Normal +20). Người chơi buộc phải chọn hy sinh một bằng chứng phù hợp để chịu lỗ nhẹ thay vì mất điểm nặng.
  3. **Cáo buộc Đòn hiểm / Bất khả kháng (Unavoidable Hit - $\approx 10\%$):** `[CHỐT]` Toàn bộ các lựa chọn đều dẫn đến kết quả **Lose ($-20$ đến $0$)**. Mô phỏng những điểm yếu không thể chối cãi của bài báo. Thử thách khả năng "chịu đòn" và tích lũy điểm thặng dư từ trước để bù đắp.

* **Bảng ma trận đối chiếu mẫu (Accusation-Evidence Mapping Matrix):**

Bảng dưới minh họa thẻ **Side quality cao nhất**. Giữ kết quả Win/Normal/Lose khi xét thẻ General cùng nội dung, nhưng đổi điểm Win thành +20 theo mục 5.1.2; không mặc định mọi thẻ cùng loại đều giải đáp được câu hỏi.

| Cáo buộc từ Hội Học Sinh | Bằng chứng: Số liệu | Bằng chứng: Nhân chứng | Bằng chứng: Tài liệu | Bằng chứng: Ảnh chụp |
| :--- | :---: | :---: | :---: | :---: |
| **C1 (Nhẹ, 15 Dmg):** *"Dựa vào đâu mà bài báo khẳng định 80% bàn ghế khu B hỏng hóc?"* | **WIN (+50)**<br>*(Phiếu khảo sát 200 học sinh)* | **NORMAL (+20)**<br>*(Lời khai lớp trưởng)* | **LOSE (-10)**<br>*(Đơn xin sửa bàn ghế cũ)* | **LOSE (0)**<br>*(Ảnh 1 góc bàn nứt)* |
| **C2 (Nặng, 35 Dmg):** *"Bức ảnh khu cách ly thùng rác chụp lén sau giờ học là xâm phạm quyền riêng tư!"* | **LOSE (-20)**<br>*(Bảng thống kê dọn rác)* | **WIN (+50)**<br>*(Biên bản đồng thuận nhân vật)* | **NORMAL (+20)**<br>*(Quy định khu công cộng của trường)* | **LOSE (-20)**<br>*(Ảnh chụp gốc không che mặt)* |
| **C3 (Giảm thiểu / Mitigation Only, 20 Dmg):** *"Ngôn từ bài phóng sự mang tính quy chụp, gây hoang mang dư luận học sinh!"* | **LOSE (-10)** | **NORMAL (+20)**<br>*(Ghi âm nguyên văn không cắt xén)* | **NORMAL (+20)**<br>*(Bản thảo kiểm duyệt nhiều khâu)* | **LOSE (-10)** |

---

## 6. CƠ CHẾ LƯỢT VỚT (THE REBUTTAL BAILOUT / LAST STAND)

```
        Thanh chạm -100 lần đầu
                   │
                   ▼
     ┌───────────────────────────┐
     │ KÍCH HOẠT LƯỢT VỚT:       │
     │ Đối thoại Bản lĩnh &      │
     │ Ý nghĩa tồn tại của CLB   │
     └─────────────┬─────────────┘
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
    [THÀNH CÔNG]        [THẤT BẠI]
         │                   │
  Cộng cố định +50     Thua ngay tức khắc
  (Thanh đưa về -50)   (Game Over)
         │
         ▼
  Tiếp tục phiên họp
  (Chạm -100 lần 2 -> Game Over)
```

### 6.1 Điều kiện kích hoạt & Tần suất
* Kích hoạt tự động ngay khi Thanh Phán Quyết tụt chạm mốc **$-100$ lần đầu tiên** trong phiên họp. `[CHỐT]`
* Tần suất tối đa: **Duy nhất $01$ lần/phiên**. Nếu thanh tụt về $-100$ lần thứ hai, hệ thống xử thua ngay lập tức. `[CHỐT]`

### 6.2 Bản chất thiết kế & Cân bằng toán học
* **Ý đồ trải nghiệm:** Lượt Vớt là khoảnh khắc nghẹt thở mang tính kịch tính điện ảnh ("ngoi lên thở lần cuối"), **tuyệt đối không phải là lối thoát dễ dãi** cho lối chơi ẩu tả.
* **Định mức can thiệp điểm:**
  * **Thành công:** Cộng chính xác **$+50$ điểm**, đưa thanh từ mốc sụp đổ $-100$ về đúng **$-50$**. Phiên điều trần tiếp tục ngay tại Cáo buộc kế tiếp. `[CHỐT]`
  * **Thất bại:** Xử Thua ngay lập tức (Ban Giám hiệu gõ búa bế mạc phiên điều trần). `[CHỐT]`
* **Lý do giữ cố định mức $+50$ (Không nâng lên $+100$ hay $+120$):**
  * Mô phỏng toán học chỉ ra: sau khi vớt về $-50$, xác suất để người chơi lật ngược thế cờ để kết thúc phiên với điểm số $> 0$ chỉ dao động trong khoảng **$0.3\% - 4\%$** (thậm chí $10\% - 28\%$ tái chạm đáy lần hai).
  * Quyết định giữ mức $+50$ nhằm bảo vệ tuyệt đối giá trị của việc chuẩn bị bằng chứng cẩn thận trong tuần. Nếu để Lượt Vớt hồi phục quá mạnh, tính chiến lược của cả trò chơi sẽ sụp đổ khi người chơi ỷ lại vào câu hỏi cuối cùng. `[CHỐT]`

### 6.3 Hướng triển khai câu hỏi Lượt Vớt `[MỞ]`
1. **Hướng Tuyên ngôn Báo chí (Narrative Philosophy):** Đưa ra 3 phát biểu về tôn chỉ hoạt động của Tập san Tĩnh Tâm. Câu trả lời chuẩn xác đòi hỏi sự nhất quán với các quyết định biên tập mà người chơi đã đưa ra xuyên suốt tuần đó.
2. **Hướng Gắn kết Nhân vật (Social Bond / Faction Stand):** Một thành viên chủ chốt trong CLB hoặc một nhân chứng đặc biệt đứng lên phát biểu tiếp sức cho Khuê, điều kiện phụ thuộc vào chỉ số thân thiết (Affection/Reputation).

---

## 7. ĐIỀU KIỆN KẾT THÚC & CHUYỂN TIẾP THỦ ➔ CÔNG

### 7.1 Phân định Thắng / Thua tại THỦ
Giai đoạn THỦ chính thức khép lại khi Hội Học Sinh sử dụng hết toàn bộ danh sách Cáo buộc nhắm vào các bài viết thường kỳ:
* **Thanh Phán Quyết $\le 0$:** **Thất bại (Defeat).** CLB Báo chí bị phán quyết thiếu minh bạch, đình chỉ hoạt động. Trò chơi kết thúc (Game Over). `[CHỐT]`
* **Thanh Phán Quyết $> 0$:** **Vượt qua (Victory).** Toàn bộ cáo buộc của HHS bị vô hiệu hóa. Đại diện HHS đuối lý, buộc phải lôi tài liệu điều tra góc khuất của Hội ra chất vấn $\rightarrow$ Hệ thống tự động chuyển sang **Giai đoạn CÔNG**. `[CHỐT]`

### 7.2 Cơ chế Kế thừa Lợi thế: Quy đổi thành Tim (Transition Buffs)
Để đền đáp cho người chơi xuất sắc mà không phá vỡ tính thử thách của giai đoạn tiếp theo, điểm số thặng dư của THỦ được quy đổi thành **Buff Tim bổ sung** khi bước vào CÔNG.

* **Bản chất của Tim trong CÔNG:** Tim đại diện cho khả năng chịu đựng sai sót của Khuê khi tấn công bóc trần sai phạm của HHS (xem chi tiết tại GDD CÔNG). `[CHỐT]`
* **Nguyên tắc phân tầng bậc (Tiered Caps):** Chia điểm theo ngưỡng bậc nhằm giải quyết vấn đề "Trần cứng $+100$ làm mất động lực của người chơi giỏi": `[ĐỀ XUẤT]`

```
       Điểm cuối THỦ               Buff chuyển giao sang CÔNG
┌─────────────────────────────┐   ┌────────────────────────────────┐
│   Bậc 1: [ +1  đến +33 ]    │──>│  Cộng thêm +0 Tim (Khởi đầu)   │
├─────────────────────────────┤   ├────────────────────────────────┤
│   Bậc 2: [ +34 đến +66 ]    │──>│  Cộng thêm +1 Tim Dự phòng     │
├─────────────────────────────┤   ├────────────────────────────────┤
│   Bậc 3: [ +67 đến +100 ]   │──>│  Cộng thêm +2 Tim Dự phòng     │
│   (Áp đảo hoặc chạm trần)   │   │  (Mức tối đa, có trần cứng)    │
└─────────────────────────────┘   └────────────────────────────────┘
```

* Quy định mức trần: Tối đa chỉ nhận được $+2$ Tim dù điểm số chạm mốc trần $+100$ sớm hay muộn. `[CHỐT]`

---

## 8. HỆ THỐNG ATMOSPHERE & PHẢN HỒI NGHE - NHÌN (UX/UI)

Đám đông trong hội trường (học sinh đại diện các CLB, khán giả trung lập) đóng vai trò như một máy đo cảm xúc trực quan phản chiếu tình thế của Thanh Phán Quyết theo thời gian thực. Hệ thống này **hoàn toàn là Atmosphere**, không can thiệp cơ học nhưng tạo ra áp lực tâm lý cực lớn. `[CHỐT]`

| Biên độ Thanh | Phản hồi Hình ảnh (Visual & Animation) | Phản hồi m thanh (SFX & BGM) | Cảm xúc truyền tải |
| :---: | :--- | :--- | :--- |
| **$[-100, -60]$** | Học sinh xì xào chỉ trỏ gay gắt; đại diện HHS khoanh tay cười nhếch mép; ánh sáng sân khấu tối sầm phía Khuê. | Tiếng cười khẩy, rì rầm chê bai rõ rệt, tiếng gõ bàn bức xúc; BGM trầm đục, căng thẳng dồn dập. | Áp bức tột cùng, bờ vực sụp đổ. |
| **$[-59, -1]$** | Khán giả quay mặt sang phía HHS, nhiều ánh mắt nghi ngại dồn về phía bàn CLB Báo chí. | Tiếng xì xào nghi ngại, tiếng lật giấy bồn chồn, nhịp trống gõ bất an. | Thế trận bất lợi, phòng ngự co cụm. |
| **$0$ (Cân bằng)** | Cả hội trường im lặng quan sát, khán giả nhìn qua lại giữa hai bên chất vấn. | Tiếng thì thầm trung tính, tiếng rè nhẹ của micro hội trường. | Căng thẳng giằng co, chờ đợi bước ngoặt. |
| **$[+1, +59]$** | Khán giả bắt đầu gật gù; vài đại biểu CLB quay sang trao đổi tán đồng với lập luận của Khuê. | Tiếng vỗ tay lẹt đẹt rải rác, tiếng ồ tán thưởng nhỏ; BGM sáng dần lên. | Lấy lại quyền chủ động, thế trận cân bằng. |
| **$[+60, +100]$** | Khán giả ngồi thẳng lưng hướng về Khuê; phía HHS toát mồ hôi, bối rối lục tìm tài liệu. | Tiếng vỗ tay rộ lên từng đợt, tiếng reo ủng hộ lan tỏa; dàn nhạc giao hưởng/piano dâng trào mạnh mẽ. | Khí thế áp đảo, công lý được bảo vệ. |

* **Kế thừa không khí sang CÔNG:** Toàn bộ trạng thái cảm xúc của hội trường ở giây phút kết thúc THỦ sẽ được **giữ nguyên sang vạch xuất phát của CÔNG**, tạo đòn bẩy tâm lý cực mạnh cho pha phản công vạch trần. `[CHỐT]`

---

## 9. MÔ HÌNH CÂN BẰNG TOÁN HỌC & ĐỊNH HƯỚNG THIẾT KẾ (BALANCING MATRIX)

*Lưu ý: Các số liệu mô phỏng đóng vai trò định hướng thuật toán, không thay thế việc kiểm thử người chơi thực tế (Blind Playtest).*

**Phạm vi số liệu cũ:** Các tỷ lệ trong mục 6.2, 9.2–9.3 và tiêu chí tham chiếu mục 12 được giữ từ mô hình trước ngày 2026-10-22, khi mọi thẻ Win đều +50. Chúng **chưa kiểm chứng** phân tầng Side/General ở mục 5.1.2; không dùng để khẳng định balance mới đã đạt mục tiêu. Cần mô phỏng lại theo cơ cấu quality và nhóm Bằng chứng thực tế.

### 9.1 Tham số mô phỏng tiêu chuẩn
* Kịch bản mô phỏng chuẩn: **10 Cáo buộc**, kho gồm **5 loại Bằng chứng**, mỗi bằng chứng chỉ dùng 1 lần.
* Sát thương áp dụng: Nhẹ ($10 - 20$), Nặng ($35 - 40$).
* Khi kiểm chứng quality mới, so sánh kho chỉ General, kho hỗn hợp và kho thiên Side với cùng số thẻ, cùng chuỗi cáo buộc; đo riêng tỷ lệ đúng loại, điểm cuối phiên, dùng Lượt Vớt và Tim chuyển CÔNG. Sau đó kiểm tra cost/thời gian kiếm từng kho trong lịch tuần thực tế.
* Mô hình hành vi: Người chơi theo thuật toán "Tham lam" (Greedy Algorithm) — luôn chọn bằng chứng đạt điểm cao nhất cho câu hỏi hiện tại mà không có khả năng nhìn thấu tương lai.

### 9.2 Tương quan giữa Tỷ lệ Tài nguyên và Tỷ lệ Sống sót

Độ khó của phiên điều trần được điều phối thông qua chỉ số:

$$\text{Tỷ lệ Tài nguyên} = \frac{\text{Tổng số Bằng chứng thu thập}}{\text{Tổng số Cáo buộc trong phiên}}$$

| Tỷ lệ Tài nguyên | Tỷ lệ Cáo buộc Nặng | Tỷ lệ Vượt qua THỦ | Trận đấu Sát nút ($[-25, +25]$) | Tỷ lệ Chạm đáy ($-100$) |
| :---: | :---: | :---: | :---: | :---: |
| **$0.7$** | $15\% - 30\%$ | **$1\% - 4\%$** *(Cầm chắc thất bại)* | $7\% - 17\%$ | *Chưa đo* (dự kiến rất cao) |
| **$0.9$** | $15\%$ | **$49\% - 51\%$** | $\approx 35\%$ | $\approx 8\%$ |
| **$0.9$** | $30\%$ | **$31\%$** | $\approx 32\%$ | $\approx 20\%$ |
| **$1.1$** | $15\%$ | **$83\% - 84\%$** | $\approx 19\%$ | $\approx 2\%$ |
| **$1.1$** | $30\%$ | **$69\% - 70\%$** | $\approx 25\%$ | $\approx 6\%$ |

### 9.3 Đúc kết thiết kế cân bằng (Design Insights)
1. **Hiện tượng Vách đá Độ khó (The Difficulty Cliff):** 
   * Tuyệt đối không tăng độ khó bằng cách "nhồi nhét thêm Cáo buộc" một cách cơ học. Nếu tăng số Cáo buộc mà không nâng số lượng cơ hội thu thập Bằng chứng trong tuần (khiến tỷ lệ tài nguyên tụt xuống $< 0.8$), tỷ lệ thất bại của người chơi sẽ lao dốc thẳng đứng về gần $100\%$.
2. **Quy hoạch độ khó theo Hồi truyện (Pacing Roadmap):**
   * **Hồi 1 (Nhập môn / Giới thiệu):** Cân bằng tỷ lệ tài nguyên ở mức $\approx 1.1 - 1.2$, tỷ lệ Cáo buộc Nặng $\le 15\%$. Tỷ lệ thắng mục tiêu: $75\% - 85\%$.
   * **Hồi 2 (Thử thách trung hạn):** Tỷ lệ tài nguyên $\approx 1.0$, tỷ lệ Cáo buộc Nặng $\approx 20\%$. Tỷ lệ thắng mục tiêu: $60\% - 65\%$ *(nội suy giữa các mốc đã đo, chưa mô phỏng trực tiếp)*.
   * **Hồi 3 (Đối đầu Trùm cuối Huy):** Tỷ lệ tài nguyên $\approx 0.95$, tỷ lệ Cáo buộc Nặng $\approx 30\%$, đòi hỏi sự tính toán tối ưu từng món tài nguyên. Tỷ lệ thắng mục tiêu: $\approx 40\%$ *(nội suy: mốc đo được là $31\%$ tại $0.9$/$30\%$ và $69\%$ tại $1.1$/$30\%$; cần mô phỏng lại trước khi chốt)*.
3. **Hiện tượng Giằng co Thế trận:** Số lần Thanh Phán Quyết đảo phe (từ âm sang dương hoặc ngược lại) trung bình đạt từ $0.5 - 1.1$ lần/trận, đảm bảo cảm giác bập bập bùng nổ, không bị nhàm chán.
4. **Giải pháp xử lý Điểm Chạm trần $+100$:** Ở tỷ lệ tài nguyên thuận lợi ($1.1$), có tới $40\% - 70\%$ người chơi chạm trần $+100$ từ sớm. Việc phân chia bậc Buff Tim (Mục 7.2) là chốt chặn quan trọng nhằm giữ trọn vẹn cảm giác thỏa mãn cho người chơi giỏi mà không làm hỏng tính cân bằng.

---

## 10. KỊCH BẢN CHƠI MINH HỌA (SCRIPTED PLAYTHROUGH)

* **Thiết lập:** Khuê đối đầu với Khoa — đầu mối Phong trào & CSVC của HHS tại Phiên Giao ban Hồi 1, Tuần 3. Bài bàn ghế dưới đây chỉ minh họa các lượt bảo vệ bài thường trong THỦ; tuyến điều tra CÔNG tiếp sau tổng kết Main Tuần 1–3 theo GDD-Attack mục 9.2.
* **Thanh Phán Quyết khởi điểm:** $0$.
* **Kho Bằng chứng khởi điểm của Khuê:**
  1. `[SỐ LIỆU / SIDE / HIGH]`: Bảng tổng hợp khảo sát 200 mẫu phiếu về tình trạng bàn ghế khu B.
  2. `[ẢNH CHỤP / SIDE / HIGH]`: Ảnh chụp cận cảnh thanh xà nứt gãy và trần dột lớp học B3.
  3. `[NHÂN CHỨNG / GENERAL / STANDARD]`: Đoạn băng ghi âm phỏng vấn bác bảo vệ phụ trách kho bảo trì.
  4. `[TÀI LIỆU / SIDE / HIGH]`: Bản sao đơn đề nghị cấp kinh phí sửa chữa đã nộp BGH tuần trước.

Các thẻ đã tự lưu khi quest hoàn thành và liên kết với bài thường đã xuất bản trong phạm vi phiên. Ví dụ dùng bảng điểm tạm ở mục 5.1.2.

---

### Diễn biến chi tiết:

#### LƯỢT 1: CÁO BUỘC NHẸ (Sát thương: 10 Dmg)
* **Hội Học Sinh:** *"CLB Báo chí lấy cơ sở nào để rêu rao rằng 80% bàn ghế khu B xuống cấp? Hay các cậu tự ngồi phòng lạnh bịa số liệu giật gân?"*
* **Cập nhật thanh:** $0 - 10 = -10$. *(Hội trường xì xào, ánh mắt nghi hoặc hướng về Khuê)*
* **Lựa chọn của Khuê:** Xuất trình thẻ `[SỐ LIỆU]` (Bảng khảo sát 200 phiếu).
* **Khắc chế:** **WIN (+50 điểm)**.
* **Tính toán:** $\Delta = +50 - 10 = +40 \rightarrow \text{Thanh hiện tại} = 0 + 40 = +40$.
* **UX/UI:** Đám đông ồ lên tán thành; đại diện HHS khẽ nhíu mày.

#### LƯỢT 2: CÁO BUỘC NẶNG (Sát thương: 35 Dmg)
* **Hội Học Sinh:** *"Bức ảnh chụp trần phòng B3 dột nát được chụp vào giờ tự học buổi tối. Các cậu tự ý đột nhập khu vực cấm mà không có sự cho phép của giám thị!"*
* **Cập nhật thanh:** $+40 - 35 = +5$. *(Hội trường xôn xao chỉ trích)*
* **Lựa chọn của Khuê:** Xuất trình thẻ `[NHÂN CHỨNG]` (Băng ghi âm bác bảo vệ cho phép vào chụp).
* **Khắc chế:** **NORMAL (+20 điểm)**.
* **Tính toán:** $\Delta = +20 - 35 = -15 \rightarrow \text{Thanh hiện tại} = +40 - 15 = +25$.
* **UX/UI:** Hội trường hạ nhiệt; Ban Giám hiệu gật đầu ghi nhận tính hợp lệ.

#### LƯỢT 3: CÁO BUỘC BẤT KHẢ KHÁNG / TOÀN LOSE (Sát thương: 20 Dmg)
* **Hội Học Sinh:** *"Cho dù có người mở cửa, bài viết dùng từ ngữ 'nguy hiểm chết người' đã gieo rắc sự hoang mang cực độ cho phụ huynh học sinh!"*
* **Cập nhật thanh:** $+25 - 20 = +5$.
* **Lựa chọn của Khuê:** Xuất trình thẻ `[ẢNH CHỤP]` (Cố gắng đưa ảnh trần nứt ra thanh minh mức độ nguy hiểm).
* **Khắc chế:** **LOSE (-10 điểm)** *(Vì hình ảnh không thể thanh minh cho lỗi dùng từ giật gân)*.
* **Tính toán:** $\Delta = -10 - 20 = -30 \rightarrow \text{Thanh hiện tại} = +25 - 30 = -5$.
* **UX/UI:** Khán giả lắc đầu chê bai; đại diện HHS mỉm cười đắc thắng.

#### LƯỢT 4: CÁO BUỘC NHẸ (Sát thương: 20 Dmg)
* **Hội Học Sinh:** *"Các cậu chỉ trích nhà trường chậm trễ, nhưng các cậu hoàn toàn không nắm được quy trình phê duyệt ngân sách công cộng!"*
* **Cập nhật thanh:** $-5 - 20 = -25$. *(Thanh rớt sâu, nhạc nền căng thẳng dồn dập)*
* **Lựa chọn của Khuê:** Xuất trình thẻ `[TÀI LIỆU]` (Bản sao đơn đề nghị kinh phí đã được BGH đóng dấu tiếp nhận).
* **Khắc chế:** **WIN (+50 điểm)**.
* **Tính toán:** $\Delta = +50 - 20 = +30 \rightarrow \text{Thanh kết thúc} = -5 + 30 = +25$.

#### KẾT QUẢ CHUNG CUỘC PHIÊN THỦ:
* Hết danh sách Cáo buộc bài viết General.
* Thanh Phán Quyết dừng ở mức: **$+25\ (> 0)$** $\rightarrow$ **VƯỢT QUA GIAI ĐOẠN THỦ THÀNH CÔNG!**
* **Chuyển giao:** Kích hoạt Buff **Bậc 1** mang sang CÔNG: Cấp thêm **$+0$ Tim** (Khởi đầu tiêu chuẩn). Không khí đám đông giữ trạng thái Khuê lấy lại quyền chủ động.

---

## 11. DANH MỤC CÁC VẤN ĐỀ CẦN HOÀN THIỆN (DESIGN BACKLOG)

| Hạng mục | Thuộc tính | Trạng thái | Hướng giải quyết đề xuất |
| :--- | :---: | :---: | :--- |
| **Balance quality Side/General** | Tài nguyên / Điểm | `[MỞ]` | Kiểm chứng bảng điểm tạm mục 5.1.2, số thẻ mỗi quest, cơ cấu loại thẻ và cost/thời gian kiếm thẻ. Chốt mức khuyến khích làm Side mà không áp quota hoặc buộc hoàn thành mọi Side. |
| **Cơ chế Nhìn trước Cáo buộc (Telegraphing)** | Hệ thống | `[MỞ]` | Nghiên cứu cho phép người chơi nhìn trước $1 - 2$ Cáo buộc tiếp theo trong hàng đợi. Mô phỏng hiện chỉ so được người chơi "tham lam" với người chơi "biết trước toàn bộ" (oracle), cho thấy khoảng cách điểm thanh trung bình đáng kể; việc nhìn trước 1–2 cáo buộc chưa được mô phỏng. Rủi ro: biến trò chơi thành bàn cờ tính toán sâu thay vì ứng biến. |
| **Hậu quả khi THỦ thất bại (Game Over)** | Hệ thống | `[MỞ]` | Chưa chốt: thua THỦ thì chơi lại từ điểm lưu nào (đầu phiên điều trần hay đầu tuần), có giữ Bằng chứng đã thu thập không. |
| **Kỹ năng Đặc thù của Hội Học Sinh (Boss Skills)** | Gameplay | `[MỞ]` | Bổ sung Skill kích hoạt theo lượt của Boss HHS: Cấm dùng nhóm thẻ Số liệu trong 1 lượt; hoặc gán hiệu ứng Sát thương duy trì (DoT - rút 5 điểm mỗi lượt). |
| **Tương tác Thể lực & Đồng đội (Stamina Impact)** | Nhân vật | `[MỞ]` | Nếu phóng viên phụ trách bài viết bị kiệt sức (Stamina = 0) trong tuần tự do, các thẻ Bằng chứng do nhân vật đó thu thập bị giảm $10$ điểm hiệu lực (Win chỉ còn $+40$, Normal còn $+10$). |
| **Liên kết Điểm Quảng Bá (Thang 100.000)** | Kinh tế | `[MỞ]` | Xác lập công thức quy đổi: Nếu bài báo đạt mốc danh tiếng cao trong tuần, Thanh Phán Quyết khởi điểm tại $+10$ hoặc $+20$ thay vì mức mặc định $0$. |
| **Quy tắc Tái sử dụng Thẻ Bằng chứng** | Tài nguyên | `[MỞ]` | Thử nghiệm cơ chế: Cho phép Bằng chứng cấp cao (Legendary Evidence) tái sử dụng lần thứ 2 với hiệu lực giảm một nửa ($50\%$). |

---

## 12. KẾ HOẠCH & TIÊU CHÍ PLAYTEST (TESTING ROADMAP)

1. **Khảo sát Tâm lý Trải nghiệm Lượt Vớt:**
   * Thu thập dữ liệu định tính xem người chơi cảm nhận Lượt Vớt là một cơ hội "nghẹt thở, đáng nhớ" hay là "cú lừa gây ức chế" khi khả năng thắng sau vớt chỉ từ $0.3\% - 4\%$. Mức hồi phục $+50$ là `[CHỐT]`; nếu tỷ lệ ức chế $> 35\%$, ưu tiên chỉnh các biến khác (tỷ lệ tài nguyên, độ khó câu hỏi vớt) trước, chỉ xem xét lại mức $+50$ như phương án cuối cùng.
2. **Khả năng Đọc Bàn cờ thông qua Atmosphere:**
   * Thử nghiệm ẩn hoàn toàn con số hiển thị trên Thanh Phán Quyết, chỉ để người chơi quan sát phản ứng của đám đông và thanh máu trực quan. Đánh giá xem người chơi có đọc đúng tình trạng trận đấu hay không.
3. **Phản ứng với Cáo buộc Bất khả kháng (Toàn Lose):**
   * Đánh giá mức độ chấp nhận của người chơi khi gặp đòn đánh không thể đỡ. Xác định xem người chơi nhìn nhận đây là thử thách chiến thuật chấp nhận lỗ hay xem đó là lỗi thiết kế bất công.
4. **Kiểm định Tỷ lệ Thắng Mù (Blind Playtest Benchmark):**
   * Tổ chức kiểm thử với nhóm người chơi mới ở Hồi 1, ghi nhận tỷ lệ thắng thực tế có rơi đúng khoảng mục tiêu **$60\% - 75\%$** hay không để kịp thời cân chỉnh bảng Sát thương.
5. **Khép kín vòng lặp Quest → Bằng chứng → THỦ:**
   * General do đồng đội tự chạy vẫn tự lưu ít nhất một thẻ quality thường khi completed; xuất bản không xóa hoặc cấp trùng thẻ. Item thưởng không quyết định việc có thẻ hay không.
   * Side cho thẻ quality cao nhất; thẻ đúng cặp Win nhận nhiều điểm hơn General cùng cặp. Side chọn sai vẫn Lose; Mitigation Only không có Win và Unavoidable Hit không được quality cứu thành đúng.
   * Chỉ thẻ của bài thường đã xuất bản trong phạm vi phiên được mang vào THỦ. Main/kho điều tra CÔNG bị loại; tư liệu THỦ không tự chuyển sang CÔNG sau phiên.
   * UI cho thấy nguồn quest, quality, loại thẻ và liên kết bài báo; người chơi hiểu vì sao thẻ Side có lợi khi chọn đúng và vì sao cần chuẩn bị nhiều loại.
   * So sánh kho General và kho hỗn hợp trong điều kiện cùng số thẻ, rồi tính khả năng thu thập theo energy/lịch tuần. Đo động lực làm thêm Side, tránh biến Side tùy chọn thành yêu cầu ngầm để chơi tiếp.
