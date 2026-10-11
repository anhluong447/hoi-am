# Lighting and depth

Window sun now travels from the harbor side into the room. Cool ambient, restrained
warm local fill and exposure are authored in the selected pack. Table/room geometry
is shadow-only; character shadows keep their existing invisible proxy. Sea uses
the painted atlas with a small shader displacement rather than a flat color plane.

DOF is calibrated for this camera: far 27m/5m transition, near 15m/2m transition,
maximum amount 0.025. Main actors/interaction region stays outside the blur zones.
Low turns off shadows, dust and DOF while keeping all visual groups and text.
Fog/glow are retained as A/B experiments, disabled by default. Texture import uses
mipmaps and nearest sampling; source pixels/hashes are unchanged.

See `evidence/hd06-quality-v1`: High/Low, DOF/dust/shadow/sun disabled, fog and glow.
699 headless and 95 native checks pass. The synthetic mouse fixture previously
yielded between press/release, permitting unrelated events to cancel a click.
Paired events now run in one input batch; all hit-target/command assertions remain.
The full native suite and two additional 64-check pointer runs pass. Three failed
diagnostic logs are preserved next to the quality captures, not hidden as passes.

DOF tuning follows the engine's distance/transition controls, verified in native
Forward+: [CameraAttributesPractical](https://docs.godotengine.org/en/stable/classes/class_cameraattributespractical.html).
