# Art direction, lighting and animation — evidence

Research date 2026-10-28. `[Inference]` marks conclusions not stated by a source.
Team-scale numbers below are warnings, not targets for a solo developer.

## Case notes

| Game | What they did | Source |
| --- | --- | --- |
| Ori (Moon Studios) | Layered painterly look "very readable… at the service of the gameplay"; hundreds of layers, 7,000+ painted assets | airborn-studios.com/projects/ori; news.xbox.com/en-us/?p=4339 |
| Ori WotW | Polygon blockout → playtest → set-dressing; hundreds of objects react to the player | gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i- |
| Ori WotW | ~30,000 hand-painted light-direction maps; auto normals rejected as "cheap [and] plasticky" (secondary report) | thegamer.com/ori-and-the-will-of-the-wisps-artists-hand-painted-30000-light-maps/ |
| GRIS | Colour script is the story structure: start in black/white, unlock a colour per chapter; ~80% of staff on art/animation, every frame hand-drawn | gamereactor.eu/what-does-gris-mean-we-talk-to-nomada-studio/; mcvuk.com/?p=22112 |
| Planet of Lana | 3D rocks + sprites, "all the lighting is hand-painted"; left flat 2D because the cinematic vision needed depth | filmstories.co.uk/features/planet-of-lana-2023s-prettiest-sci-fi-platformer/ |
| INSIDE | Hand-placed GI/AO/shadows, local volumetrics; VFX talk "Turn it Down 90%" (clean shapes, muted colours); dithering against gradient banding; continuity from streaming + continuous audio | 80.lv/articles/the-rendering-of-inside-low-complexity-high-fidelity/; blog.playdead.com/articles/inside_presentations/inside_publications.html |
| Rayman / Child of Light (UbiArt) | Art split into pieces, boned and deformed; artists make "patterns, like samples" to model levels fast; 40 levels reused under new lighting | gamedeveloper.com/design/the-evolutionary-process-of-building-i-rayman-origins-i- |
| Spiritfarer | Toon Boom, mix of frame-by-frame and cutout; Stella ~100 moves (~25 core); spirits share a base action set; sprite animation can't blend procedurally so transitions are hand-made; keep non-interactive sequences short | toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer |
| Hollow Knight | "whatever your protagonist is, you're going to be drawing it a thousand times over"; cloak hides arms | mcvuk.com/when-we-made-hollow-knight/ |
| Dordogne | Ink sketch → one-shot watercolour → camera-mapped onto rough Blender geometry; light/shadow painted in, shaders kept simple (texture + white rim on characters) | gamedeveloper.com/design/q-a-hand-painting-the-watercolor-world-of-i-dordogne-i- |
| Endling | 2D graphic style on a 3D world; bold contrasts and silhouettes | 80.lv/articles/the-development-process-behind-endling-extinction-is-forever/ |
| Hoa (Skrollcat, VN) | Hand-painted, Ghibli-inspired, 5-person team; Webby for art direction | saigoneer.com/saigon-technology/25490-… |

## Principles

1. **Colour script before painting.** Plan palette per beat (e.g. golden hour → dusk → blue hour) as content data, so lighting changes carry story. (GRIS)
2. **Paint the light; runtime light only augments.** Base art carries key light and shadow; runtime adds a few motivated lights, shafts, grade. Auto-generated normals on painted art look plastic. (Ori, Lana, Dordogne)
3. **Readability first.** Characters own a value/saturation range the background does not use; check every composition in greyscale and at gameplay size. `[Inference]`
4. **Blockout → play → dress.** Paint only after the beat layout feels right in play. (Ori)
5. **Kits over unique paintings.** Reusable modules (walls, windows, railings, props) re-lit per time of day. (UbiArt)
6. **Design characters for animation cost.** Silhouette, hair and uniform chosen so the protagonist is cheap to redraw/rig. (Hollow Knight)
7. **Hybrid animation.** Cutout/skeletal for continuous motion (idle, walk, talk); a few frame-by-frame or bespoke poses for emotional peaks. Decide transitions early: sprites don't blend. (Spiritfarer, Ori)
8. **Continuity through staging and sound.** Story plays inside the gameplay camera; audio does not cut on transitions. (INSIDE)
9. **Restrain VFX.** Bloom, fog, particles serve mood; turn them down until they stop being the subject. (Playdead)
10. **Plan for banding.** Sunset gradients and fog band; dither in shaders/plates, use HDR 2D. (Playdead)
11. **Cheap depth.** A few parallax planes + foreground occluders, or camera-mapped paintings, not hundreds of layers. `[Inference]` from Dordogne/Ori scale.
12. **Make the world respond.** Small sway of foliage, curtains, water, dust reacting to the player sells a painting as alive. (Ori)

## AI-assisted art

- Steam (Jan 2024; narrowed ~Jan 2026): pre-generated AI content players consume (art, sound, text, localization, store/marketing) must be disclosed; behind-the-scenes efficiency tools exempt. Verify in the live Steamworks Content Survey before release. (gameworldobserver.com/2024/01/10/steam-ai-games-new-rules-pre-generated-live-generated; notebookcheck.net/Steam-updates-AI-disclosure-form-…)
- US Copyright Office (2025-01-29): prompts alone don't confer authorship; human modification/arrangement can. (copyright.gov/newsnet/2025/1060.html)
- Reception risk: Indie Game Awards rescinded Clair Obscur awards after AI placeholder textures shipped (malaymail.com 2025-12-21); 52% of devs in GDC 2026 survey see GenAI as harmful.
- Practice `[Inference]`: log every AI-touched asset (tool, prompt, date, human edits); tag placeholders so a build fails if one ships; derive characters from human-approved model sheets (AI drifts on poses/costume); paint over AI backgrounds to a locked palette and brush language; disclose honestly.
