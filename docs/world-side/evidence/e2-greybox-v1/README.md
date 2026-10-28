# E2 greybox v1 — historical, visual regression found

Captured 2026-10-28 by `tests/native_side_rooms.gd` through
`python tools/verify_native.py --godot <Godot 4.7.2> --side-output
res://docs/world-side/evidence/e2-greybox-v1`.

The native walkthrough passed 257 checks, wrote 28 captures, and the subsequent
interaction/dialogue/HD-2D suites passed. This version is **not E2 visual acceptance**:
review of the screenshots found that walking from club into school changed the
controller location but left the HUD location label showing the club. The suite
did not yet assert the rendered location label. A headless regression test then
reproduced the problem (1127 checks, one failure).

The fix refreshes the HUD only after a successful side-room mount. Evidence after
the fix is recorded separately; these captures and `report.json` remain unchanged.

Each PNG is a 1920×1080 window-sized image: the native 1918×1080 viewport is copied
without scaling and the two black KEEP letterbox columns are restored. Lighting is
selected for review without changing the gameplay calendar; the HUD still shows
the original gameplay phase. Actors and scenery are greybox silhouettes/rectangles.
Wall-clock samples at cap 60 are informational and do not establish GPU or iGPU performance.
