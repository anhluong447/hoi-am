# Production for a small/solo story game — evidence

Research date 2026-10-28. `[Inference]` marks synthesis without a direct source.

## How others scoped

| Game | Lesson | Source |
| --- | --- | --- |
| Celeste | 4-day PICO-8 jam proved the core before ~2 years of full dev | en.wikipedia.org/wiki/Celeste_(video_game) |
| Oxenfree | ~5 people/18 months; pitch "Limbo, but you could talk"; cut superpowers not serving story; ~1,500-page non-linear script, rewrites hard; playtests showed players didn't know where to go | mcvuk.com/?p=180442 |
| Coffee Talk | Born in a 2-week jam; "design by subtraction" | gamedeveloper.com/design/coffee-talk-devlog-1-… |
| Night in the Woods | Capped stretch goals to avoid scope creep; still slipped; severe crunch reported | en.wikipedia.org/wiki/Night_in_the_Woods; vandal.elespanol.com/noticia/1350707475/… |
| Kentucky Route Zero | Expected small, missed every date over 7 years | usgamer.net/articles/kentucky-route-zeros-creators-at-the-end-of-the-road-… |
| A Space for the Unbound | ~7 years, years searching for "the right formula" | en.wikipedia.org/wiki/A_Space_for_the_Unbound |
| Spiritfarer | Cut seasonal transitions as "much too large" | gamespot.com/articles/spiritfarer-creative-director-… |
| Unpacking | Story through ~1,000 reusable objects; reworked structure when beats lacked room; avoided branching (FOMO, "choice judgment"); audio "takes literal years" | gamedeveloper.com/gdc2022/gdc-2022-unpacking-…; nme.com/news/unpacking-features-over-14000-… |
| Venba | Deliberately <2 h; GDC postmortem "Good Enough Is Better Than Good" | gonintendo.com/contents/24619-…; schedule.gdconf.com/session/…/901533 |
| Eastward | Data loss forced remakes → back up offsite | nintendo.com/us/whatsnew/how-the-developers-began-making-then-remaking-eastward |
| "Beautiful corner" | One screen at final art/audio inside greybox sets the target and measures cost | mycours.es/interactivity/?p=130 |

## Narrative production

- Write in engine: NITW dialogue lived in Yarn scripts with commands driving the game. (secretlab.com.au/blog/2016/2/10/yarn-spinner)
- Branch-and-bottleneck: fixed beats merge paths; flags colour later content. (blooloop.com/…/multi-branching-narrative/)
- Nobody published a "content per day" number → measure your own throughput during the slice. `[Inference]`

## Playtesting

- Test whether the intended emotion and understanding land, not "did you like it"; ask descriptive questions, observe. (sfwa.org/2024/09/10/playtesting-narrative-content-…)
- Track `[Inference]`: retell/comprehension, beat landing, drop-off points, missed optional content (instrumented), reading speed, navigation confusion.

## Localization from day one

- Externalize strings with stable IDs; plan font swaps and text expansion. (godot docs: internationalizing_games)
- Vietnamese stacked diacritics → test line height early; give translators speaker/emotion/screenshot context; keep a glossary. `[Inference]`

## Milestone ladder `[Inference, assembled from the above]`

| Milestone | Content | Exit criteria |
| --- | --- | --- |
| M0 Paper/script | Pitch, beat outline with bottlenecks, slice script | Table read: readers retell the slice and name the emotional turn; cut list written |
| M1 Greybox slice | Whole slice playable with boxes, placeholder portraits, all text through IDs, save/load, core loop | ~5 testers finish unaided; comprehension/beat checks pass; navigation confusion ~0 |
| M2 Beautiful corner | One location at final art, light, ambience, music | Measured hours per background, character, portrait set × whole game ≤ budget, else simplify style now |
| M3 Vertical slice | Slice at ship quality incl. localization pipeline, accessibility, AI-asset audit | Blind testers hit targets; performance target met on real hardware; throughput supports the full plan or plan is cut |
| M4 Content blocks | Production in blocks reusing kits | Per block: playtest + scope review |
| M5 Content lock/polish | No new scenes | Pacing, audio, localization, store/AI disclosure checks |

## Top pitfalls

1. Scope growth (KRZ, Silksong) — cap locations/characters per block.
2. Crunch as plan (NITW).
3. Mechanics not serving story (Oxenfree cut powers).
4. Branching explosion — bottlenecks + flags.
5. Art style only a large team affords (GRIS 80% art staff) — prove cost at M2.
6. Polishing before the greybox plays.
7. Hard-coded text and fonts.
8. Untracked AI assets reaching a build.
9. No offsite backup (Eastward).
10. Measuring "fun" instead of comprehension/emotion; testing too late.
