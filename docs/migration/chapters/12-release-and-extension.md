# Chapter 12 — Quality, export và further development

Trạng thái: technical release/extension handoff đã kiểm chứng; visual gates xem review.
Phụ thuộc: Chapters 09/10/11 và các parity reports.
Mục tiêu: project tự đủ, có quy trình thêm feature/content và native build được kiểm tra.

## Work packages

- [x] C12.01: clean import trên clone mới, no-cache boot và tests; repo giữ source,
  UID/content/assets/licenses nhưng không phụ thuộc .godot hoặc absolute machine paths.
- [x] C12.02: gameplay/formula parity suite, integration save/load/scene/disposal,
  keyboard/controller focus, long text và các viewport/tỷ lệ uniform fit.
- [x] C12.03: Forward+ native profiling CPU/GPU/frame-time/memory/loading trên device
  ghi rõ; xác lập budget/target 60fps và quality tiers bằng số đo thực.
- [x] C12.04: export templates/preset, JSON include filters, license distribution,
  native release/debug và chạy từ folder sạch không source checkout/Node/Python.
- [x] C12.05: test export save paths, missing resources/font glyphs, failure UI,
  logging và content-version compatibility; exported app không chỉ editor pass.
- [x] C12.06: extension rehearsal: thêm một room nhỏ, NPC/dialogue graph và case
  qua content/scene workflow, không đổi core boundary hoặc tạo engine framework.
- [x] C12.07: docs handoff, remaining visual/game-design gaps, inventory archive các
  target artifacts đã obsolete, kiểm tra moved bytes/links; source giữ nguyên.

## Đầu ra

Export preset và build instructions, test/performance/visual acceptance report,
content authoring guide được thử thực tế, migration ledger cuối và backlog production.

## Exit gate

Native build chạy độc lập; logic parity, save compatibility và resource packaging
đã kiểm chứng. Các art/performance gates được ghi đúng trạng thái, không claim
production complete nếu còn gap. Repo có lịch sử riêng và source reference giữ nguyên.

## Sau chapter này

Làm production narrative/cases/rooms, lịch NPC và balance bằng pipeline đã thử.
Chỉ mở rộng abstraction khi feature cụ thể chứng minh duplication; chapter mới
cho thay đổi design/platform có scope/evidence riêng.

## Evidence 2026-10-10

Technical release/extension handoff verified; production visual and broad-device stress gates remain in the final review.

[Review, parity, native captures/video/profile](../../reviews/chapters-06-12/README.md).
