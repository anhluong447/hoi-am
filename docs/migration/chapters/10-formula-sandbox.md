# Chapter 10 — Sandbox công thức độc lập

Trạng thái: chưa bắt đầu. Phụ thuộc: Chapters 01/02; có thể làm sau M2/M3.
Mục tiêu: giữ công cụ đo công thức cũ trong Godot, không nhập luật vào gameplay.

## Work packages

- [ ] C10.01: nhập balance/fixtures/policies sandbox với technical IDs và catalog keys.
- [ ] C10.02: port core rules/math, fatigue/quality/score/evidence/pressure và calendar
  riêng; giữ thứ tự weekly processing, emergency strike, recovery và endings.
- [ ] C10.03: validator/session riêng cho formula_sandbox; dùng cùng ownership API
  nhưng không dùng gameplay schema hoặc handlers.
- [ ] C10.04: port 8 benchmark policies, trace edge cases và comparator; report đúng
  baseline cố định, không coi source historical sym.py là oracle cao hơn rules hiện hành.
- [ ] C10.05: authoring/debug scene chạy riêng; test runner callable headless, không
  đưa knobs mô phỏng vào flow chính của người chơi.
- [ ] C10.06: save envelope isolation và formula preview/publication dùng cùng pure math.

## Đầu ra

`src/domain/formula_sandbox/`, `content/formula_sandbox/`, deterministic benchmark
runner và tool scene. Không cần sao chép giao diện debug HTML theo pixel.

## Exit gate

8 policies khớp mọi field baseline; domain boundaries đúng; gameplay tests vẫn
pass độc lập. Numeric tolerance có evidence; không merge hai lịch/tập stat vì
tên cùng giống nhau. Source baseline/mock limitations giữ nguyên ý nghĩa.

## Handoff

Sandbox phục vụ đo mechanics và intentional design changes sau migration, không
chứng nhận các heuristic tối ưu hoặc narrative/ending cuối game.
