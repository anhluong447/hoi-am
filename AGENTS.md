# Hoi Am project instructions

- This is the independent Godot migration target. Never modify `../hai-vong/`
  during migration. Read `docs/ARCHITECTURE.md`, `docs/DEVELOPMENT.md`, and the
  current chapter in `docs/migration/` before changing module boundaries.
- Since 2026-10-28 ([ADR 005](docs/decisions/005-side-scroll-2d.md)) the world
  direction is Godot 2D side-scrolling, high-res painted cinematic art, no pixel
  art. New world code lives in `src/world/side/`, content in `content/world2d/`.
  Imported design docs from hai-vong (`feat/first3-art-direction`) are the
  current authoring reference, kept byte-exact under `docs/design/` with
  provenance in `docs/design/SOURCES.json`. HD-2D (ADR 004) is archived, not
  deleted, and is not the forward direction; do not build new HD-2D content.
  Use the `making-story-side-scrollers` skill when planning a side-scroll
  scene, chapter, or vertical slice.
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
  Run `python tools/check_content.py` for current packs/art/oracle integrity.
  For runtime/content changes, also run `python tools/verify.py --godot <exe>`.
  Report checks actually run. Headless smoke does not establish visual parity,
  Forward+ GPU performance, or successful native export.
  World/UI changes also require `tools/verify_native.py --godot <exe>` plus new
  visual evidence when geometry/art changes; preserve historical capture versions.
- Keep imported reference bytes and baseline evidence unchanged. Never regenerate
  baselines to make a port pass. Log intentional behavior changes separately.
- The user accepted the current dialogue UI layout/art on 2026-10-11. Dialogue
  animation work preserves that composition; historical static pixel diagnostics
  do not block motion work. Keep timing/offset/scale in content and world input
  locked through the dialogue exit; one reveal click must not dispatch a choice.
- Follow `docs/ART-DIRECTION.md`: fixed coastal UI and its attached flowers,
  notebook, and harbor art remain in scope. World 2.5D has its own acceptance
  track; scene/portrait similarity must not block isolated UI gates.
- Do not delete obsolete art or source inputs without inventory, byte verification,
  and repaired references. Archive historical evidence rather than overwriting it.
