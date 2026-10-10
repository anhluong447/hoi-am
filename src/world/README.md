# World

Scene/script pairs for rooms, actors, movement, camera, and local interaction will
live here. `Main/WorldRoot` is currently an empty Node3D mounting point.

Rooms and actors must run without GameSession or persistence. Emit interaction
intent (technical target/action IDs); a presentation controller bridges it to
application commands. Collision/navigation are spatial concerns, not journalism
rules. Gameplay state uses location IDs; render coordinates belong to world state.

The first concrete implementation is the newsroom blockout in
[Chapter 3](../../docs/migration/chapters/03-world-blockout.md).
