# Local ambient motion

Room-local motion owns small, independently phased foliage rotations and bounded,
exponentially smoothed camera translation. Newsroom follow never exceeds 0.25m
horizontal / 0.15m depth. Authored overscan remains in view; camera orientation is
fixed. Existing actors retain directional idle/walk/talk and distance-driven steps.
No HUD or dialogue composition/timing was changed.

Reduced motion restores foliage and camera origin, stops decorative dust and water
displacement, and survives quality changes and room remount. Low quality separately
disables expensive effects. Unmount releases the local motion owner. Gameplay,
session/save schema and original source assets remain unchanged.

Evidence: `evidence/hd07-motion-v1/motion.mp4`, 1280x720 H.264, 40.017 seconds at
60fps. Review sequence: idle, directional walking, opening/revealing/closing
dialogue, reduced motion, restored motion, Low and High. This deterministic movie
is a visual review artifact, not a real-clock performance measurement.

700 headless checks; 103 native checks (64 interaction, 19 dialogue, 20 world).
New assertions cover camera bounds, phased foliage, reduced-motion/quality behavior
and node cleanup. Agent review permits continuing; final user art acceptance remains
pending. Pixel actor art is retained from the existing pilot rather than replaced.
