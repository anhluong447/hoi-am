# E2 greybox v2 — incomplete native attempt

This attempt captured four room3 lighting frames after the HUD-location fix.
It is not accepted verification: the dialogue probe encountered a workspace modal
where it expected the dialogue view and logged a script error. Continuing the
failed route attempted to revisit room3; this directory therefore is not a complete
seven-room evidence set and is not used for visual acceptance.

The owned test process was stopped after confirming its PID and command line.
The user's existing editor was left running. Both a short dialogue reproduction
and a reproduction including the preceding lighting/captures/ten-second walk passed;
the cause of this one-off modal change was not established. The harness now ignores
OS focus/mouse input, guards modal types, and stops navigation after the first failure.
Corrected evidence is captured in a new version; this attempt and its failure log remain.
