# Chapter 03 — Phòng CLB blockout 2.5D

Trạng thái: technical greybox verified. Phụ thuộc: 00 và room/interaction IDs từ 01.
Mục tiêu: thử spatial/camera thật bằng greybox, không cần production art.

## Work packages

- [x] C03.01: dựng room scene với sàn/tường/cửa, bàn/tủ/cửa sổ đơn giản và lối đi.
- [x] C03.02: actor proxy dùng CharacterBody3D, collision trên XZ, tốc độ từ spatial config.
- [x] C03.03: input actions có WASD/arrows/interact/menu; world nhận quyền input
  được inject, không đọc modal hoặc session singleton.
- [x] C03.04: so perspective FOV nhỏ và orthographic; khóa room scale, camera angle,
  framing/horizon và screen-space actor size bằng captures.
- [x] C03.05: Area3D/interaction targets emit IDs, một spawn và một portal contract
  có safe fallback; không tạo scene-transition framework.
- [x] C03.06: ánh sáng nắng đơn giản qua window geometry, shadow/readability smoke.

## Đầu ra

Scene/script pairs dưới `src/world/rooms/newsroom/`, actor/movement/camera cụ thể,
room preview composition và camera fixture. Concept HUD/map là hướng bố cục;
không dùng background PNG như room có geometry.

## Exit gate

Đi quanh bàn không xuyên collider, camera ổn khi resize, interaction target IDs
đúng và có screen-space anchor. World preview không cần domain/session. Walking
không đổi day/energy. Ghi still/video và device; parity art không cần ở greybox.

## Handoff

Chapter 04 thay actor proxy bằng sprite. Các blocker về camera/readability phải
được giải trước khi sản xuất hàng loạt room assets.

Implementation/evidence: [review Chapter 01–05](../../reviews/chapters-01-05/README.md).
