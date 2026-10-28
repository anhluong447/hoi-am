# Gameplay save fixtures

Frozen world-envelope inputs for `tests/test_saves.gd`. Never regenerate these to
make a port pass; add a new fixture instead. Each file is one line of JSON with
no trailing newline, so checkout EOL normalization cannot change its bytes.

| File | SHA-256 | Provenance |
| --- | --- | --- |
| `world_v1_club_3d.json` | `c950f6a8184b733d85c30ae2dae5ed0da3e7c59b88945ae095e7af5d367bcb96` | Genuine. Written by the packaged `src/bootstrap/release_check.gd` (`saves.save("slot_1", play.world_snapshot(), "release-check")`) to `user://release_checks/gameplay/slot_1.json` on 2026-10-11 21:10:10 +0700, during HD09 delivery: after `b320353` (20:32) and before `ce602c6` (21:35), whose committed `release_check.gd` and `locations.json` (club -> `newsroom_hd2d_v1`) match this payload. Pre-pivot HD-2D club shape: `{"version":1,"location_id":"club","room_id":"newsroom_hd2d_v1","position":[x,y,z]}`. Copied byte-for-byte (its `.bak` sibling had the same hash). |
| `world_v1_library_3d.json` | `368bc76340063e0edb4e5b7691bdfc772ed0f98dae03b9244219796523a5bc31` | Genuine. Captured 2026-10-28 at `1a47f43` (clean tree) by a one-off SceneTree script that instantiated the real `playable.tscn`, called `travel("library")`, and saved `world_snapshot()` through `GameplaySaves` + `FileSaveStore` (`saved_at: "fixture-capture"`). |
| `world_v1_side_school.json` | `8d9604fd61348b00e66a2df11e684e4cd763f78c9d5f2a76fe91207912a59536` | Genuine. Same capture run at `1a47f43`: `travel("school")`, `enter_room("corridor_c_2d", "from_gate")`, then saved. v1 side-room shape `{"version":1,"location_id":"school","room_id":"corridor_c_2d"}`. |
| `world_v2_side.json` | `db46ac138b0f2cf17107f4bd0d94ea75c9fe94520462749abd0cbf36b5f9c44f` | Genuine. Captured 2026-10-28 with the Task 9 world-envelope v2 runtime (working tree on top of `1a47f43`): `travel("school")`, `enter_room("corridor_c_2d", "from_gate")`, `room.place_player("from_gate", 1234.0, -1)`, saved through `GameplaySaves` + `FileSaveStore` (`saved_at: "fixture-capture-v2"`). |
| `world_v2_corrupt_x.json` | `e8e5df807c556c662209d0a50fd928a71b14205b5fa09c8299a624c97bff4a36` | Derived. `world_v2_side.json` with the single byte sequence `"x":1234.0` replaced by `"x":"NaN"`; every other byte unchanged. Must be rejected with `invalid_save_envelope`. |
| `world_v2_both_fields.json` | `0edf5490c7e9a3fe517540b49caabca176535d7f0c06752d477575d5ffa68d72` | Derived. `world_v2_side.json` with `"position":[1234.0,0.0,0.0],` inserted before `"x":1234.0`; every other byte unchanged. Carrying both `x` and `position` is ambiguous and must be rejected. |
