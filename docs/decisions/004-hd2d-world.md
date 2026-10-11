# ADR 004 — World HD-2D

Accepted for implementation by the user on 2026-10-11. The user explicitly
authorized HD00–HD09 in one sustained run, with one commit per chapter.
Intermediate style choices use the recommended direction in the approved plan;
their evidence remains available for subsequent user review. They are not
recorded as user-approved production art merely because implementation passes.

World images come primarily from 2D art: textured surfaces, cutout props, layered
harbor paintings, and animated character atlases. Simple geometry supports
surfaces, collision and shadows. Prop visuals do not own interaction commands.
Camera framing is controlled and authored; free camera orbit is out of scope.
No changes to gameplay/formula rules, text policy, source project or accepted UI.

Composition loads and validates world packs/resources before mounting rooms.
World receives those resources, emits spatial intents, and owns local lifecycle.
Visual depth, physical collision, shadow casting and prompt visibility are
separate contracts. Existing packs, source art and evidence remain intact.

See [approved roadmap](../plans/hd2d-world-roadmap.md). New progress is tracked in
[HD-2D status](../world-hd2d/status.json), separately from migration Chapters 00–12.
