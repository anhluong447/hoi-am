# World

Scene/script pairs now live in `rooms/newsroom/` and `actors/`. The independent
world entry is `src/bootstrap/previews/world_preview.tscn`; it injects room/actor
content and textures, then mounts the room under its own World node.

Rooms and actors must run without GameSession or persistence. Emit interaction
intent (technical target/action IDs); a presentation controller bridges it to
application commands. Collision/navigation are spatial concerns, not journalism
rules. Location IDs and render coordinates belong to the separate world envelope.

The first concrete implementation is the newsroom blockout in
[Chapter 3](../../docs/migration/chapters/03-world-blockout.md).

As of [ADR 005](../../docs/decisions/005-side-scroll-2d.md) (2026-10-28), this
HD-2D tree is archived: content/evidence stay in place, but new world work goes
to `src/world/side/` (content in `content/world2d/`), per the
[side-scroll design](../../docs/superpowers/specs/2026-10-28-side-scroll-environment-design.md)
and `docs/world-side/status.json`. Locations without a 2D room still mount a
room here during the transition.

`newsroom_sample.json` uses the authored room kit, harbor layers, dust and far DOF.
Other location packs are prototypes; the F6 reading-room extension rehearses an
NPC/graph/case without changing the core handlers. See the
[authoring guide](../../docs/CONTENT-AUTHORING.md) and
[native review/profile](../../docs/reviews/chapters-06-12/README.md).
