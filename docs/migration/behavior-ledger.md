# Behavior and scope ledger

2026-10-10. No gameplay tuning or baseline bytes changed.

| Decision | Reason | Evidence / limitation |
| --- | --- | --- |
| Gameplay state v3 stores name/title/story/teaser keys | Keep translation out of domain and state creation | Explicit [schema decision](../decisions/002-gameplay-state-v3.md), pure v1/v2 migration, semantic source comparison |
| New log params may contain nested text references or numeric format descriptors | Resolve labels and vi grouping only in presentation | Exact rendered event equivalence in six traces; log order preserved |
| Preserve v1/v2 historical rendered log params/messages during migration | Old evidence must remain readable | Validation accepts keyed legacy events and legacy messages; new rules never author translated strings |
| Open/assign/approve/select and nightly work were ported with Chapter 02 | Sleep parity needs work, approval and publication hooks | Assignment/reassignment and publication-once traces; no claim of full newsroom policy parity |
| Previously deferred commands now ported | Complete the source gameplay loop without tuning changes | Quest/personal traces and all four policies including 84 days match full source state |
| World preview has no gameplay clock | Spatial movement is independent of progression | Independent room/session test, native movement/lock checks |
| Preview portal emits destination but returns to safe spawn | Only the newsroom has 3D geometry in this chapter | Destination/portal ID tests; no yard scene or scene-transition framework |
| Orthographic camera is the greybox default | Consistent actor scale through the room | Native perspective comparison retained; production camera remains reviewable |
| Y billboard + capsule shadow proxy is the current actor setup | Maintain standing registration and avoid cardboard shadow silhouette | Fixed/Y and three shadow-mode native captures; art quality remains a pilot |
| Isolated previews own separate fresh sessions/fixtures | Keep review reproducible before Chapter 06 integration | Calendar uses live state; world/UI previews visibly mark fixture status; returning to calendar starts a new session |
| Static UI behavior passes; G2 stays open | Porting the renderer does not certify replica art | Native captures, conservative-mask diagnostic and explicit visual backlog |
| Gameplay native envelope/world versions are separate from state v3 | Keep spatial coordinates out of domain and validate before replace | ADR 003; round-trip, corruption, interruption and legacy import tests |
| Formula state v2 stores text references | Preserve pure domain and translated journal/labels at view time | Eight policies match source full state through explicit display adapter; source role label omitted |
| Formula save supports isolated solo roster | Source simulation supports solo but its save validator rejected it | Native validator preserves full fatigue keys, validates the actual roster and keeps separate slots |
| Prototype travel presents source location IDs without consuming slots | Domain command contract contains no travel cost | Personal action lists follow source location mapping; room geometry is authored sample/prototype |
| Native portals use authored location destinations | Keep prototype connectivity out of runtime hardcoded routing | Room switches preserve quality settings; prompts read the mounted room and unsafe vertical save positions fall back to spawn |
| Reading-room extension stays in its F6 scene | Rehearse extension without altering baseline gameplay content | New room/NPC/graph/case work through existing handlers; Vân sprite explicitly used as temporary stand-in |
| High/Low and effect A/B are renderer-only | Readable sprites/UI and a measurable device budget | Native profile/captures; fog/glow not enabled by default; far DOF stays off UI canvas |
| Save uses full float precision and semantic JSON equality | Serialization can change integral numeric representation | No float rounding or tolerance is used to hide save changes |
| Club, school and home enter side-scroll greybox rooms | Side-scroll pivot (ADR 005); other locations stay HD-2D until migrated | Playable/native tests; doors cost no time; side-room saves keep envelope v1 location/room and restore to the entry room travel spawn until envelope v2 |
| Save v1 tại club/school/home vào spawn mặc định phòng 2D, vị trí 3D không chuyển đổi | World envelope v2 stores side-room `x`/`facing`; HD-2D coordinates have no meaning in a side room | `tests/test_saves.gd` with genuine v1 fixtures (`tests/fixtures/saves/README.md`): v1 and old HD-2D rooms at now-side locations enter the location travel spawn; v2 side `x` outside bounds uses the room default spawn; gameplay state unchanged |
| Side-room doors refresh the displayed HUD location after successful mount | Cross-location doors updated controller location but left the old label visible until the next modal/travel refresh | Headless door round-trip regression and native per-room rendered-label assertions; progression unchanged |
| Captured UI preview defers rebuilding choice controls until GUI dispatch finishes | Synchronous rebuilding inside the pressed callback allowed duplicate choice requests and unstable focus in the native fixture | Existing native pointer/rebuilt-focus test reproduced failure, then passed 68 checks after deferral; accepted UI composition and gameplay dialogue flow unchanged |

The gameplay packs remain mock mechanics. The story bible remains reference
material with its existing proposal/canon distinctions. Captured dialogue graphs
are interaction-test dialogue, not an approved production narrative. No new
ending, balance, romance or NPC schedule design was inferred from those documents.
