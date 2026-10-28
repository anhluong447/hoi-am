---
name: making-story-side-scrollers
description: Use when planning, staging, art-directing or reviewing a scene, chapter, vertical slice or roadmap for a story-driven 2D side-scrolling game (walk-and-talk, dialogue choices, painted high-res art, cinematic lighting, Godot 2D), or when judging whether such a plan is scoped and grounded.
---

# Making story-rich side-scrollers

## Overview

Story side-scrollers that people remember (Oxenfree, Night in the Woods, Kentucky
Route Zero, A Space for the Unbound, Spiritfarer, Ori, GRIS, INSIDE) share one
discipline: **every system, frame and light serves a story beat that is already
written and playtested, at a cost the team has measured.** Beauty comes from a
colour script and painted light; reactivity comes from a few remembered choices,
not branches.

Evidence with sources lives in `references/`:
`narrative-interaction.md`, `art-and-lighting.md`, `godot-2d-cinematic.md`,
`production-ladder.md`. Read the one matching your task before deciding.

## A scene or slice plan contains, in this order

1. **Canon sources.** Cite the story/gameplay docs each beat comes from. Mark every
   new mechanic, item, lock, cost or quest name as `PROPOSAL` for the owner to
   approve. Not in the docs → not in the plan as fact.
2. **Beat sheet.** Per beat: purpose, the emotion the player should feel, what the
   player *does* (walk, look, choose, stay silent), the one line they should be
   able to retell afterwards, and which game systems it touches (time of day,
   resource cost, quest tier, save state) with the doc that defines each rule.
3. **Choice design.** Expressive choices (tone, inner life) by default; branch only
   on who/where. List each flag written and the later beat that calls it back. A
   flag with no callback is cut. Silence/no-answer is an option where it fits.
4. **Dialogue presentation.** Choose per beat: in-world bubbles while walking
   (walk-and-talk), framed dialogue with portrait, or wordless staging. State
   whether interruption is allowed, and if so the resume points and recovery lines.
   When a scene switches mode (bubbles → framed), name the trigger and how player
   input is locked/unlocked. Timed or silence choices need a reading-speed or
   untimed accessibility setting.
5. **Colour script and light.** Palette per beat as data (e.g. golden hour → dusk).
   Key light painted into the art; runtime adds ≤ a few motivated lights, shafts,
   grade. Normal maps only on characters/hero props with flat-lit diffuse.
6. **Composition and readability.** Depth planes (far/back/actor/foreground
   occluder), where the eye goes, character value range distinct from background.
   Check in greyscale and at gameplay size.
7. **Animation budget.** Rig/cutout for continuous motion; bespoke poses only for
   named emotional peaks; list transitions needed (sprites don't blend).
8. **Sound.** Ambience per place, one signature motif, which cues continue across
   transitions.
9. **Production order.** Greybox playable → playtest → beauty corner (one view at
   final quality, time every asset) → expand. Each step has an exit check.
10. **Acceptance.** Playtest questions on comprehension and emotion (retell, name
    the turn, notice the callback), navigation confusion, missed optional content;
    native performance on target hardware; asset provenance complete; plus the
    project's own required checks and evidence rules (read its agent instructions).

## Quick reference

| Decision | Default |
| --- | --- |
| Choice structure | Expressive + branch-and-bottleneck; few flags with callbacks |
| Day/chapter shape | Same skeleton every day (rounds → chosen hangout → home → night) |
| Dialogue | Talking is an ability; protagonist speaks when the player makes them |
| Peaks | Slow, wide, quiet; sound carries it |
| Light | Painted first, runtime augments; restrain VFX ("turn it down 90%") |
| Gradients | HDR 2D and/or dither against sunset banding |
| Depth | 3–5 parallax planes + foreground occluders; pre-blurred far plates |
| Assets | Kits re-lit per time of day over unique paintings |
| AI imagery | Logged provenance, painted over to locked palette, disclosed; characters from approved model sheets |

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Inventing locks, costs, quests to "add gameplay" | Mark PROPOSAL; mechanics must serve the beat (Oxenfree cut powers) |
| Many branches, no callbacks | Fewer flags, each paid off later (KRZ) |
| Final art before the greybox plays | Blockout → play → dress (Ori) |
| Style nobody measured | Beauty corner, time assets × whole game before committing |
| Auto-generated normals on painted art | Plastic look; paint light, soft normals on few items |
| Busy painted background swallows characters | Separate value range; greyscale check |
| "60 fps" claimed from headless runs | Measure natively on target GPU |
| One playtest question ("did it feel good?") | Retell, emotion, callbacks noticed, where lost |
| Copying team-scale numbers (Ori layers, GRIS staff) | Copy principles, budget for one person |
