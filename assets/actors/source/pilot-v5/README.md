# Khuê: walk assets from the aligned storyboards

Historical bank: on 2026-10-08, pilot-v6 replaced the up/down walk using idle-derived templates. The left/right walk and idle/talk here remain unchanged in the active bank. Keep v5 as a comparison and rollback source.

New right/up/down walking cycles, eight frames each, generated from the inspected four-direction technical guides in `../walk-cycle-probe/storyboards/`. This attempt generates a complete 4-column × 2-row cycle in one imagegen call per direction, rather than generating each pose independently. The head and body are imported together, without head splicing.

`right-walk.png`, `up-walk.png`, `down-walk.png`: native 256×48 strips, eight 32×48 frames. `khue.png`: 256×384 bank with the new down/right/up walk rows. The approved left cycle and all existing idle/talk rows are copied from pilot-v3. On 2026-10-08, the game atlas was switched to pilot-v5 at the user's request. Play at `/pixel.html`; preview the active bank at `/tools/khue-animation-lab.html`. Pilot-v3 remains available for rollback.

Source sheets are preserved as `<direction>-source.png`. `prompts.json` records character master, complete direction storyboard and approved left walk references. Right/down initial attempts are preserved as `*-attempt1-source.png`; arm correction prompts are recorded separately. Imagegen originals are copied into this directory and retained at their original generated-image paths.

Rebuild using `tools/import_khue_storyboard_walk.ps1`. Mechanical import uses the entire fixed 4×2 grid, one shared 0.95 scale for all three directions, one vertical registration offset per complete four-frame source row to compensate for differing transparent row margins, binary alpha and the existing character palette. No individual frame cropping/recentering, geometry repair, or synthetic poses. `metrics.json` records bounds and registration offsets.

Review actual native-size animation, especially counter-swing and the two passing poses. Generated guides constrain the motion but do not guarantee identical anatomy or pixel clusters. This is a review candidate; it does not establish a production-approved animation set.

After map integration: **57/57 browser checks passed**, including movement across maps and animation clip transitions. The actual map preview completed the yard-to-newsroom walk with no overflow. [In-map screenshot](../../../archive/development/reviews/pixel-map-v5-preview.png).
