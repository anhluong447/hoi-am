# Stage 3 — independent dialogue UI and local lighting

Edit [composition](../../../../content/ui/coastal-dialogue-ui.json) and
[materials](masters/materials.json), then run `python tools/build_dialogue_ui.py --build`.
Use `--check` to verify deterministic outputs, catalog keys, native bounds,
font/source hashes and byte preservation. Never edit generated JS, exports or manifest.

The pack contains **14 UI exports: 11 SVG and 3 PNG**. Harbor print, flowers and
notebook PNGs inherit Stage 2 native master bytes and its recorded generation
provenance. No new bitmap generation or resizing took place. Editable SVG sources
cover paper, wave, choices, date, insignia, icons, seal, logo, shore ink and notebook
edge. Stage 1/2 packs remain available. Readable lettering stays live in the locale
catalog. Three pinned local OFL font families are reused.

`manifest.json` records UI assets separately from one replaceable newsroom
`contextAsset` in v2. No scene, character, desk, newspaper or cup reconstruction
belongs to this pack. The authoring renderer can show UI on light, dark, detailed
or scene context at 1672×941. The optional logo is stored and hidden by default.

Five data-authored shadow profiles apply to paper, choice strips, date card,
flowers and the notebook union. Paper wash follows its contour clip; notebook
wash follows the union's alpha. Notebook edge and PNG receive a single shadow.
Glyphs and context receive no lighting filter. Lighting is a static A/B toggle;
motion, device/GPU performance and gameplay integration belong to later stages.

[Review mask](review/ui-mask.svg) is a **conservative reference-owned interior
diagnostic**, generated from the independently authored paths in materials JSON.
It is not recovered reference alpha or a complete mask of flowers/occluded fringes.
Logo is excluded. Transparent boundary pixels can still respond slightly to the
context; review their alpha on light/dark canvases. Do not equate its MAE with
whole-UI parity or alter the mask to conceal an art error.

See [Stage 3 evidence and open G2 work](../../../../docs/ui-reviews/coastal-replica-stage3/README.md).
