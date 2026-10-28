# First three days acceptance chapter

The player entry selects `content/first-three-days.project.json` / `runtime.first3`.
`content/project.json` / `runtime.foundation` retains the isolated mechanics fixture.
Both use the same validated pack, resources and generic runtime. This is a Phase 0
acceptance chapter, not all of week 1 or a production art milestone.

The user's source is preserved at `docs/history/narrative/First3Days.md`, SHA-256
`f55787d3363ee2fb9a82e4ca171a67cf713b6dc2475924005d1d548aae3b2d30`.
The finalized Bible/GDD govern conflicts. No protected design document was rewritten.

| Source scene | Managed chapters / physical spaces | Acceptance behavior |
| --- | --- | --- |
| 1.1 transfer | `arrival`; gate → discipline office | Tran, transfer, grandfather's notebook/card |
| 1.2 class | `long`; classroom 11A3 | Long and introduction to the newspaper club |
| 1.3 recruitment | `recruit`; corridor C → Room 3 | Van, threatened Friday closure, Main notice/custody route |
| Day boundary | `rest1`; home | Explicit sleep advances to day 2; walking never advances time |
| 2.1 cabinet | `tape`; Room 3 cabinet | Cassette 2011 remains an unresolved lead |
| 2.2 Van | `tape`; Room 3 | Fear of abandonment, commitment to the club |
| 2.3 Long's lead | `plan`; Room 3 | Accept or skip canteen Side; separate short General delegated to Long |
| Day boundary | `rest2`; home | General completes through normal delegated work; day 3 begins |
| Optional fieldwork | `side-photo`, `side-source`; canteen | Collected photograph and source verification earn one high-quality Defense card |
| 3.1–3.2 pressure | `pressure`; Room 3 | Khoa intimidation and camera bluff; Main-only alternative if Side skipped |
| 3.3 advisor | `advisor`; Room 3 | Nguyen's support/lamp, Main complete, materials queued, Friday still ahead |

The exact source depicts completed canteen work before the confrontation. Here it
is optional to honor the Bible: the skipped route argues from the notice and Room 3
rights and invents no canteen facts. The empty-film bluff never earns a photograph
or evidence. Khoa's day-3 intimidation is narrative pressure, not the week-3 Boss.
The early cassette does not resolve the 2011 investigation. Publication is automatic;
there are no manual writing/editing/printing tasks after quest completion.

All authored JSON is under `content/dev/first-three-days/`; visible strings are in
the shared locale catalogs. Eleven independent story documents use stable node and
command anchors. Seven scenes define bounds, doors, placements and interactions.
Quests, schedules, events, flags, tuning and team names are managed definitions.
The separate routine General concerns club activity schedules and does not delegate
the optional canteen Side. General's standard Defense card exists even when Long
performs the work. Audience stays unchanged until the automatic publication boundary.

Friday publication and Defense/Attack acceptance use the maintained, isolated
`playtest.fixture.hearing` commands. They are not squeezed into these three days.
The original geometric art and tone are labelled fixture resources with tracked
provenance and recoverable masters. Hand-drawn/anime visual approval remains future work.

## Author and verify

Use [ADDING-CONTENT.md](ADDING-CONTENT.md) and the shared Workspace editors/imports.
The editable JSON documents are authoritative; ignored one-time bootstrap helpers
must not overwrite later source edits. New mutually dependent documents can be
committed as one validated Workspace group, then saved as an atomic source group.

`tests/authoring/first3-pipeline.test.js` creates a new scene/NPC, quest, branch,
flag, schedule and strings on an isolated copy of the real chapter. It exercises
dependency rename/removal, grouped undo/redo, actual IndexedDB draft recovery,
rejected invalid references, explicit preview restart, stable-anchor hot reload,
runtime Canvas/NPC rendering and traversal. The Python companion sends that exact
dirty-document payload to the authenticated source writer, reopens the saved bytes
and checks stale-write and invalid-flag preservation. This test content does not
change the approved story or player saves.

`tests/browser/foundation-journey.test.js` walks both complete routes using native
keyboard input and a controlled correctness clock. `tests/release/first3.test.js`
does the same against the read-only static artifact's own modules/content/assets,
including native keyboard slot save/load at day 2 and the ending. Its clock is not
FPS evidence. `tests/release/export.test.js` separately tests the actual index entry
and samples real RAF timings. Run the complete gates with:

```powershell
.venv/Scripts/python.exe -B -X utf8 tools/ci.py
```

Bot entry seeds in `traversal.json` are authoring-only references to valid playtest
fixtures. They replay actual gameplay/story commands to earn prerequisite state;
they do not inject rewards or silently omit guarded branches. Both pressure seeds
are required, covering Side and Main-only variants. Coverage lists remaining
unexplored paths explicitly and fails the acceptance gate if any remain.

The content migration `0.0.1 → 0.0.2` adds the declared 17 flags and 3 quest records
without overwriting existing progress or execution receipts. RunSnapshot stays 3:
only entries in already-defined collections are added. The genuine old-save fixture
was captured from commit `1dfce841e8447a20ccfe55e31096c8ccce3382f8` using its actual
runtime/SaveService, with provenance embedded in the fixture. It continues the old
mechanics scene rather than teleporting an old run into a different narrative.
