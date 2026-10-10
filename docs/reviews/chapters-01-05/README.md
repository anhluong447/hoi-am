# Chapter 01–05 implementation review

2026-10-10. Windows, Godot 4.7.2 Steam, Forward+ / D3D12,
NVIDIA GeForce RTX 3050 Ti Laptop GPU. Source `hai-vong` remains unchanged.

| Chapter | Delivered | Gate |
| --- | --- | --- |
| 01 | JSON gameplay/maps/dialogue packs, source mapping, seven oracle traces with hashes | Content/oracle integrity verified |
| 02 | Real session, calendar/guards/costs/fatigue, night hooks, keyed v3 migration/validation | Six traces / 71 commands have intermediate state/event parity; full-policy parity deferred |
| 03 | Walkable newsroom, colliders/windows/light, camera presets, targets/portal/safe spawn | Technical greybox verified |
| 04 | Unchanged actor atlas, foot pivot, camera-relative distance-driven walk, idle/talk, NPC model, depth/shadow modes | Rig reviewed natively; production art/animation polish remains open |
| 05 | Native dialogue/HUD, keyed text, attached art, prompt anchors, focus/pointer/scale | Behavior verified; static G2 remains open |

F5 opens three concrete review entries. Calendar owns a fresh live session;
world/UI previews use identified fixtures. Chapter 06 connects world → NPC
dialogue → command → live HUD. Full personal mechanics, saves, formula sandbox
and production world art are not implied.

## Checks actually run

- Architecture/reference/content checks pass: 34 runtime scripts, largest 168
  nonblank lines, 826 locale entries. No runtime file exceeds 200 nonblank lines.
- 18 original reference copies / four concept locks are unchanged. 78 selected
  art/provenance imports and 16 runtime textures have verified SHA256.
- Headless import, contracts, gameplay parity, world/UI integration and main
  boot smoke pass: **349 checks, zero failures**.
- Native input suite: **12 checks, zero failures**. Pointer choices and Tab focus
  work at 1672×941, 1280×720 and 1920×1080; native walk/facing/input lock pass.
  Input is injected through the engine, not an OS-level keyboard test.
- MCP native room run had no errors. Native logs identify the GPU above.
  Durable raw logs and file hashes are indexed by [evidence.json](evidence.json).
- Fixed simulation cadence in tests is not an FPS/performance measurement.
  Export, full-policy parity and device budgets remain unverified.

The browser suite was not run because source code was unchanged. Its four
gameplay/eight formula-policy baseline files remain untouched; their policies
are not certified by the current subset of Godot traces.

## Native visual evidence

World: [orthographic](captures-v3/world-orthographic.png),
[perspective](captures-v3/world-perspective.png),
[before desk](captures-v3/world-desk-front.png),
[behind desk](captures-v3/world-desk-behind.png),
[window](captures-v3/world-window.png), [door](captures-v3/world-door.png).

Default camera: position (8,10,12), target (0,0.5,0), orthographic size 14.4,
near 0.05/far 45. Comparison: (16,20,24), target (0,0.5,0), FOV 25,
near 0.05/far 75. Actors share pixel_size 0.042 and pivot (16,46); opaque sprite
height is about 1.55–1.64 world units. Camera choice remains reviewable.

Sprites receive room light and are occluded by desk/door geometry. Compare
[sprite shadow](captures-v3/shadow-sprite.png), [proxy](captures-v3/shadow-proxy.png),
[contact](captures-v3/shadow-contact.png), [fixed plane](captures-v3/billboard-fixed.png),
[Y billboard](captures-v3/billboard-y.png). Default is Y billboard + capsule proxy;
the sprite plane does not cast its own shadow. Idle/talk timing and distance
registration retain source metadata. No sprite pixels were edited.
The proxy is still a simplified silhouette needing production review.

Godot documents the chosen [alpha-cut/depth behavior and billboard-shadow caveat](https://docs.godotengine.org/en/stable/classes/class_spritebase3d.html).
[Camera projection](https://docs.godotengine.org/en/stable/classes/class_camera3d.html)
supplies anchors, followed by viewport/ray-occlusion checks.

UI: [neutral](captures-v3/dialogue-neutral.png), [bright](captures-v3/dialogue-ui-light.png),
[dark](captures-v3/dialogue-ui-dark.png), [detail](captures-v3/dialogue-ui-detail.png),
[HUD](captures-v3/hud-neutral.png), [HUD on detail](captures-v3/hud-detail.png),
[1280×720](captures-v3/dialogue-1280x720.png), [1920×1080](captures-v3/dialogue-1920x1080.png).
Captures use keyed dialogue fixtures, deterministic backdrop profiles and hidden
authoring controls/focus outlines. UI is independent of room camera/exposure.

Early [captures](captures/) retain icon/note-placement and shadow issues;
[v2](captures-v2/) records icon/note/framing corrections. v3 fixes shadow coverage
with bounded camera clipping and adds selection chevrons. Older captures are
historical evidence, not current certification.

## Visual gaps and limits

- Paper/wave/harbor/flowers/notebook scope is retained. Local paper/note lighting
  washes, union-mask shading and exact browser/Godot typography still differ.
- Notebook handwriting has an approximate native rotation/placement; the source
  affine/shear transform still needs visual authoring.
- HUD geometry is an initial coastal implementation. Exact HUD/map replica,
  ornament details and typography need a separate visual pass.
- Room geometry/materials and actor artwork are pilots; harbor context, final
  props, dust/DOF/atmosphere and production animation quality remain open.

The source conservative interior mask covers **444,170 pixels**. Diagnostic RGB
MAE is **23.409 / 255** for neutral v3 dialogue against the concept; see
[comparison](ui-comparison-v3.json) and [mask](ui-mask-v3.png).
This is not recovered reference alpha, a full-frame score, a pass threshold or
a zero-diff claim. Mixed/occluded fringe alpha remains uncertain. G2 stays open;
G3 motion remains deferred. Chapter 06 can use this implementation with documented
visual gaps while art corrections proceed independently.
