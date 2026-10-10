# Khuê: idle-derived up/down walk

2026-10-08. Active in `atlas.json`. Only up/down walk rows are replaced: eight poses each, contact → closing → passing → opening for each leg. Left/right walk and all idle/talk pixels are unchanged from pilot-v5.

Each direction was generated as a complete 4×2 sheet using eight intact copies of its own idle as the editing input. The accompanying technical guide uses the measured idle head bounds and fixed body landmarks. Prompts request arm/leg articulation while retaining the existing head, neck, shirt, waist and satchel. `prompts.json`, the idle templates, body guides and original `<direction>-source.png` sheets are retained here.

Rebuild templates with `tools/prepare_khue_idle_templates.ps1` and import with `tools/import_khue_idle_walk.ps1`. Import samples complete grid cells without rescaling the character, head splicing or individual frame recentering; it uses the existing palette and binary alpha. A single translation compensates transparent padding per four-frame source row: up 0/+3px, down 0/0px. This changes registration only, not body geometry. `metrics.json` records these offsets and the geometry gate for all 16 frames.

All up frames retain the idle upper-band bounds of 17×17px; all down frames retain 18×17px, at y7. These bounds measure opaque pixels above y24, rather than anatomical bone lengths. Down silhouette height varies 37–39px as legs bend. Matching bounds does not guarantee identical interior pixels: hair/color details still vary slightly. Native-size animation and overlays remain the visual review criteria.

Compare [up with idle](../../../archive/development/reviews/khue-v6-up-idle-comparison.png) and [down with idle](../../../archive/development/reviews/khue-v6-down-idle-comparison.png), or step all frames at `/tools/khue-proportion-audit.html`. Preview the active animation at `/tools/khue-animation-lab.html`; play at `/pixel.html`.

Validation: **58/58 browser checks passed**, including upper-band proportions, unchanged protected rows and map movement/clip transitions. The actual animation lab loaded v6 and visited all eight phases in four directions. The map preview completed its yard-to-newsroom route with no overflow. [Animation preview](../../../archive/development/reviews/khue-v6-animation-preview.png), [map preview](../../../archive/development/reviews/pixel-map-v6-preview.png).
