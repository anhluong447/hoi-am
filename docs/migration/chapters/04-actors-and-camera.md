# Chapter 04 — Sprite actors, camera và chiều sâu

Trạng thái: actor rig reviewed; pilot art quality open. Phụ thuộc: Chapter 03.
Mục tiêu: một actor sprite đọc rõ, đi và bị che tự nhiên trong cảnh 3D.

## Work packages

- [x] C04.01: nhập sprite có provenance, frame/tag/duration/pivot và nearest filtering;
  asset pilot nguồn chỉ là candidate, chưa coi animation review đã pass.
- [x] C04.02: dựng actor rig: collider/body và AnimatedSprite3D riêng; hướng nhìn
  và animation frame chọn theo movement/camera, không theo tên đã dịch.
- [x] C04.03: thử fixed orientation hoặc Y-billboard, alpha cut/scissor/depth và
  projected pixel size; capture trước/sau bàn, gần tường và trước cửa sổ.
- [x] C04.04: review nhận sáng và bóng của sprite; so shadow proxy/contact shadow
  với shadow plane để tránh silhouette tấm bìa.
- [x] C04.05: NPC với authored target IDs/schedule presentation từ model; local
  idle/walk không tự advance gameplay hoặc tính outcomes.
- [x] C04.06: khóa camera/actor registration; thử floor elevation chỉ khi room thật cần.

## Đầu ra

Actor scene/script nhỏ, imported sprite manifest, camera preset và readability
review. Tái sử dụng art được chọn, giữ atlas/source cũ; không regenerate sprite
toàn cast chỉ để chạy proof of concept.

## Exit gate

Idle/walk/interact không jitter/sliding rõ rệt; occlusion/alpha và shadows được
review trên Forward+; pixel density nhất quán. Input lock hoạt động, world không
import application/domain. Art quality còn mở phải ghi riêng với technical pass.

## Handoff

Rig phục vụ first playable. Thêm animation states/expressions sau khi có nhu cầu
dialogue/story thực tế, không dựng animation engine tổng quát.

Implementation/evidence: [review Chapter 01–05](../../reviews/chapters-01-05/README.md).
