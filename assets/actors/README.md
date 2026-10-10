# Selected 2.5D actor pilot

Runtime sheets: unchanged `khue.png` from source pilot-v6 and `van.png` from
pilot-v2. Both are 256×384, eight columns/eight rows, 32×48 frames, foot pivot
(16,46). Rows/columns/durations and walk stride come from
`content/world/actors.json`, captured from the original atlas.

The original generation prompts, source sheets, intermediate registration data
and READMEs remain under `source/pilot-v2`, `source/pilot-v5`, `source/pilot-v6`.
Source documentation paths retain their historical checkout meaning. These
directories are authoring evidence and are excluded from Godot import.
All copied bytes have SHA256 entries in `docs/migration/art-import-manifest.json`.

Art was generated with the source project's built-in imagegen workflow; source
READMEs describe the provisional art and registration limitations. It is not
final canon or an artist-layered production source. No sprite pixels were edited,
recentered or regenerated for this migration.

`AnimatedSprite3D` uses nearest filtering, alpha discard, shared pixel_size
0.042, and offset derived from the pivot. Idle/talk retain source durations;
walk selects frames from actual horizontal travel distance, not requested input.
The default Y billboard casts no sprite-plane shadow; a shadows-only capsule
provides the current proxy. Contact and raw-sprite modes are review alternatives.
