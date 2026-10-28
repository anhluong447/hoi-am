# TÀI LIỆU THIẾT KẾ CƠ CHẾ: GIAI ĐOẠN CÔNG (VẠCH TRẦN TỪNG LỚP MẶT NẠ)

* **Dự án:** CLB Báo Chí (Tập San Tĩnh Tâm)
* **Phân hệ:** Hệ thống Tranh luận / Phiên họp Giao ban (Debate & Hearing System)
* **Phiên bản tài liệu:** v2.1 (Đồng bộ Boss với tuyến Main Quest và nguồn Bằng chứng)
* **Người phê duyệt cốt lõi:** Nel (Lead Designer)
* **Ngày cập nhật:** 2026-10-22
* **Phạm vi tài liệu:** Đặc tả chi tiết cơ chế **Giai đoạn CÔNG (Offense State - Cao trào Vạch trần)** trong phiên giao ban định kỳ. Tài liệu đóng vai trò mảnh ghép hoàn thiện nối tiếp trực tiếp sau **Giai đoạn THỦ (Defense State)**.
* **Tình trạng dữ liệu:** Trục Main Quest và mốc Boss ở mục 9.2 được đồng bộ với [Story Bible v2, mục 12.1.1](../narrative/game_story_bible_v2.md#1211-boss-theo-hồi-và-tuyến-main-bắt-buộc) ngày 2026-10-22. Chỉ số $HP$, lời thoại và từng mắt xích đối chất vẫn cần hoàn thiện khi viết kịch bản; tài liệu chưa thay đổi runtime/save/baseline.

---

## 1. QUY ƯỚC QUẢN LÝ THIẾT KẾ (DESIGN CONVENTIONS)

Mọi điều khoản và thông số trong tài liệu được gán nhãn nghiêm ngặt nhằm phục vụ quá trình phối hợp liên ngành:

* **`[CHỐT]`**: Quyết định thiết kế bất biến từ Lead Designer (Nel). Không tự ý thay đổi nếu không có chỉ thị trực tiếp.
* **`[CHỐT TẠM]`**: Đã thống nhất hướng đi tạm thời, sẽ tái đánh giá sau khi có kết quả playtest hoặc tích hợp kịch bản.
* **`[ĐỀ XUẤT]`**: Phương án kỹ thuật tối ưu hóa rút ra từ mô phỏng toán học và logic hệ thống, chờ Lead duyệt.
* **`[GIẢ ĐỊNH]`**: Tham số vận hành tạm thời phục vụ mô hình cân bằng; có thể tinh chỉnh sau khi playtest.
* **`[MỞ]`**: Hạng mục chưa ấn định, cần phối hợp thảo luận với đội Biên kịch (Narrative), Kỹ thuật (Dev) và Giao diện (UI/UX).

---

## 2. BỐI CẢNH TỰ SỰ & TRIẾT LÝ THIẾT KẾ

### 2.1 Bối cảnh tự sự (Narrative Context)
Sau khi bảo vệ thành công các bài viết thường kỳ (*General Articles*) ở giai đoạn THỦ, CLB Báo chí đã giữ vững vị thế chính danh trước toàn trường. Bị dồn vào thế bí, Hội Học Sinh (HHS) quyết định tung đòn mạo hiểm: lôi bài báo điều tra ngầm nhắm vào chính họ ra nghị trường nhằm quy chụp CLB tội vu khống, bôi nhọ uy tín ban cán sự. 

**Đồng bộ nguồn Bằng chứng ngày 2026-10-22:** General Articles ở THỦ gồm bài thường từ **Side Quest và General Quest**, không phải chỉ General Quest. Side cấp thẻ THỦ quality cao nhất, General cấp quality thường; cơ chế điểm nằm ở [GDD-Defense, mục 5.1](GDD-Defense.md#51-hệ-thống-bằng-chứng-evidence-system). **Kho điều tra ngầm của CÔNG vẫn tách biệt hoàn toàn**: Main và các tư liệu điều tra ngầm riêng được chỉ định trong Side phục vụ CÔNG; không lấy thẻ THỦ, quality THỦ hoặc điểm phát hành để tự mở đáp án CÔNG. Nếu Side có tư liệu cho cả hai pha, phải khai báo đầu ra riêng, khác ID/mục đích, không sao chép cùng bằng chứng sang hai kho. Lợi thế điểm cuối THỦ vẫn chỉ chuyển thành Buff Tim theo quy tắc hiện hành. `[CHỐT]`

Tình thế lập tức đảo chiều: Khuê chuyển từ thế bị động giải trình sang **chủ động thuật lại sự thật**. Phiên điều trần trở thành sàn diễn để Khuê bóc trần từng lớp ngụy tạo của đối thủ trước sự chứng kiến của Ban Giám hiệu (BGH) và đại diện các CLB.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        TIẾN TRÌNH CHUYỂN GIAO THẾ TRẬN                 │
│                                                                        │
│   [GIAI ĐOẠN THỦ]                [ĐIỀU KIỆN KÍCH HOẠT]                 │
│   Bảo vệ bài báo General  ───>   Thanh Phán Quyết > 0                  │
│   (Thế thủ / Sinh tồn)           HHS lôi bài báo điều tra ra mổ xẻ     │
│                                            │                           │
│                                            ▼                           │
│                                    [GIAI ĐOẠN CÔNG]                    │
│                                 Bóc trần sai phạm HHS                  │
│                                 (Thế công / Phản biện)                 │
└────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Triết lý & Mục tiêu trải nghiệm (Core Pillars)
1. **Người chơi nắm quyền chủ đạo (Player-Led Pacing):** Khuê là người kể chuyện, kiểm soát nhịp độ tranh luận. Đối phương bị tước quyền chủ động, chỉ có thể ngắt lời, chống chế hoặc chối bỏ một cách bị động. `[CHỐT]`
2. **Tranh luận văn minh (Civilized Discourse):** Trái ngược với phong cách lớn tiếng át giọng của đối thủ, lối chơi của Khuê đề cao sự điềm tĩnh: lắng nghe cẩn trọng, đọc sâu tài liệu và đặt câu hỏi trúng tử huyệt. `[CHỐT]`
3. **Sự leo thang tâm lý rõ rệt (Psychological Escalation):** Khắc họa trọn vẹn tiến trình sụp đổ tâm lý của kẻ phạm sai lầm: từ tự tin, ngạo mạn $\rightarrow$ căng thẳng, gượng gạo $\rightarrow$ mất bình tĩnh, ấp úng $\rightarrow$ phát cuồng (*Crash out*) $\rightarrow$ sụp đổ hoàn toàn. `[CHỐT]`
4. **Vạch trần trọn vẹn (No Loose Ends):** Để giành chiến thắng tuyệt đối, người chơi phải lật tẩy toàn bộ sai phạm được cài cắm, không được bỏ sót bất kỳ đầu mối nào. `[CHỐT]`
5. **Dễ tiếp cận, ưu tiên dòng chảy tự sự (Narrative-First Accessibility):** CÔNG là cao trào thưởng thức cốt truyện. Cơ chế trừng phạt được thiết kế khoan dung để tránh làm gãy mạch cảm xúc người chơi vì các thao tác lỗi thuần cơ học. `[CHỐT]`

---

## 3. BẢNG NGUYÊN TẮC VẬN HÀNH CỐT LÕI (CORE RULESET)

| Mã luật | Nội dung cơ chế | Trạng thái | Diễn giải kỹ thuật & Hệ quả |
| :--- | :--- | :--- | :--- |
| **R01** | Khuê thuật lại các phát hiện điều tra theo từng phân đoạn. | `[CHỐT]` | Cấu trúc tự sự đóng vai trò xương sống; mỗi phân đoạn đại diện cho một mắt xích điều tra. |
| **R02** | Đối phương chỉ có thể ngắt lời để phủ nhận, giải thích hoặc thanh minh. | `[CHỐT]` | Tạo tiền đề cho câu đố đọc hiểu logic; lời đối phương chứa đựng mâu thuẫn cần bóc tách. |
| **R03** | Màn hình Recap xuất hiện sau lời thanh minh, hiển thị toàn bộ thoại kèm các từ/cụm từ gạch chân. | `[CHỐT]` | Đóng vai trò "biên bản đối chất". Người chơi dừng lại để đối chiếu logic thay vì bị ép thời gian. |
| **R04** | Chỉ duy nhất $01$ từ/cụm gạch chân mang mâu thuẫn cốt lõi. Chọn sai trừ $0.5$ Tim. | `[CHỐT]` | Cơ chế lọc nhiễu: người chơi phải nhận diện chính xác luận điểm ngụy biện hoặc phi lý. |
| **R05** | Sau khi bắt đúng từ, người chơi chọn $01$ trong $04$ câu hỏi chất vấn. Chọn sai trừ $0.5$ Tim và khóa lựa chọn sai. | `[CHỐT]` | Giới hạn 4 phương án; việc khóa lựa chọn sai ngăn ngừa hành vi bấm lặp vô ích. |
| **R06** | Bắt đúng từ và chọn đúng câu hỏi: trừ một lượng $HP$ định sẵn của đối phương. | `[CHỐT]` | Mỗi đòn phản biện chính xác tác động trực diện vào "sức chịu đựng tâm lý" của đối thủ. |
| **R07** | Quy trình lặp lại nếu đối phương tiếp tục bao biện; Khuê tiếp tục mạch kể khi đối phương hết lý lẽ. | `[CHỐT]` | Vòng lặp vi mô: giải quyết triệt để từng ngụy biện trước khi mở khóa đầu mối kế tiếp. |
| **R08** | $HP$ đối phương là thanh tiến độ cốt truyện (bình phong), lượng trừ cố định theo sai phạm. | `[CHỐT]` | Mỗi boss sở hữu tổng $HP$ khác nhau; đòn đánh không mang tính ngẫu nhiên hay phụ thuộc chỉ số cày cuốc. |
| **R09** | Điều kiện thắng CÔNG: Bóc trần toàn bộ danh mục sai phạm định sẵn. | `[CHỐT]` | Đảm bảo tính trọn vẹn của cuộc điều tra; không thể kết thúc trận đấu nếu còn uẩn khúc. |
| **R10** | Khi $HP < 50\%$, kích hoạt Giai đoạn Đối chất: BGH đặt câu hỏi chí mạng. | `[CHỐT]` | BGH can thiệp với tư cách trọng tài công tâm; đối phương lúng túng tạo ra sơ hở lớn hơn. |
| **R11** | Khi $HP = 0$: Đối phương phát cuồng (*Crash out*), kích hoạt Mini-game Chặn Đạn và kết thúc bằng Final Shot. | `[CHỐT]` | Chuyển đổi nhịp điệu từ đấu trí chậm rãi sang tương tác hành động xả stress cao trào. |
| **R12** | Khuê có số Tim hữu hạn; thao tác sai trừ từ $0.5$ đến $1.0$ Tim. | `[CHỐT]` | Đóng vai trò tạo ma sát tâm lý và ngăn chặn hành vi đoán mò vô tội vạ. |
| **R13** | Hết Tim: Hồi sinh ngay tại đoạn đang chơi (Checkpointed Recovery). | `[CHỐT]` | Thiết kế nhân từ, loại bỏ tình trạng Game Over ức chế khiến người chơi phải chơi lại từ đầu. |
| **R14** | Mini-game Chặn Đạn có thanh $HP$ độc lập tính theo $\%$. Thua phải chơi lại mini-game. | `[CHỐT]` | Tách biệt hoàn toàn với hệ thống Tim của phần tranh luận trí tuệ. |
| **R15** | Độ khó tổng thể áp dụng một mức thiết lập chung tạm thời. | `[CHỐT TẠM]` | Phục vụ cân bằng cơ bản trước khi mở rộng tùy biến độ khó sâu. |
| **R16** | Thời lượng mỗi màn CÔNG duy trì cô đọng, dồn dập, đảm bảo cao trào không bị loãng. | `[CHỐT]` | Giới hạn số lượng vòng lặp phản biện để duy trì độ sắc bén của kịch bản. |
| **R17** | Toàn bộ bảng dữ liệu $HP$ và danh mục sai phạm để ngỏ cho đội Narrative lấp đầy. | `[CHỐT]` | Tài liệu này tập trung thiết lập bộ khung quy tắc và hệ thống tương tác chuẩn mực. |

---

## 4. CẤU TRÚC TIẾN TRÌNH & ÁNH XẠ CẢM XÚC

### 4.1 Lưu đồ tiến trình tổng thể (Master Flowchart)

```
                       [ĐIỀU KIỆN TIÊN QUYẾT TỪ THỦ]
                         Thanh Phán Quyết cuối THỦ > 0
                        HHS lôi bài báo điều tra ra mổ xẻ
                                      │
                                      ▼
             ┌──────────────────────────────────────────────────┐
             │       GIAI ĐOẠN 1: THUẬT LẠI & PHẢN BIỆN         │
             │   - Khuê thuật phân đoạn điều tra                │
             │   - Đối phương chặn họng, thanh minh             │
             │   - Mở màn Recap (chọn từ gạch chân lỗi)         │
             │   - Chọn câu hỏi chất vấn (1 trong 4)            │
             │   - Trừ HP đối phương (trọng số theo sai phạm)   │
             │   - Lặp lại cho đến khi cạn luận điểm bào chữa   │
             └────────────────────────┬─────────────────────────┘
                                      │
                                      ▼
                        Kiểm tra: HP đối phương < 50%?
                                      │
                                      ▼
             ┌──────────────────────────────────────────────────┐
             │            GIAI ĐOẠN 2: ĐỐI CHẤT BGH             │
             │   - Ban Giám hiệu đặt câu hỏi chất vấn chí mạng  │
             │   - Đối phương luống cuống, lộ mâu thuẫn lớn     │
             │   - Khuê chốt hạ bằng câu hỏi phản biện then chốt│
             │   - Trừ HP dứt điểm về 0                         │
             └────────────────────────┬─────────────────────────┘
                                      │
                                      ▼
                        Kiểm tra: HP đối phương = 0?
                                      │
                                      ▼
             ┌──────────────────────────────────────────────────┐
             │          GIAI ĐOẠN 3: CRASH OUT & MINI-GAME      │
             │   - Đối phương mất kiểm soát, mắng nhiếc, chối bỏ│
             │   - Mini-game Chặn Đạn ngôn từ (30 - 50 giây)    │
             │   - Final Shot: Chuỗi tap liên hoàn bung tỏa     │
             │   - Đối thủ sụp đổ hoàn toàn trước hội đồng      │
             └────────────────────────┬─────────────────────────┘
                                      │
                                      ▼
                         [PHÁN QUYẾT CHUNG CUỘC]
                   BGH kết luận & Chuyển giao chương mới
```

### 4.2 Bảng ánh xạ tiến trình tâm lý đối phương (Psychological Breakdown)

| Giai đoạn | Trạng thái tâm lý | Biểu hiện hành vi | Chỉ dấu Ngôn ngữ & Âm thanh |
| :--- | :--- | :--- | :--- |
| **Giai đoạn 1 (Đầu)** | Ngạo mạn, tự tin tuyệt đối. | Cười nhếch mép, khoanh tay, ngắt lời trịch thượng, coi thường luận điểm của Khuê. | Lời thoại trơn tru, câu từ đanh thép; nhạc nền tự tin của đối phương, nhưng sắc thái nền vẫn kế thừa bầu không khí đám đông từ cuối THỦ (§11) — không ép về một phía. |
| **Giai đoạn 1 (Cuối)** | Căng thẳng le lói, cố thủ. | Nụ cười gượng gạo, ánh mắt lườm nguýt, xuất hiện động tác thừa (chỉnh kính, vuốt tóc). | Thoại bắt đầu dài dòng, dùng nhiều thuật ngữ vòng vo để khỏa lấp sơ hở; nhạc tăng nhịp. |
| **Giai đoạn 2** | Hoảng loạn, đuối lý. | Toát mồ hôi, ấp úng, né tránh ánh nhìn của Ban Giám hiệu, nói năng mâu thuẫn trước sau. | Câu thoại ngắt quãng, xuất hiện các dấu ba chấm; nhạc dồn dập, căng thẳng cực độ. |
| **Giai đoạn 3 (Crash Out)** | Phát cuồng, vỡ vụn nhân cách. | Đập bàn, chỉ tay, mắt trợn tròn, biểu cảm méo mó, hoàn toàn đánh mất tác phong chuẩn mực. | Quát tháo vô nghĩa, chửi đổng, lộ bản chất tha hóa; nhạc chuyển sang tiết tấu hỗn loạn. |
| **Final Shot** | Sụp đổ hoàn toàn (*Defeated*). | Đứng chôn chân, cúi gục đầu, buông thõng hai tay, không thể thốt nên lời. | Nhạc im bặt nhường chỗ cho tiếng búa phán quyết hoặc tiếng thở dốc; hiệu ứng hình ảnh nổ tung. |

---

## 5. HỆ THỐNG TÀI NGUYÊN & QUY TẮC PHẠT

### 5.1 Hệ số Tim ($H_p$ của Khuê)
Tim đóng vai trò là "nguồn lực tập trung" của Khuê trong quá trình đối chất, tạo áp lực vừa đủ để người chơi đọc kỹ tư liệu.

* **Số Tim cơ bản khởi điểm:** $5$ Tim `[ĐỀ XUẤT]`.
* **Cộng dồn Buff từ THỦ:** Tối đa $+2$ Tim dựa trên thành tích điểm số ở giai đoạn THỦ (chia theo các bậc thành tích) `[CHỐT]`.
  $$\text{Tổng Tim mang vào CÔNG} = \text{Tim Cơ Bản} + \text{Tim Buff THỦ} \quad (\text{Dao động: } 5 \text{ đến } 7 \text{ Tim})$$

* **Bảng khấu trừ Tim theo lỗi vi phạm:**

| Loại hành vi sai sót | Mức khấu trừ | Trạng thái | Diễn giải logic tự sự |
| :--- | :--- | :--- | :--- |
| Chọn sai từ/cụm từ gạch chân | $-0.5\ \text{Tim}$ | `[CHỐT]` | Bắt trúng chi tiết không trọng tâm, bị đối phương phản pháo nhẹ. |
| Chọn sai câu hỏi chất vấn | $-0.5\ \text{Tim}$ | `[CHỐT]` | Đặt câu hỏi thiếu sắc bén, bị đối phương lảng tránh thành công (khóa phương án sai). |
| Bắt sai mâu thuẫn ở Giai đoạn 2 | $-0.5\ \text{Tim}$ | `[GIẢ ĐỊNH]` | Đưa ra nghi vấn chưa đủ sức nặng trước hội đồng BGH. |
| Buộc tội vô căn cứ (*False Accusation*) | $-1.0\ \text{Tim}$ | `[ĐỀ XUẤT]` | Vi phạm đạo đức báo chí: quy chụp sai khiến đối phương chớp thời cơ lật ngược tình thế. |

* **Cơ chế Hồi sinh nhân từ (Mercy Respawn Loop):**
  * Khi Tim giảm về $\le 0$, người chơi **không bị Game Over** hay bị đẩy về đầu phiên điều trần `[CHỐT]`.
  * Hệ thống hồi sinh người chơi ngay tại phân đoạn đối chất hiện tại với mức Tim hồi phục định sẵn ($3$ Tim hoặc đầy Tim) `[MỞ]`.
  * **Thiết kế ma sát tâm lý:** Dù không bị Game Over, việc hết Tim sẽ kích hoạt hoạt cảnh nhỏ khiến đối thủ cười khẩy, mỉa mai lòng nhiệt thành của Khuê, đồng thời buộc người chơi phải theo dõi lại đoạn recap để rèn tính cẩn trọng `[ĐỀ XUẤT]`.

### 5.2 Thanh Kháng Cự của Đối Thủ ($HP_{\text{Sanity}}$ - Thanh Bình Phong)
* **Bản chất kỹ thuật:** Thanh $HP$ của đối thủ không phản ánh sát thương tự do mà là **thước đo tiến độ bóc trần sai phạm** của kịch bản `[CHỐT]`.
* **Cơ chế sụt giảm:** Mỗi sai phạm được gắn một trọng số khấu trừ cố định ($\Delta HP$). Chỉ khi người chơi chọn đúng từ gạch chân và đặt đúng câu hỏi tương ứng, lượng $\Delta HP$ đó mới được trừ vào thanh `[CHỐT]`.
* **Tổng lượng máu:** Mỗi boss sở hữu lượng $HP$ danh nghĩa khác nhau tùy thuộc vào vị thế và số lượng tội danh trong kịch bản `[CHỐT]`.
* **Mốc kích hoạt then chốt:**
  * $HP > 50\%$: Vận hành Giai đoạn 1 (Thuật lại & Bẻ gãy thanh minh).
  * $HP < 50\%$: Kích hoạt chuyển cảnh sang Giai đoạn 2 (BGH can thiệp đối chất) `[CHỐT]`.
  * $HP = 0\%$: Kích hoạt Giai đoạn 3 (Đối thủ sụp đổ tinh thần & Mini-game Chặn Đạn) `[CHỐT]`.

### 5.3 Thanh Chống Chịu Mini-game ($HP_{\text{Mini}}$)
* Tách biệt hoàn toàn với hệ thống Tim ($H_p$). Được tính theo thang tỷ lệ phần trăm $0\% - 100\%$ `[CHỐT]`.
* Bị trừ dần khi người chơi để "đạn ngôn từ" va chạm trực tiếp vào nhân vật.
* Thất bại trong mini-game chỉ yêu cầu chơi lại màn chặn đạn đó, không ảnh hưởng đến kết quả phần tranh biện trước đó `[CHỐT]`.

---

## 6. ĐẶC TẢ CHI TIẾT GIAI ĐOẠN 1: THUẬT LẠI & PHẢN BIỆN

### 6.1 Dòng chảy thao tác chuẩn (Turn Pipeline)
Mỗi phân đoạn vạch trần diễn ra tuần tự theo chuỗi 6 bước khép kín:

```
[BƯỚC 1: KHUÊ THUẬT LẠI] ─────────> Khuê trình bày dữ kiện điều tra mới
                                           │
                                           ▼
[BƯỚC 2: ĐỐI PHƯƠNG CHẶN HỌNG] ───> Đối phương ngắt lời, đưa ra lời giải thích/chối tội
                                           │
                                           ▼
[BƯỚC 3: MÀN HÌNH RECAP] ─────────> Toàn văn thanh minh hiện ra với các cụm gạch chân
                                           │
                                           ▼
[BƯỚC 4: BẮT LỖI GẠCH CHÂN] ──────> Người chơi chọn 1 từ/cụm từ phi lý
                                     ├─ SAI : Trừ 0.5 Tim ──> Chọn lại
                                     └─ ĐÚNG: Khóa thành công ──> Mở 4 câu chất vấn
                                           │
                                           ▼
[BƯỚC 5: ĐẶT CÂU HỎI CHẤT VẤN] ───> Chọn 1 trong 4 câu hỏi đào sâu
                                     ├─ SAI : Trừ 0.5 Tim ──> Khóa đáp án sai ──> Chọn lại
                                     └─ ĐÚNG: Kích hoạt đòn phản biện
                                           │
                                           ▼
[BƯỚC 6: KHẤU TRỪ TIẾN ĐỘ] ───────> Đối phương cứng họng, trừ ΔHP định sẵn
                                     ├─ Còn lý do chối ──> Lặp lại Bước 2 với lý lẽ mới
                                     └─ Hết lý do chối  ──> Khuê thuật tiếp khám phá mới
```

### 6.2 Cơ chế Màn hình Recap (Inspection Interface)
* **Ý nghĩa trải nghiệm:** Tái hiện không khí nghị trường trang nghiêm. Màn hình chuyển thành văn bản "biên bản ghi nhận lời khai", cho phép người chơi bình tĩnh soi chiếu ngôn từ mà không bị áp lực thời gian `[CHỐT]`.
* **Phân bổ từ gạch chân:** Trong đoạn văn của đối phương, hệ thống gạch chân từ $3$ đến $5$ cụm từ `[GIẢ ĐỊNH]`:
  * **$01$ Cụm từ Đúng:** Chứa mâu thuẫn trực tiếp với bằng chứng thực tế, tính bất hợp lý thời gian, số liệu hoặc sự lấp liếm có chủ đích.
  * **Các cụm từ Nhiễu (Bẫy logic):** Được thiết kế có vẻ đáng ngờ, mang cảm xúc tiêu cực hoặc cách dùng từ gắt gỏng nhưng về mặt bản chất sự việc lại hoàn toàn đúng luật hoặc không vi phạm quy chế `[ĐỀ XUẤT]`.

### 6.3 Cơ chế Chọn Câu hỏi Chất vấn
* Khi chọn đúng từ gạch chân, hệ thống mở ra bảng hiển thị $04$ phương án chất vấn độc bản được soạn riêng cho tình huống đó `[CHỐT]`:
  * $01$ Câu hỏi Sắc bén (Đúng): Nhắm thẳng vào mâu thuẫn của từ vừa bắt lỗi, dồn đối thủ vào thế không thể giải thích.
  * $03$ Câu hỏi Bẫy (Sai): Gồm các dạng hỏi ngoài lề, công kích cá nhân lạc đề, hoặc hỏi về chi tiết chưa đủ bằng chứng xác thực.
* **Quy tắc khóa:** Chọn sai sẽ làm mờ/gạch bỏ phương án đó trên màn hình và trừ $0.5$ Tim, bảo đảm người chơi không bị kẹt hay bối rối `[CHỐT]`.
* **Thiết kế thân thiện:** Độ khó được định hướng rõ ràng; người chơi theo dõi cốt truyện sẽ dễ dàng nhận ra câu hỏi chuẩn xác ngay lượt đầu `[CHỐT]`.

### 6.4 Mối quan hệ giữa Bằng chứng và Câu hỏi
Trong giai đoạn CÔNG, người chơi không phải mở kho túi đồ để chọn thẻ bằng chứng thủ công như giai đoạn THỦ. **Toàn bộ bằng chứng điều tra thu thập trong tuần đã được tích hợp trực tiếp vào nội dung các câu hỏi chất vấn** `[ĐỀ XUẤT]`. Điều này giúp nhịp độ đối chất liền mạch, biến màn chơi thành cuộc đấu khẩu trí tuệ mượt mà thay vì màn so khớp thẻ bài cơ học.

> `[MỞ]` Hệ quả cần quyết: vì bằng chứng điều tra đã nằm sẵn trong câu hỏi, công sức thu thập **tư liệu điều tra ngầm** trong tuần chưa có vai trò cơ chế riêng ở CÔNG. Hướng xem xét: tư liệu điều tra thu được/bỏ lỡ quyết định việc một phương án đúng có xuất hiện hay có gợi ý đi kèm, hoặc giữ nguyên như hiện tại nếu muốn CÔNG thuần tự sự. Đây là quyết định riêng của kho CÔNG, không dùng thẻ hoặc quality THỦ để thay thế.

---

## 7. ĐẶC TẢ CHI TIẾT GIAI ĐOẠN 2: ĐỐI CHẤT BGH

### 7.1 Điều kiện chuyển pha & Vai trò của Ban Giám hiệu
* Khi thanh $HP_{\text{Sanity}}$ của đối thủ sụt giảm xuống dưới mức $50\%$, mạch tranh luận tự động chuyển sang Giai đoạn Đối chất `[CHỐT]`.
* **Vị thế của BGH:** Thầy/Cô chủ trì phiên họp đại diện cho trật tự và lý tính tối cao. Thấy thành viên HHS có dấu hiệu giải trình quanh co, BGH chủ động cất lời chất vấn các điểm mâu thuẫn then chốt `[CHỐT]`.
* **Nguyên tắc không thiên vị:** BGH chỉ nêu câu hỏi truy vấn chứ **tuyệt đối không đưa ra phán quyết hay kết luận tội danh thay người chơi**. Trách nhiệm tung đòn dứt điểm hoàn toàn thuộc về Khuê `[CHỐT]`.

### 7.2 Cơ chế thực thi
* Dưới sức ép chất vấn của BGH, đối phương lâm vào thế hoảng loạn, bắt đầu nói trước quên sau và bộc lộ các sơ hở nghiêm trọng nhất `[CHỐT]`.
* Hệ thống tiếp tục sử dụng khung tương tác đồng nhất của Giai đoạn 1 (Recap $\rightarrow$ Bắt từ gạch chân $\rightarrow$ Chọn câu hỏi hạ màn) để người chơi không phải làm quen lại cơ chế `[GIẢ ĐỊNH]`.
* Cú chốt hạ chính xác trong giai đoạn này sẽ đánh sập toàn bộ $HP$ còn lại của đối phương về mức $0$, kích hoạt pha chuyển giao sang trạng thái Crash Out `[CHỐT]`.

---

## 8. ĐẶC TẢ CHI TIẾT GIAI ĐOẠN 3: CRASH OUT & MINI-GAME CHẶN ĐẠN

### 8.1 Hiện tượng Tâm lý "Crash Out"
Khi $HP_{\text{Sanity}} = 0$, phòng tuyến lý lẽ của đối thủ sụp đổ hoàn toàn. Đối phương không còn khả năng ngụy tạo sự thanh lịch, hoàn toàn mất bình tĩnh, bắt đầu đập bàn, quát tháo vô tội vạ và lộ rõ bản chất tư lợi `[CHỐT]`.

* **Thể hiện thẩm mỹ:** Lời thoại hiển thị với font chữ méo mó, phóng to, chèn các ký tự đặc biệt thể hiện tiếng chửi thề được kiểm duyệt nhẹ phù hợp lứa tuổi học đường (`#@$%!`) `[ĐỀ XUẤT]`.
* **Ý nghĩa cơ chế:** Đây là tín hiệu báo hiệu chiến thắng tuyệt đối về mặt lập luận của người chơi, đồng thời mở màn cho thử thách tương tác phản xạ cuối cùng `[CHỐT]`.

### 8.2 Cơ chế Mini-game Chặn Đạn Ngôn Từ (Text-Deflection)

```
       [ĐỐI PHƯƠNG CRASH OUT] 
       Tung các cụm từ đả kích!
               │
               ▼
   [ĐẠN CHỮ BAY THEO CÁC LÀN] ──> "ĐỒ ĐIÊN!" / "BIẾT GÌ MÀ NÓI!" / "VU KHỐNG!"
               │
               ▼
   [VỊ TRÍ KHUÊ CHẶN / GẠT ĐẠN]
     - Easy  : Di chuyển nhân vật chắn đúng làn (Hứng tự động)
     - Normal: Nhấn nút bấm khi đạn vào vùng tiếp xúc để đập tan
               │
               ▼
   [KẾT THÚC ĐỢT CÔNG KÍCH] ────> Chuyển sang FINAL SHOT
```

* **Ý tưởng cốt lõi:** Những lời lẽ chối bỏ, thoái mạ từ đối phương được cụ thể hóa thành các luồng đạn chữ bay dồn dập về phía Khuê. Người chơi dùng sự kiên định để đánh tan các đòn công kích tâm lý này `[CHỐT]`.
* **Phân định rõ ràng:** Đây là mini-game phản xạ hành động, **hoàn toàn không phải game âm nhạc theo nhịp (Rhythm Game)** và không dùng đồ họa bong bóng thoại kiểu Danganronpa `[CHỐT]`.
* **Cấu hình làn đạn:** Thiết kế $2$ làn di chuyển (Làn Trên / Làn Dưới), cửa sổ thời gian nhận diện va chạm rộng rãi, ưu tiên cảm giác đã tay `[ĐỀ XUẤT]`.
* **Phân tầng độ khó:**
  * **Easy:** Người chơi chỉ cần gạt cần điều hướng đưa Khuê vào đúng làn đạn; nhân vật sẽ tự động tạo khiên vô hiệu hóa mà không cần bấm nút tấn công `[CHỐT]`.
  * **Normal (Mặc định):** Người chơi di chuyển đúng làn và phải nhấn phím hành động (Đánh/Chặn) đúng thời điểm đạn bay vào tầm `[CHỐT]`.
  * **Hard:** Tạm thời chưa tích hợp, sẽ cân nhắc thêm cùng hệ thống tính điểm Score trong tương lai `[MỞ]`.
* **Thời lượng vận hành:** Toàn bộ mini-game kéo dài trong khoảng $30 - 50$ giây, nhịp độ đạn tăng dần theo mức độ hoảng loạn của boss `[CHỐT]`.

### 8.3 Cơ chế Kết Liễu: Final Shot
* Sau khi chặn đứng toàn bộ đợt đạn ngôn từ, thời gian ngưng đọng, mở ra khoảnh khắc kết liễu tối thượng `[CHỐT]`.
* **Thao tác tương tác:** Màn hình hiển thị lệnh liên hoàn tap (Button Mash) trong vòng $3 - 5$ giây `[CHỐT]`.
* **Nguyên tắc nhân từ:** Đây là cơ chế thưởng thức cảm xúc (*catharsis*). Người chơi tap nhiều hay ít thì sau khi hết $3 - 5$ giây, hiệu ứng phát nổ kết liễu vẫn diễn ra toàn vẹn `[CHỐT]`.
* **Hiệu ứng kết liễu:** Khuê đập tập tài liệu bằng chứng đanh thép xuống mặt bàn, âm thanh phát nổ vang dội xé toạc màn hình, đối thủ hoàn toàn suy sụp và gục ngã trên bàn nghị trường `[CHỐT]`.

---

## 9. KHUÔN MẪU DỮ LIỆU SAI PHẠM & HỒ SƠ ĐỐI THỦ (BOSS PROFILES)

### 9.1 Khuôn mẫu Bảng Sai Phạm (Flaw Matrix Template)
Đội Narrative và Level Design sẽ dựa trên khung cấu trúc này để thiết kế kịch bản chi tiết cho từng chương:

```markdown
### MÃ SAI PHẠM: [Mã_Định_Danh]
* **Giai đoạn áp dụng:** [Giai đoạn 1: Thuật lại & Phản biện / Giai đoạn 2: Đối chất BGH]
* **Khám phá của Khuê (Lời dẫn):** "[Nội dung Khuê thuật lại từ bài báo điều tra]"
* **Lời thanh minh của đối phương:** "[Đoạn văn chứa ngụy biện hoặc lấp liếm của đối thủ]"
* **Danh sách cụm từ gạch chân:**
  - Cụm từ Đúng: "[Từ mang mâu thuẫn cốt lõi]"
  - Cụm từ Bẫy 1: "[Từ gây hiểu lầm / từ ngữ cảm xúc]"
  - Cụm từ Bẫy 2: "[Chi tiết phụ không vi phạm quy chế]"
* **Bảng 4 câu hỏi chất vấn:**
  - [ĐÚNG]: "[Câu hỏi nhắm trúng tử huyệt mâu thuẫn]"
  - [SAI 1]: "[Câu hỏi công kích cá nhân ngoài lề]"
  - [SAI 2]: "[Câu hỏi thiếu căn cứ xác thực]"
  - [SAI 3]: "[Câu hỏi chất vấn nhầm đối tượng]"
* **Thông số tác động:**
  - Khấu trừ HP: [$\Delta HP$ tương ứng trọng số sai phạm]%
  - Phản ứng của đối phương khi người chơi chọn sai: "[Biểu cảm cười khẩy / nhún vai kèm câu thoại mỉa mai]"
```

### 9.2 Danh mục Boss & Đặc trưng Chiến đấu theo Hồi

**Trục truyện và lịch đối đầu `[CHỐT]`:** Boss phải kết tinh từ các Main Quest bắt buộc trong Hồi, đồng bộ với Bible mục 12.1.1. Thay chủ đề căng tin/quỹ ngoại khóa cũ bằng các tuyến Main dưới đây; không nâng Side Quest thành điều kiện ngầm. Tên/chức danh Khoa và Linh được giữ làm nhãn nhân vật phát triển `[MỞ]`; Huy là đối trọng chính đã có trong Bible. Chi tiết lời thoại, mức liên đới và chứng cứ quy trách nhiệm từng nhân vật còn phải viết trong Main, không mặc định mọi sai phạm đều do Boss trực tiếp thực hiện. Đặc tính đạn giữ `[CHỐT TẠM]`.

| Hồi / Mốc Boss | Đối thủ & Chức danh | Main Quest bắt buộc dẫn vào trận | Trục đối chất CÔNG | Phong cách Crash Out | Đặc tính Đạn Ngôn Từ (Mini-game) |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1 — Tuần 3** | **Trần Đình Khoa**<br>*(Trưởng ban Phong trào & CSVC)* | T1: Căn phòng số 3 và Thời hạn 7 ngày → T2: Sân bóng bị khóa trái → T3: Hồ sơ thư viện bị xé và Trang sử 2011. | Đối chiếu lý do thu hồi không gian CLB, lý do khóa sân với hợp đồng cho thuê thực tế, rồi chất vấn phần giải trình của HHS trước hồ sơ lưu trữ bị khuyết. Làm rõ trách nhiệm báo cáo/che giấu của đầu mối CSVC; trang sử 2011 chỉ mở manh mối cho Hồi sau. | Quát tháo thô lỗ, đập bàn chỉ tay, đổ lỗi cho bộ phận quản lý tài sản. | **Đạn To & Dồn dập:** Chữ to, bay thẳng, tốc độ trung bình, mật độ dày đặc `[CHỐT TẠM]`. |
| **2 — Cuối Tuần 7** | **Vũ Thảo Linh**<br>*(Phó Chủ tịch kiêm Trưởng ban Tài chính)* | T4: Bảng vàng danh dự và Danh sách điểm ảo → T5: Sự cố sập phông sân khấu → T6: Dự án Nhà thể chất, dấu hiệu thầu sân sau → T7: Báo cáo kiểm toán và Các con số dị biệt. | Đặt báo cáo thành tích cạnh sai lệch hiện trường và chi phí; trọng tâm là chứng từ, dòng tiền tài trợ và biên bản nghiệm thu khống phòng lab trong Main T7. Xác minh phần trách nhiệm tài chính của Linh; chưa kết luận toàn bộ mạng lưới phía sau. | Run rẩy, cắn móng tay, khóc lóc đổ lỗi cho cấp dưới và hoàn cảnh. | **Đạn Tản Mác:** Đạn chữ nhỏ, quỹ đạo bay uốn lượn, đổi làn đột ngột `[CHỐT TẠM]`. |
| **3 — Tuần 12** | **Phan Gia Huy**<br>*(Chủ tịch Hội học sinh - Trùm Cuối)* | T8: Lệnh cấm phát hành và đối đầu Huy → T9: Hồ sơ 2011 của Thầy Diệp → T10: Hải Vọng Corp và BGH → T11: Bản nghiệm thu gốc → T12: Số Đặc Biệt & Điều trần. | Đối chất việc Huy tham gia che giấu sai phạm để giữ thành tích, ngăn công bố và bảo vệ mạng lưới lợi ích giữa Hải Vọng Corp với nhà trường. Đối chiếu hồ sơ 2011/2026 để minh oan Thầy Diệp và phơi bày nguy cơ an toàn; phân biệt trách nhiệm của Huy với người lớn và nhà thầu. | Im lặng đáng sợ, ánh mắt lạnh băng, nụ cười méo mó, sụp đổ trong câm lặng. | **Đạn Nặng & Biến tốc:** Số lượng đạn ít nhưng kích thước khổng lồ, bay chậm tạo áp lực nghẹt thở `[CHỐT TẠM]`. |

**Ranh giới Tuần 7/8:** Trận Linh khép Hồi 2 ở cuối Tuần 7. Tuần 8 mở Hồi 3 bằng lệnh đình bản sau bài điều tra tài chính và cuộc chạm trán Huy; đây là hệ quả/mở xung đột, chưa phải trận Boss cuối với Huy. Không thêm một trận Linh lần hai ở Tuần 8.

**Hợp đồng tự sự cho mỗi Boss:**

* Main phải giới thiệu Boss, vai trò HHS và lý do đối đầu trước phiên; cung cấp tư liệu đối chiếu và xác minh trách nhiệm cần cho mọi mắt xích đối chất bắt buộc ngay trong Main. Không biến hợp đồng có chữ ký cán bộ quản trị thành chữ ký Khoa hoặc xem hồ sơ bị xé là bằng chứng Khoa tự tay xé nếu Main chưa xác minh.
* Bỏ Side căng tin T1 hoặc Side chênh lệch kinh phí sự kiện T7 không làm thiếu ngữ cảnh, tư liệu hay đáp án bắt buộc của Boss. Side chỉ có thể thêm chiều sâu/lời thoại tùy chọn; mọi nhánh bổ sung phải kiểm tra nội dung người chơi thực sự đã trải qua.
* Trận Huy T12 không được yêu cầu hoàn thành Side đối thoại riêng T10, Side kiểm định sàn tập, Side bảo vệ người tố giác hoặc Side in ngầm. Main T8–12 phải có đường tự thân cho phần hiểu Huy, hồ sơ an toàn, bảo vệ nguồn tin thiết yếu và xuất bản bắt buộc.
* Các đầu ra Main nói trên thuộc tuyến điều tra CÔNG. Quy tắc thẻ THỦ Side/General và quality tại GDD-Defense vẫn tách biệt; hiểu/hoàn tất tuyến đối chất không đồng nghĩa được cấp thẻ THỦ từ Main.

---

## 10. MÔ HÌNH TOÁN HỌC & CÂN BẰNG HỆ THỐNG

### 10.1 Xác suất Đoán Bừa & Ma Sát Tài Nguyên
Để ngăn ngừa người chơi spam chọn bừa mà không đọc kịch bản, hệ thống áp dụng cơ chế khấu trừ tài nguyên dựa trên kỳ vọng toán học:

* Giả định một phân đoạn có $5$ cụm từ gạch chân và $4$ câu hỏi chất vấn:
  * **Kỳ vọng số lần chọn sai ở Bước Bắt Từ:**
    $$E_{\text{Từ}} = \frac{5 - 1}{2} = 2.0\ \text{lần sai} \implies \text{Thiệt hại kỳ vọng} = 2.0 \times 0.5 = 1.0\ \text{Tim}$$
  * **Kỳ vọng số lần chọn sai ở Bước Câu Hỏi:**
    $$E_{\text{Hỏi}} = \frac{4 - 1}{2} = 1.5\ \text{lần sai} \implies \text{Thiệt hại kỳ vọng} = 1.5 \times 0.5 = 0.75\ \text{Tim}$$
  * **Tổng thiệt hại trung bình cho mỗi phân đoạn nếu bấm ngẫu nhiên:**
    $$\text{Tổn thất kỳ vọng} = 1.0 + 0.75 = 1.75\ \text{Tim / Phân đoạn}$$

* **Hệ quả cân bằng:** Với tổng quỹ Tim dao động từ $5$ đến $7$ (đã gồm buff từ THỦ), người chơi chỉ có thể "đoán mò thành công" tối đa $3$ phân đoạn trước khi cạn sạch Tim và kích hoạt hồi sinh. Trong khi đó, người chơi thực sự đọc hiểu chỉ mất rất ít Tim (kỳ vọng $\le 0.5$ Tim mỗi phiên nếu thỉnh thoảng nhầm một bước) `[ĐỀ XUẤT]`.

### 10.2 Quy chuẩn Thời lượng & Nhịp độ (Pacing Guideline)
* **Số lượng mắt xích điều tra mỗi Boss:** Giới hạn từ $3$ đến $5$ khám phá chính `[ĐỀ XUẤT]`.
* **Số lượt đối đáp mỗi mắt xích:** Từ $1$ đến $3$ vòng bẻ gãy thanh minh trước khi chuyển sang mắt xích mới `[ĐỀ XUẤT]`.
* **Tổng thời lượng một màn CÔNG:** Giao động từ $6 - 9$ phút (bao gồm cả Mini-game Chặn Đạn và Final Shot), bảo đảm giữ vững tính dồn dập của một trận Climax cuối chương `[ĐỀ XUẤT]` *(chưa playtest)*.

---

## 11. TÍCH HỢP HỆ THỐNG LIÊN PHÂN HỆ

| Phân hệ tích hợp | Bản chất liên kết & Quy tắc chuyển giao | Trạng thái |
| :--- | :--- | :--- |
| **Giai đoạn THỦ** | Điều kiện mở khóa: Thanh Phán Quyết cuối THỦ $> 0$. Chuyển đổi thành tích thặng dư thành Buff Tim bổ sung (tối đa $+2$ Tim). Bầu không khí đám đông (Atmosphere) tích cực từ THỦ được thừa hưởng trọn vẹn sang CÔNG. | `[CHỐT]` |
| **Vòng lặp Báo chí Tuần** | Mọi phát hiện điều tra Khuê thuật lại trong CÔNG đều là kết quả thu thập trực tiếp từ tuyến nhiệm vụ chính (*Main Quest*) trong tuần tự do. | `[CHỐT]` |
| **Hệ thống Đồng đội (Team System)** | Đề xuất cơ chế hỗ trợ: Các thành viên CLB Báo chí (Vân, Nhi, Long...) có thể kích hoạt kỹ năng phụ trợ (gợi ý từ gạch chân hoặc loại bỏ bớt 1 câu hỏi sai) dựa trên mức độ thân thiết. | `[MỞ]` |
| **Điểm Quảng Bá Tờ Báo** | Nghiên cứu tác động: Có thể mở khóa thêm lời thoại thán phục từ đại diện các CLB khác ở phần phán quyết cuối phiên họp nếu điểm quảng bá đạt mốc xuất sắc. | `[MỞ]` |
| **Bằng chứng Vùng Xám** | Cơ chế điều tra ranh giới (ảnh chụp trộm, nguồn giấu tên): Nếu người chơi sử dụng tài liệu này, đối phương có thể vin vào để kích hoạt mức phạt "Buộc tội vô căn cứ" (trừ $1$ Tim). | `[MỞ]` |

---

## 12. DANH MỤC HẠNG MỤC CHƯA CHỐT & KẾ HOẠCH PLAYTEST

### 12.1 Danh mục Hạng mục Mở (`[MỞ]`) Cần Phê Duyệt

1. **Thông số $HP$ danh nghĩa cụ thể cho từng Boss:** Chờ kịch bản chi tiết từ đội Narrative.
2. **Quy tắc hồi phục Tim khi Hết Tim:** Hồi phục toàn bộ hay chỉ hồi phục một mức cố định (ví dụ: $3$ Tim) để tạo thêm thử thách?
3. **Mức phạt Buộc tội vô căn cứ:** Xác nhận mức trừ cố định $1.0$ Tim đối với các phát biểu thiếu đạo đức tác nghiệp.
4. **Hệ thống trợ lực từ Đồng đội CLB:** Xác định mức độ can thiệp của đồng đội vào quá trình đối chất.
5. **Cơ chế Hậu Phán Quyết:** Sau khi kết thúc Final Shot, người chơi có được quyền đưa ra lựa chọn nhân từ (chừa đường lui) hay xử lý kỷ luật triệt để đối với kẻ sai phạm hay không?
6. **Mở rộng Mini-game:** Chế độ Hard và hệ thống bảng điểm thành tích (Score Attack) cho Mini-game Chặn Đạn.

### 12.2 Kế hoạch & Tiêu chí Đánh giá Playtest (Playtest Checklist)

* [ ] **Cảm nhận tranh biện:** Người chơi có cảm thấy màn hình Recap với các cụm gạch chân mang lại phong thái đối chất văn minh hay chỉ đơn thuần là bài thi trắc nghiệm đọc hiểu ngữ pháp?
* [ ] **Độ dài nhịp độ:** Màn đối đầu kéo dài trung bình $6 - 9$ phút có giữ chân được người chơi hay gây cảm giác lê thê?
* [ ] **Cơ chế Hồi sinh nhân từ:** Việc không Game Over có làm suy giảm cảm giác căng thẳng hay ngược lại, giúp người chơi tập trung tận hưởng cốt truyện tốt hơn?
* [ ] **Độ rõ ràng của Diễn hoạt:** Biểu cảm biến chuyển của boss và sắc thái âm nhạc có truyền tải được mức sụp đổ tâm lý mà không cần nhìn vào thanh $HP$ hay không?
* [ ] **Khả năng tiếp cận Mini-game:** Người chơi không quen thể loại hành động có thể vượt qua mức Easy/Normal của mini-game Chặn Đạn mà không gặp ức chế thao tác không?
* [ ] **Độ thỏa mãn của Final Shot:** Cú nổ kết liễu sau chuỗi tap liên hoàn có mang lại cảm giác xả stress và giải tỏa cảm xúc trọn vẹn hay không?
* [ ] **Ngữ cảnh Boss khi bỏ Side:** Rà tuyến Main T1–3, T4–7 và T8–12 khi không hoàn thành Side nào. Mỗi Boss đã được giới thiệu; mọi luận điểm, tư liệu và đáp án bắt buộc đều có nguồn trong Main. Đặc biệt kiểm tra bỏ Side căng tin T1, kinh phí sự kiện T7, đối thoại Huy T10 và in ngầm T11.
* [ ] **Mốc chuyển Hồi:** Boss lần lượt ở T3, cuối T7 và T12; T8 là hậu quả trận Linh và mở xung đột Huy. Không lấy dữ kiện 2011/2026 chỉ mở ở Main T9–11 để yêu cầu giải thích đầy đủ ở trận T3.
