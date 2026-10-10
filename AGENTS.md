# Hoi Am project instructions

- This is the independent Godot migration target. Never modify `../hai-vong/`
  during migration. Read `docs/ARCHITECTURE.md`, `docs/DEVELOPMENT.md`, and the
  current chapter in `docs/migration/` before changing module boundaries.
- No player-facing literals in GDScript, scenes, resources, shaders, or UI shells.
  Author text in `content/locales/vi.json`; resolve it through `TextCatalog`.
  Technical IDs, paths, and developer diagnostics are allowed. Do not bake
  readable text into images. Keep `config/name` technical; set window titles
  from the catalog.
- Definitions, tuning, dialogue, and authored layouts belong in `content/`.
  IDs never depend on translated labels. Resolve display text at view time.
- Follow the dependency rules in `docs/ARCHITECTURE.md`. Domain code uses plain
  data and RefCounted, never scene nodes, file/storage/network/input APIs, clocks,
  or ambient randomness. Preserve gameplay and formula-sandbox as separate rulesets.
- Commands go through `GameSession`. Transitions preserve their inputs; callers
  cannot mutate owned state through snapshots/results. Validate before replacement.
  New save fields require a validator, version/migration review, and fixtures.
- Composition owns dependencies; scenes own local nodes and emit local signals.
  No global session singleton, global event bus, service locator, speculative ECS,
  generic command framework, or empty feature implementations.
- Keep scene and script together. Use snake_case paths and one focused role per
  runtime file. Split runtime files before exceeding 200 nonblank lines.
- Run `python tools/check_architecture.py` and `python tools/check_reference.py`.
  For runtime/content changes, also run `python tools/verify.py --godot <exe>`.
  Report checks actually run. Headless smoke does not establish visual parity,
  Forward+ GPU performance, or successful native export.
- Keep imported reference bytes and baseline evidence unchanged. Never regenerate
  baselines to make a port pass. Log intentional behavior changes separately.
- Follow `docs/ART-DIRECTION.md`: fixed coastal UI and its attached flowers,
  notebook, and harbor art remain in scope. World 2.5D has its own acceptance
  track; scene/portrait similarity must not block isolated UI gates.
- Do not delete obsolete art or source inputs without inventory, byte verification,
  and repaired references. Archive historical evidence rather than overwriting it.
