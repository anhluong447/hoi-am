# World

Scene/script pairs now live in `rooms/newsroom/` and `actors/`. The independent
world entry is `src/bootstrap/previews/world_preview.tscn`; it injects room/actor
content and textures, then mounts the room under its own World node.

Rooms and actors must run without GameSession or persistence. Emit interaction
intent (technical target/action IDs); a presentation controller bridges it to
application commands. Collision/navigation are spatial concerns, not journalism
rules. Gameplay state uses location IDs; render coordinates belong to world state.

The first concrete implementation is the newsroom blockout in
[Chapter 3](../../docs/migration/chapters/03-world-blockout.md).
