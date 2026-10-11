# Authoring coastal HD-2D rooms

The selected newsroom JSON is canonical. `build_hd2d_newsroom.py` records the
initial authoring recipe and intentionally refuses to overwrite it; subsequent
camera, lighting and motion calibration lives in the committed content files.
Do not rerun recipes to erase reviewed tuning.

## Add a prop

1. Keep original PNG/source/prompt bytes in a versioned source folder. Copy the
   selected raster unchanged to runtime. Source imports are ignored; source is
   excluded from Windows exports. No readable text is baked into art.
2. Add a new manifest version when changing atlas definitions. Record SHA-256,
   actual PNG dimensions and reviewed pixel region. `inspect_world_atlas.gd`
   reports alpha bounds as metadata; inspect adjacent-cell contamination manually.
3. Add a prop group in a visual pack: stable `id`, world `position`, and layers
   with asset ID and world width/height. Each layer's bottom center is its pivot.
   Offsets separate plant/lamp/paper layers in depth. Fixed camera-facing Z planes
   suit the authored frontal camera; do not enable free orbit.
4. Add separate invisible collision/shadow proxies in the room pack only where
   needed. Artwork and solid footprint serve different purposes. Match foot
   contact, tabletop height, approach space and shadow direction in native view.
5. Decorative `idle` is optional: finite `degrees`, positive `period`, and `phase`.
   Use small angles and distinct phases. The room motion owner resets everything
   for reduced motion and is freed on unmount.

## Add a room

Copy a reviewed pack into a new version; retain the old prototype and stable
location/target/portal IDs. Set `world_art_path`, `visuals_path` and
`world_font_path`. Locations select the pack independently from the historical
manifest used by compatibility fixtures. Add old room IDs to `legacy_room_ids`;
save positions still pass collision/bounds validation before placement.

Author surfaces separately from furniture: flat QuadMesh floor/wall surfaces
sample painted atlas regions. Repetition and `swap_axes` control material
orientation. Cutout props use alpha discard and nearest filtering with mipmaps.
Sprite shadows use existing invisible proxies, avoiding billboard-shadow issues.
No player-facing string belongs in a shader, script or image: add a catalog key
and a Label3D definition; composition injects the font and resolved text.

Orthographic camera presets are the selected framing. Perspective remains an A/B
preview. Camera follow is translation only, bounded by authored maximum values;
provide enough background/floor overscan for all edges. Tune near/far DOF against
actual camera distances, never blur the main actor or actionable props to suggest
depth. Outside spaces need their own skyline, collision edges and sunlight.

High enables authored shadows, dust, water motion and DOF. Low disables expensive
effects; reduced motion independently removes decorative movement. Both preserve
targets, text and gameplay. No new global manager or domain feature is needed.

## Review and ship

Run `tools/verify.py` and `tools/verify_native.py` with the Godot executable.
Capture new versioned evidence; never overwrite reviewed captures or baseline
hashes. Check actor front/behind furniture, approach to every target, collision,
legacy save fallback, portal travel, motion settings and unmount cleanup.

Use `tests/capture_hd2d.gd` for camera comparisons and
`tests/capture_hd2d_quality.gd` for effect isolation. `tests/movie_hd2d.gd` records
a 40-second deterministic review; it does not establish FPS. Real-clock profiling
uses `tools/profile_hd2d.py`, with 10-second warm-up, 30-second measurements and
three repetitions per case. Keep editor state and all samples, inspect variability,
and investigate measured bottlenecks before adding rendering infrastructure.

Export debug/release with `tools/build_windows.py`. Packaged checks run in clean
folders, exercising text/fonts, resources, saves and travel. User art approval and
performance acceptance are separate from successful technical checks.
