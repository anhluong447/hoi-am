# Khuê / Vân pilot v2

Two generated character sets, integrated in `pixel.html`; inspect in `/tools/sprite-lab.html`.

- Artwork: built-in imagegen, 2026-10-06. Prompt files: `khue-prompt.txt`, `van-prompt.txt`. Vân uses Khuê's source sheet as the style/scale reference.
- `*-source.png`: transparent generated source, 1024×1536.
- `khue.png`, `van.png`: runtime PNG, each 256×384; 8×8 cells of 32×48.
- Rows 0–3: 8-frame walk in down/left/right/up. Rows 4–7: same directions, columns 0–3 idle and 4–7 talk.
- Pivot `(16,46)`, shared 32-color palette. Neutral down-facing height **39px for both**, 27 colors each. The initial target was approximately 40–42px; the pilot uses 39px to retain transparent margins and avoid clipping.

Import with `tools/import_pilot_sprites.ps1`. It registers the source's entire column grid once, finds row gutters, applies **one shared scale** across both characters/all frames, uses a fixed row-level foot reference, samples with nearest-neighbor and indexes to one shared palette. It does not draw anatomy or manufacture animation frames. Original cell positions remain comparable; individual frames are not independently resized or centered. Row registration accommodates the imperfect generated grid and is not a replacement for an editable artist-authored source.

No existing character sheet was overwritten. Other five characters retain their previous sprites. `atlas.json` selects pilot overrides for Khuê/Vân only. `tools/build_pixel_assets.py` preserves those overrides.

Core idle/walk/talk implemented. Walk is tied to distance, idle/talk use their own durations, NPC dialogue selects talk and animates its portrait. Sprite Lab provides scale, backdrop, direction, speed, pause/frame stepping, onion-skin and pivot controls.

This is an art prototype, not final canon or an Aseprite layered source. Writing/editing, reaching and photography clips are not yet included. Further manual pixel/pose refinement may be needed after visual review; passing automated tests verifies the asset/runtime contract, not whether the artwork is beautiful.
