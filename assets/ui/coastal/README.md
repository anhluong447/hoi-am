# Native coastal UI art contract

`source/` preserves the original UI v3 masters/exports/materials/manifest/mask
byte-for-byte. Imported prompt/font provenance is recorded in
`docs/migration/art-import-manifest.json`. Its README retains historical source
paths. Godot ignores the authoring directory.

`tools/bake_ui_art.py` compiles six independent full-plane art layers plus
choice/date/sun/icon textures. Chromium is used at authoring time because the
source SVG grain/drop-shadow filters need browser rendering. The game reads
only committed PNG textures; no browser is needed to run it. `generated_sources/`
retains the compiled SVG inputs, with their hashes in the runtime art manifest.

Text is never baked. Paper, waves, harbor print, flowers and notebook are art;
speaker/body/date/choices/notebook notes are plain native Labels from the locale
catalog. Independent Button hit targets ignore the transparent decoration art.
Font files carry their original OFL/METADATA. Complex local paper/note washes and
some typography details remain in the explicit visual backlog.

Runtime assets and generated-source hashes are checked by `tools/check_content.py`.
Change authored materials/composition deliberately, retain source evidence,
rebuild textures, then create a new capture version. Do not overwrite historical
reference images or use concept screenshots as runtime UI textures.
