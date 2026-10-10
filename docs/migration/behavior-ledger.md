# Behavior and scope ledger

2026-10-10. No gameplay tuning or baseline bytes changed.

| Decision | Reason | Evidence / limitation |
| --- | --- | --- |
| Gameplay state v3 stores name/title/story/teaser keys | Keep translation out of domain and state creation | Explicit [schema decision](../decisions/002-gameplay-state-v3.md), pure v1/v2 migration, semantic source comparison |
| New log params may contain nested text references or numeric format descriptors | Resolve labels and vi grouping only in presentation | Exact rendered event equivalence in six traces; log order preserved |
| Preserve v1/v2 historical rendered log params/messages during migration | Old evidence must remain readable | Validation accepts keyed legacy events and legacy messages; new rules never author translated strings |
| Open/assign/approve/select and nightly work were ported with Chapter 02 | Sleep parity needs work, approval and publication hooks | Assignment/reassignment and publication-once traces; no claim of full newsroom policy parity |
| Unsupported commands reject explicitly | Avoid success without an implementation | Session immutability checks for seven deferred command families |
| World preview has no gameplay clock | Spatial movement is independent of progression | Independent room/session test, native movement/lock checks |
| Preview portal emits destination but returns to safe spawn | Only the newsroom has 3D geometry in this chapter | Destination/portal ID tests; no yard scene or scene-transition framework |
| Orthographic camera is the greybox default | Consistent actor scale through the room | Native perspective comparison retained; production camera remains reviewable |
| Y billboard + capsule shadow proxy is the current actor setup | Maintain standing registration and avoid cardboard shadow silhouette | Fixed/Y and three shadow-mode native captures; art quality remains a pilot |
| Isolated previews own separate fresh sessions/fixtures | Keep review reproducible before Chapter 06 integration | Calendar uses live state; world/UI previews visibly mark fixture status; returning to calendar starts a new session |
| Static UI behavior passes; G2 stays open | Porting the renderer does not certify replica art | Native captures, conservative-mask diagnostic and explicit visual backlog |

The gameplay packs remain mock mechanics. The story bible remains reference
material with its existing proposal/canon distinctions. Captured dialogue graphs
are interaction-test dialogue, not an approved production narrative. No new
ending, balance, romance or NPC schedule design was inferred from those documents.
