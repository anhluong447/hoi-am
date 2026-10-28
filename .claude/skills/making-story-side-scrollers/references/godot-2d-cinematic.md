# Godot 4.7 for painted cinematic 2D — evidence

Research date 2026-10-28, Godot 4.7.2 stable. Items marked **unverified** must be
prototyped before they enter a plan as fact.

## Renderer and post

- 4.6: D3D12 default on Windows; glow blended before tonemapping; AgX controls; CSV translations gain context/plural columns. 4.7: HDR display output for 2D/3D; Tweens can await signals. (godotengine.org/releases/4.6/, /4.7/)
- **HDR 2D** (`rendering/viewport/hdr_2d`, `Viewport.use_hdr_2d`): float buffer, per-object glow via modulate > 1, less banding; costs bandwidth; Forward+/Mobile only. (docs: class_viewport, environment_and_post_processing)
- **2D glow:** `WorldEnvironment` with background mode Canvas; Canvas Max Layer keeps UI `CanvasLayer`s out. Compatibility renderer: RGBA8, simplified glow, no debanding. (docs: renderers)
- LUT/adjustments in 2D per renderer: **unverified** — fallback is one full-screen LUT/vignette/grain shader on a top `CanvasLayer`.
- Screen-reading shaders: `hint_screen_texture` + `SCREEN_UV`; blur via `textureLod` with a mipmap filter hint; screen copied once per frame at first reader; each `BackBufferCopy` is another full-screen copy. (docs: screen-reading_shaders)

## Lighting

- Nodes: `CanvasModulate` (ambient), `PointLight2D` (texture, height), `DirectionalLight2D`, `LightOccluder2D`; filter PCF13 "only for a few lights". Large lights cost more pixels. Additive sprites are a cheaper shadowless fake light. (docs: 2d_lights_and_shadows)
- Normal/specular via `CanvasTexture`; masks via `CanvasItem.light_mask`. Godot expects OpenGL (Y+) normals; importer has "Normal Map Invert Y".
- Per-canvas-item light cap ≈15–16: **unverified** (forum reports). Split big sprites / fewer lights.
- Pitfalls: normal-mapped items go too dark under `CanvasModulate` night setups (forum); emboss-generated normals turn painted texture into fake bumps; painted shading + dynamic light double-lights `[Inference]`.
- Tools: Laigter (GPL-3), SpriteIlluminator (paint angle/height, inflate).
- Recommended: diffuse painted with neutral, flatter light for anything dynamically lit; soft low-frequency normals (inflate/bevel) only on characters and hero props; background plates unlit and graded.

## Parallax and depth

- `Parallax2D` (props: `scroll_scale`, `scroll_offset`, `repeat_size`, `repeat_times`, `follow_viewport`, `ignore_camera_scroll`, `limit_begin/end`) replaces legacy `ParallaxBackground`. Zooming out can break repeats → raise `repeat_times`. (docs: 2d_parallax, class_parallax2d)
- No built-in 2D DoF: pre-blur far plates (cheapest), `CanvasGroup` blur shader, or SubViewport composite.

## Characters and memory

- Spine (spine-godot GDExtension, 4.7 CI builds; normal maps via `n_` prefix). Needs a paid Spine license to distribute; exports must match runtime editor version. (esotericsoftware.com/spine-godot)
- Built-in `Skeleton2D`/`Bone2D`/`Polygon2D` with weights; 2D IK editor-only. (docs: 2d_skeletons, cutout_animation)
- Live2D via GDCubism: community, mixed licensing — defer until reviewed.
- Import: 2D default Lossless (disk only; VRAM holds RGBA8). VRAM compression S3TC/BPTC can artifact on 2D — A/B before adopting. Mipmaps only for layers the camera zooms out on, with a `*_WITH_MIPMAPS` filter.
- Memory math: 3840×2160 RGBA8 ≈ 33 MB (≈44 MB with mips); BPTC ≈ 8.3 MB. 2 s @24 fps of 1024² frames ≈ 200 MB → frame-by-frame at high res only for short flourishes.

## Cinematics and dialogue

- `AnimationPlayer` as timeline: property, bezier, call-method (not run in editor preview), audio, animation tracks.
- Phantom Camera addon (MIT, 4.4+): priority cameras, follow/group/path, 2D zoom tweens.
- Dialogue options:

| Tool | Fit |
| --- | --- |
| Dialogue Manager 4 (MIT, 4.6+) | Text scripts, static `[ID:KEY]` line keys, PO/CSV export, translator notes, stateless runtime, no UI lock-in |
| Dialogic 2 (MIT) | Visual timelines, VN-oriented, owns UI — heavier |
| Yarn Spinner Godot | C#/.NET, marked work-in-progress |
| Ink (GodotInk / inkgd) | .NET required, or GDScript port on unreleased branch |

  Any tool must resolve lines through the project's own text catalog; never let a plugin own state or UI that the domain/session must own.

## Resolution

- Docs: 1920×1080 base for non-pixel desktop (3840×2160 for high-end), stretch `canvas_items`, aspect `expand`. Author ~1.5–2× and import with size limits.

## Prototype-first risks

1. Worst-case room (HDR 2D, glow, 5 plates, 3 lights, one blur, particles) at 1080p/1440p on target GPU: GPU ms + VRAM.
2. Normal maps on painted characters: double lighting, dark-at-night, light cap.
3. Lossless vs BPTC plates: artifacts vs VRAM.
4. spine-godot on 4.7.x export + licence.
5. Dialogue tool with Vietnamese diacritics + catalog round-trip.
6. Glow/LUT/tonemap in Canvas mode on the chosen renderer.
7. Camera zoom with `Parallax2D` repeats and mipmap shimmer.
8. HDR vs SDR monitor grading consistency.
