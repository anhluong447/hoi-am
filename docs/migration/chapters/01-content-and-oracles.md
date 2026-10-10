# Chapter 01 — Content và oracle inventory

Trạng thái: content/oracle verified. Phụ thuộc: Chapter 00.
Mục tiêu: khóa dữ liệu/hành vi nguồn trước khi đổi ngôn ngữ và renderer.

## Work packages

- [x] C01.01: lập bảng source module → target responsibility; đánh dấu port/rebuild/reference/defer.
- [x] C01.02: xuất roster, cases, quests, calendar/balance, phase/location và migration IDs
  thành JSON; giữ stable IDs và text keys, không đưa resolved locale labels vào rules.
- [x] C01.03: xuất dialogue graphs và schedules; xác định room/interaction IDs cho blockout.
- [x] C01.04: validate duplicate IDs, stat/actor/case references, graph edges và tuning ranges.
- [x] C01.05: tạo oracle action traces bằng công cụ chỉ đọc source, output vào target;
  lưu initial state, commands, intermediate state, rejection, events và source hashes.
- [x] C01.06: giữ baseline hiện có, lập comparator numeric tolerance `1e-8` và semantic
  ordering contract. Integer/bool/string/IDs phải đúng chính xác.
- [x] C01.07: phân biệt proposal/story canon, mock gameplay và intentional changes trong ledger.

## Đầu ra

`content/gameplay/`, `content/dialogue/`, room metadata tối thiểu, domain content
validators, `tests/fixtures/parity/`, manifest oracle và source mapping. Exporter
chỉ là migration tooling; runtime Godot không import hoặc eval JavaScript.

## Exit gate

Pack validate độc lập; IDs không phụ thuộc dịch; ít nhất traces cho ngày/phase,
invalid command, assign/reassign, publication một lần và weekend. Oracle có provenance,
không overwrite baseline. Source tree giữ nguyên, target load pack không cần source.

## Quyết định cần review

Labels hiện eagerly resolved và embedded trong source saves: giữ compatibility
fields trước, chuyển sang ID-only có migration riêng. Không tiện tay rename IDs
để làm JSON đẹp. Room art và camera chưa là điều kiện của chapter này.

Implementation/evidence: [review Chapter 01–05](../../reviews/chapters-01-05/README.md).
