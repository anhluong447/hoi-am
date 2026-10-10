# Chapter 00 — Foundation

Trạng thái: foundation verified; kết quả checks ở [review](../../reviews/foundation.md).
Mục tiêu: tạo project có thể phát triển lâu dài mà không port gameplay giả.

## Work packages

- [x] C00.01: xác nhận source/target tách biệt, ghi source commit và import inventory.
- [x] C00.02: Main composition, WorldRoot/Interface riêng, boot scene chạy qua content.
- [x] C00.03: catalog JSON, TextCatalog inject, missing-key/parameter contract.
- [x] C00.04: GameSession ownership với transition/validator inject; snapshot/results deep copy.
- [x] C00.05: architecture/reference checks và headless contract/boot tests.
- [x] C00.06: docs mới, chapter roadmap, art scope, chọn reference/baseline/font.
- [x] C00.07: init Git repository độc lập trên main.

## Exit gate

Checks và boot pass; không có domain mechanics/world art đã port; catalog không
hardcode ở scene/script. Source checkout không thay đổi. Evidence nói rõ boot
smoke khác với visual/GPU/export acceptance. Chốt file ownership trước khi thêm feature.

## Handoff

Chapter 01 tiếp tục inventory chi tiết và domain packs. Foundation chưa có content
schema/gameplay validator, persistence, controllers, navigation hay lighting framework.
Không cần hoàn thành bốn UI concept để bắt đầu oracle/domain.
