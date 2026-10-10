# Pixel anime character set

Temporary sandbox designs, not final character canon. Created with the built-in imagegen tool on 2026-10-06. Source prompt: `characters-anime-prompt.txt`.

- `characters-anime-source.png`: generated transparent artwork, 1536×1024, 12 columns × 7 rows.
- `characters-anime.png`: runtime atlas, 288×252, 24×36 per frame. Each row is one character: Khuê, Vân, Long, Nhi, Ngọc, Ân, source NPC.
- Columns: south idle/left step/right step, west idle/left step/right step, east idle/left step/right step, north idle/left step/right step.
- `prototype-v1/`: previous character atlas and metadata for comparison/rollback.

`tools/import_anime_sprites.ps1` mechanically crops transparent cell bounds, uses a common scale within each character row, aligns feet, packs the grid with nearest-neighbor sampling and binary alpha. It does not generate character drawings. Run from the repository root to rebuild the runtime atlas.

The renderer and dialogue portraits read the atlas metadata. Movement/collision still use the existing tile grid; the taller sprite is visual only.
