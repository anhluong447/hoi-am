# Chapter 11 — Production art, atmosphere và motion

Trạng thái: asset/effect/motion pipeline sample đã kiểm chứng; C11.05 G2 còn mở.
Phụ thuộc: Chapters 04/05/06; không chờ full logic port
để thử một asset/light sample có giá trị. Mục tiêu: khóa pipeline sản xuất bằng
một phòng và một bộ UI trước khi mở rộng số lượng assets.

## Work packages

- [x] C11.01: chọn style texture/mesh/pixel density từ blockout và concept; module room
  kit cụ thể gồm floor/wall/window/desk, source file, license và import settings.
- [x] C11.02: production sample phòng CLB: texture/mats, props chính, harbor backdrop
  có chiều sâu phù hợp camera. Không dựng toàn thành phố trong chapter này.
- [x] C11.03: nắng cửa sổ, cool ambient/warm local lights, shadow quality/occlusion;
  so baked/static với dynamic lights theo nhu cầu gameplay/device budget.
- [x] C11.04: dust/sea shimmer/DOF/fog/glow/grade từng effect có A/B và budget;
  đọc sprite và UI ưu tiên hơn effect density. Không blur text UI.
- [ ] C11.05: UI correction paper/type/icons/flowers/notebook/harbor/light, đóng static
  gaps trước motion của màn đó; masks/uncertain alpha ghi rõ.
- [x] C11.06: AnimationPlayer/Tween theo feature: enter/choice/page/ambient transitions,
  cancel/replay/reduced motion; callback gameplay không chờ animation xong.
- [x] C11.07: still/video review và performance capture trên máy thật, world/UI riêng;
  giữ screenshot/prompt/source/manifest versions, không overwrite evidence cũ.

## Đầu ra

Room asset kit, sprite/shadow standards, production font/theme/material set,
motion presets và art/static/motion review theo screen/room.

## Exit gate

Visual review xác nhận đúng scope; art/licensing nguồn đầy đủ; readability khi
đi/bị che/chuyển scene, stable text/hitboxes và interruptible motion. Device cost
được ghi, không suy GPU/FPS từ headless hay video encoding.

## Handoff

Mở rộng room/character cần budget và pipeline đã khóa. Những hướng chưa chốt
đưa vào art/design ledger, không coi cảm hứng Octopath là spec kỹ thuật hoàn chỉnh.

## Evidence 2026-10-10

Room kit/effects/motion sample and native A/B/profile completed. C11.05 exact static visual parity remains open; no production-art acceptance claim.

[Review, parity, native captures/video/profile](../../reviews/chapters-06-12/README.md).

UI correction pass tiếp theo đã thay HUD panel bằng khung mực/ngày tháng/nhiệm vụ,
gauge năng lượng thật, typography theo weight, notebook affine và paper wash;
sửa glyph/icon khi dựng lại view, text dài và prompt sát mép. 655 headless checks,
53 native checks ở năm window sizes và 22 captures mới có trong
[review UI upgrade](../../reviews/ui-upgrade-2026-10-10/README.md).
C11.05/G2 vẫn mở: dialogue comparison là diagnostic trên mask bảo thủ,
chưa có ngưỡng nghiệm thu hoặc xử lý toàn bộ fringe/occluded alpha.

## UI correction 2026-10-11

Selected choice có ink/weight riêng, focus giữ đúng choice ID khi configure lại;
composition giữ font weights bất biến theo layout. Paper/harbor wash và cạnh HUD
có source/PNG v4–v5, mask và baseline cũ không đổi. 661 headless checks và
64 native checks, 24 captures có kiểm pixel cho glyph/icon ở cả selected/idle.
Dialogue diagnostic giảm từ 23.422 xuống 22.303/255 trên mask gốc; từng vùng
có cải thiện hoặc regression được ghi riêng, không dùng MAE làm gate tự đặt.
[Review và các static gaps còn mở](../../reviews/ui-correction-2026-10-11/README.md).
