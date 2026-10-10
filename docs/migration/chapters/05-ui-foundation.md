# Chapter 05 — UI coastal tĩnh và preview

Trạng thái: behavior verified; static G2 visual open. Phụ thuộc: Chapter 01; không phụ thuộc world art.
Mục tiêu: dialogue/HUD cấu trúc đúng, độc lập scene, rồi nghiệm thu UI tĩnh.

## Work packages

- [x] C05.01: kiểm kê pack UI source, chọn layer/texture/font/license/prompt cần nhập;
  thử SVG phức tạp trước, bake art-only PNG hoặc shader/material khi phù hợp.
- [x] C05.02: port dialogue paper/wave/harbor/flowers/notebook, text và choice targets
  thành scene nhỏ; portrait/background là slot thay được.
- [x] C05.03: giữ native plane 1672×941, uniform scale/letterbox, focus keyboard,
  pointer targets và plain text tiếng Việt, không scene/image text literals.
- [x] C05.04: dựng HUD date/energy/money/objective/controls từ view model; preview
  fixture độc lập, không hardcode số gameplay trong view.
- [x] C05.05: world-to-screen anchor adapter cho prompt, xử lý off-screen/occlusion;
  không yêu cầu exact room art để kiểm tra prompt và fixed HUD.
- [x] C05.06: isolated captures neutral/bright/dark/detailed, reference masks và
  typography/alpha/material gaps. Source G2 còn mở được xử lý, không tự kế thừa pass.

## Đầu ra

Dialogue/HUD scene-script pairs, theme/font roles, content UI compositions và
preview entry/fixtures. Asset manifest chỉ những file thực sự runtime sử dụng.

## Exit gate

Behavior: model/signal/input/focus/scale pass. Visual: review UI riêng, attached
decorations giữ đúng scope; background/actor identity không chặn. Nếu G2 chưa
đóng, first playable dùng UI có gaps được ghi rõ; chưa nhận là production art.

## Handoff

Menu/dossier hoàn thiện ở Chapter 08; motion sau static geometry/type ổn định
trong Chapter 11. Không animate domain commands hoặc chờ animation mới commit state.

Implementation/evidence: [review Chapter 01–05](../../reviews/chapters-01-05/README.md).
