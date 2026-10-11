# Playable integration

Playable and world preview now select the same HD-2D club pack. Composition
validates and injects world resources before removing the old mounted room.
Spatial target/portal IDs still bridge through the existing controllers.

Legacy room aliases `newsroom`/`newsroom_sample` accept old save coordinates;
safe spawn checks those coordinates against current colliders. Valid positions
restore; positions inside furniture use authored spawn. Save schema is unchanged.

699 headless checks, 64 native interaction checks, 19 dialogue checks and 12 new
HD-2D native checks pass. Native screenshots include front/behind table, playable
HUD and dialogue. Final art approval is still reserved for the user.
