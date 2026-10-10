# Source responsibilities and migration coverage

Reviewed 2026-10-10. Source checkout remains read-only. Technical IDs are retained.

| Source | Target responsibility | Treatment / coverage |
| --- | --- | --- |
| content/gameplay/definitions.js, balance.js, presentation.js, migrations.js | content/gameplay/pack.json | Captured roster, stats, cases, steps, phases, places, tuning, legacy skills; frozen source pack |
| content/maps/definitions.js | content/world/source_maps.json | Reference data: five rooms, targets, portals and club/leisure schedule IDs |
| content/dialogue/interaction-scenes.js | content/dialogue/graphs.json | Nine keyed mock graphs; validated edges/speakers; runtime dialogue traversal is Chapter 06/08 |
| src/domain/calendar.js, people.js, actions.js | domain/gameplay calendar, people, events | Port: clock, fatigue, availability, guards, costs and structured events |
| src/domain/session.js | gameplay_state.gd, gameplay_rules.gd | Port current calendar subset, final day and sleep preparation; pure injected definitions |
| src/domain/journalism.js | research_actions.gd, nightly_work.gd, publication.gd | Port open/assign/approve/select and nighttime hooks required by sleep; quest/write/summary deferred to 07/08 |
| src/domain/personal.js | gameplay_rules.gd activity branch | Port rest/investigation entry only; job/train/hangout/date/gift/tool/boost/upgrade deferred to 08 |
| src/domain/validateSave.js | state_validation.gd, record_validation.gd, state_migration.gd | Rebuild for v3; migrate v1/v2 fields before validation; persistence/envelopes remain Chapter 09 |
| src/application/GameSession.js | application/game_session.gd | Existing ownership contract retained, now exercised with real gameplay |
| src/pixel/maps.js, PixelWorld.js, world/ and animation.js | world/rooms/newsroom/, world/actors/ | Rebuild spatial presentation in 3D; preserve room/target IDs and atlas frame registration |
| assets/pixel/atlas.json, pilot-v2/v5/v6 | assets/actors/, content/world/actors.json | Reuse unchanged Khuê/Vân sheets, clip timing and pivots; retain selected generation inputs |
| coastal-dialogue-ui.json, UI v3 masters/exports | content/ui/dialogue.json, coastal views, art baker | Rebuild native Controls; compile text-free SVG/filter art; attached decorations retained |
| coastal UI HUD and measured concept | content/ui/hud.json, hud_view.gd | Rebuild date/status/objective/prompt; HUD geometry is an initial implementation with visual gaps |
| src/presentation/, src/ui/, HTML shells | controllers/, views/, bootstrap/ | Rebuild local model/signals/input; no DOM or JavaScript runtime |
| src/core/, formula sandbox packs | Separate formula_sandbox ruleset | Reference only; port remains Chapter 10 |
| SaveService / GameplaySaveService | Future infrastructure save adapter | Defer to Chapter 09; no incomplete storage implementation |
| game_story_bible.md | docs/reference/hai-vong/ | Reference only; proposal and canon labels preserved |
| archive/clb-hoi/ | No target runtime responsibility | Historical snapshot; never edited or imported |

Oracle coverage: seven captured traces / 77 commands. Six current-domain traces /
71 commands compare every accepted/rejected intermediate state and emitted event.
The quest/write trace is captured for Chapter 07 and is deliberately not counted
as ported. Four existing gameplay-policy baselines and eight formula-policy
baselines are unchanged reference evidence, not completed parity runs.

Source maps store schedule presentation tags, not production NPC calendars. The
greybox uses one authored NPC; future controllers supply availability/visibility.
