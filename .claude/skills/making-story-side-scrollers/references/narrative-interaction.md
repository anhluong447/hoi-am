# Interactive storytelling in side-scrollers — evidence

Research date 2026-10-28. `[Inference]` marks conclusions not stated by a source.

## Case notes

| Game | Mechanic / lesson | Source |
| --- | --- | --- |
| Oxenfree | Choice bubbles over the protagonist while walking; wait, interrupt or stay silent; "choosing dialog had to feel like an ability, not a menu choice"; "Alex never talks unless the player makes her" | thumbsticks.com/gdc-17-creating-narrative-gameplay-oxenfree/; gdcvault.com/play/1024270 |
| Oxenfree | Interruption needs recovery lines ("So like I was saying…"); missed plot points often meant "a total rewrite of the scene"; "make the leanest version of that idea first" | mcvuk.com/?p=180442 |
| Oxenfree | Mechanic complexity flat, stakes escalate through story; mechanic-heavy ending cut | thumbsticks (above) |
| Oxenfree II | Walkie calls anywhere; outcomes as whole character threads; missable people are a feature | nintendoeverything.com/oxenfree-ii-developer-interview/ |
| Night in the Woods | Day shape: town rounds → choose one friend to hang out with → home → dream; choice decides *whose* story you see, not a plot fork | ladiesgamers.com/thoughts-on-night-in-the-woods/; en.wikipedia.org/wiki/Night_in_the_Woods |
| Night in the Woods | NPCs with inner lives unrelated to the plot; recurring small details make the town; Yarn Spinner built for non-technical writers, detects unreachable content, separates text from flow for localisation | gamedeveloper.com/business/road-to-the-igf-infinite-fall-s-i-night-in-the-woods-i-; gamedeveloper.com/programming/deep-dive-yarn-spinner |
| Kentucky Route Zero | Player as performer; choices about inner life; small answers stored and called back acts later; theatrical set design; rejects binary morality | digitaltrends.com/gaming/exploring-the-magical-reality-of-cardboard-computers-kentucky-route-zero/; killscreen.com/kentucky-route-zero-devs-says-moral-choices-games-are-pretty-worthless/ |
| Kentucky Route Zero | Episodic schedule slipped from months to years | digitaltrends (above) |
| A Space for the Unbound | One signature verb (spacediving into a person's heart) that "supported the story"; slice-of-life tribute to a real Asian town, photographed then liberated; experts consulted on mental-health themes; middle was the hardest part | news.xbox.com/en-us/2023/01/26/…; bossrush.net/2023/03/pax-east-2023-interview-…; asianews.network/?p=145834 |
| Spiritfarer | Care is the axis; medicine system cut because punishment contradicted the message; hugs give physical connection; last voyage staged long and quiet; ~90,000 words of spirit stories; ~15 people | originstory.show/episodes/nick-guerin; en.wikipedia.org/wiki/Spiritfarer |

## Principles

1. **Talking is an ability.** In-world choice prompts while the player keeps control; walk-and-talk where the scene allows. (Oxenfree)
2. **Interruption is budgeted, not free.** Allow it only at authored points, every node resumable, recovery lines written. (Oxenfree) `[Inference: limit for solo]`
3. **Silence counts.** Not answering is a choice others react to. (Oxenfree)
4. **Expressive over branching.** Choices colour tone and inner life; branch on *who/where you spend time*, keeping structure roughly linear. (KRZ, NITW)
5. **Few flags, visible callbacks.** Store small answers and pay them off later; one callback beats several branches. (KRZ)
6. **Fixed day shape.** Same skeleton every day so each day is scoped and tested alone. (NITW)
7. **Ambient life keyed by (day, place).** Short NPC lines with lives of their own. (NITW)
8. **Missable content is real.** Don't force completion; let players feel what they skipped. (Oxenfree II)
9. **Stakes rise through story, not new mechanics.** (Oxenfree, KRZ, ASftU)
10. **One signature verb tied to the theme.** Radio, heart-dive, care — for a newspaper game: listening/interviewing/notebook. `[Inference]`
11. **Cut systems that fight the message.** (Spiritfarer medicine)
12. **Stage peaks slowly.** Wide framing, silence, sound; let the camera breathe. (Spiritfarer, KRZ)
13. **Writer-first script format, text separate from logic, reachability checks.** (Yarn)
14. **Outline the middle before art; playtest placeholder scenes for missed beats.** (ASftU, Oxenfree)
15. **Ground the place in lived reference; consult experts on sensitive themes.** (ASftU, Spiritfarer)
