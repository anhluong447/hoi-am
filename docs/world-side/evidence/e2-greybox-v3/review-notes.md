# E2 implementation and review notes

One independent, read-only whole-branch review covered the E0–E2 work, with focus on
legacy saves, locked doors, non-finite/out-of-bounds spawn values, duplicate door
requests, room disposal and reduced motion enabled before mounting. No second
review round was used; fixes were verified by regression tests and the full suite.

## Corrections verified

- Cross-location doors mounted the correct room/controller but left the rendered HUD
  location stale. A new regression failed at 1127 checks/one failure. Refresh only
  after successful room mount; headless and per-room native label checks now cover it.
- A v1 world with an extra `x` but no `facing` passed validation and entered the v2
  decoder. The reviewer called this Minor; the implementer raised it to Important
  because accepted imported data produced a script error after progression replacement.
  Regression reproduced that error; restore now gates x/facing decoding on version 2.
  The full verify gate passed 1129 checks with no engine errors after correction.
- Native viewport captures omit KEEP letterbox columns. The first run failed all
  28 dimension assertions; capture now preserves rendered pixels and restores only
  the black letterbox on the window-sized output canvas.
- An incomplete native attempt encountered an unexpected workspace instead of
  dialogue. Short and full-prelude reproductions passed, so no runtime cause was
  claimed. The harness isolates OS focus/mouse input, guards modal types, stops on
  first route failure, and refuses duplicate room captures. Version 2 stays archived.
- The existing native UI fixture subsequently reproduced unstable rebuilt focus and
  duplicate `draft` requests. The captured preview was rebuilding controls inside
  the button callback. Deferring its configure call until GUI dispatch finishes
  made the existing pointer/focus test pass all 68 checks; production dialogue
  composition and command handling were not changed. All synthetic native suites
  now isolate unrelated OS focus/mouse input during their fixtures.

## Decisions retained

- Continue the existing feature branch with its in-flight edits; no new worktree,
  main-branch merge or push. Moving the edits would have split ownership.
- Domain gameplay/formula rules and accepted coastal UI composition remain in scope
  as previously defined; scene rooms own spatial state, not calendar/energy/saves.
- World saves use world v2 for both side `x/facing` and HD-2D `position`; the outer
  save envelope stays v1. Generated v1 and legacy imports keep their documented
  location/default-spawn fallback; no 3D-to-2D coordinate conversion is inferred.
- Doors with target_room use that destination room and derive its location from
  content; location-only doors use travel. Tuning is required and validated before mount.
- Actor and interaction IDs have distinct namespaces so Van can name both. Door
  labels are optional catalog keys. The domain club phase maps to afternoon lighting.
- E1 closes with partial RTX reference data and casual defaults chosen by design.
  The user's decision to stop profiling and defer iGPU measurement still applies.
- Painted art, textured actor polish and beauty-corner work belong to E3 after the
  user's E2 review. Imported design bytes and historical baselines are not normalized.

## Deferred minors

- `report.viewport_texture` describes the end of the run, not each PNG source at
  capture time. Capture dimensions and unscaled fit are asserted, and the README
  explains this metadata limitation. Per-capture source-size metadata is future polish.
- Earlier reviewed prototype limitations remain: historical HD-2D profiler defaults
  to the old club path; rejected authored content uses a debug assertion; textured
  actor/right-limit parallax/occlusion sampling can be strengthened when E3 exercises
  painted assets. These do not establish production art or performance acceptance.

The reviewer set aside iGPU performance (explicitly deferred), final painted art
(E3), immutable imported whitespace, the actively investigated one-off native probe,
and documents still being finalized at review time. The implementer retained the
first three boundaries, documented the probe without claiming its cause, and
completed the technical handoff documents after verification.
