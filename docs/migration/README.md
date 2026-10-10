# Roadmap migration theo chapter

Ngày: 2026-10-10. Source hai-vong giữ nguyên; target hoi-am phát triển độc lập.
Mục tiêu cuối: game Godot chạy không cần JavaScript/HTML, world 2.5D và UI coastal,
gameplay có đối chứng. Không xem skeleton, concept hoặc proposal là demo hoàn chỉnh.

## Cách thực hiện

Mỗi chapter có một bản chạy/review được, đầu ra cụ thể, dependency và exit gate.
Trạng thái chi tiết ở [status.json](status.json); evidence ở [reviews](../reviews/foundation.md).
Làm một work package nhỏ mỗi lần; không tạo sẵn các hệ thống chưa có nhu cầu.

Port parity và thay đổi gameplay là hai loại công việc riêng: port phải giữ baseline,
thay đổi phải ghi lý do, tác động và evidence. Có thể đổi cấu trúc module/API khi
vẫn giữ contract, IDs và kết quả. Không hứa số tuần khi art/content chưa được đo;
ước lượng sau từng chapter bằng khối lượng thực tế và tốc độ đã quan sát.

| Chapter | Nội dung | Phụ thuộc | Đầu ra chính |
| --- | --- | --- | --- |
| [00](chapters/00-foundation.md) | Foundation và repo boundary | Project Godot mới | Boot, text/session contracts, checks/docs |
| [01](chapters/01-content-and-oracles.md) | Content và oracle inventory | 00 | Structured packs, action traces, parity fixtures |
| [02](chapters/02-gameplay-domain.md) | Gameplay domain | 01 | Calendar/session/validation và commands đầu tiên |
| [03](chapters/03-world-blockout.md) | Room blockout 2.5D | 00, room IDs từ 01 | Phòng CLB greybox đi được, camera/interaction |
| [04](chapters/04-actors-and-camera.md) | Sprite actors và camera | 03 | Actor rig, hướng đi, occlusion/shadow tests |
| [05](chapters/05-ui-foundation.md) | UI coastal tĩnh | 01 | Dialogue/HUD độc lập, text/focus/scale |
| [06](chapters/06-first-playable.md) | First playable | 02, 04, 05 | Khám phá → nói chuyện → command → HUD |
| [07](chapters/07-newsroom-systems.md) | Nghiệp vụ tòa soạn | 02, 06 | Cases/team/editorial/publication và policies |
| [08](chapters/08-personal-and-narrative.md) | Đời sống, quest và dialogue | 07 | Personal loop, quest/story conditions, menu/dossier |
| [09](chapters/09-saves-and-compatibility.md) | Save/load và compatibility | 07, 08 | Versioned save, import cũ, safe restore |
| [10](chapters/10-formula-sandbox.md) | Sandbox công thức riêng | 01, 02 | Oracle công thức và 8 policies đúng baseline |
| [11](chapters/11-art-and-atmosphere.md) | Art, atmosphere và motion | 04, 05, 06 | Production sample room/UI, visual evidence |
| [12](chapters/12-release-and-extension.md) | Quality, export và mở rộng | 09, 10, 11 | Native build độc lập, test/performance handoff |

03/04 và 05 có thể tiến triển độc lập với port domain sau khi IDs đã ổn định;
đây là các track công việc, không yêu cầu chạy nhiều agent. Không để việc dựng
phòng giống concept chặn UI isolation; không để polish UI chặn domain parity.

## Các mốc review lớn

- M0 — sau 00: mở project, checks pass, ownership/text boundaries rõ.
- M1 — sau 02: domain chạy headless với traces, không cần scene.
- M2 — sau 06: một vòng tương tác nhỏ chạy thật trong world 2.5D.
- M3 — sau 08/09/10: các tính năng port có parity, save và hai ruleset tách biệt.
- M4 — sau 11: production art/motion sample có visual review riêng.
- M5 — sau 12: exported build tự đủ, budget/device evidence và extension workflow.

Full gameplay parity chỉ được tuyên bố khi các policy/trace thực sự được port và
so sánh. Baseline source chứa mock gameplay, không chứng nhận cân bằng/narrative
production. UI/world acceptance vẫn có thể còn mở dù logic đã đúng.

## Definition of done dùng chung

Code/content thực thi, architecture/reference checks pass, targeted tests pass,
dependency và migration notes cập nhật. Với world/UI: ghi rõ camera/fixture/viewport,
still hoặc video review và visual gaps. Với schema: validator + migration + corrupt
fixtures. Với art: source/license/hash/pivot/import settings. Với export: chạy ở
folder sạch không có source checkout. Không overwrite lịch sử để làm checklist xanh.

## Hướng đi sau migration

Migration tái hiện behavior hiện có; nội dung cuối game, lịch NPC production,
balance cuối và ending canon là workstream thiết kế/sản xuất tiếp theo. Bản bible
giữ các nhãn proposal/đã chốt; không tự biến mọi mục thành backlog đã được duyệt.
New rooms/content dùng pipeline ở Chapter 12, không đổi module boundary tùy từng map.
