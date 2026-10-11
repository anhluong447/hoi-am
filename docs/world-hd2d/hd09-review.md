# Final world migration review

All eight existing locations now select painted HD-2D packs: club, library, cafe,
home, shop, food street (job), school and waterfront. Characters and props are 2D
textures in a 3D world with authored painted surfaces, depth, collision, lighting
and shadow proxies. Outdoor compositions use separate facade/tree/pier cutouts,
wider camera framing and background overscan. No visible blockout boxes remain
in the selected rooms; original prototypes are preserved.

Composition lives in versioned content, using the shared room assembler. No
domain, GameSession, gameplay rules, formula rules, save schema or locked gameplay
baseline changed. The accepted coastal UI/HUD/dialogue sources remain untouched.
World signs use injected Vietnamese catalog text and fonts, with no readable text
baked into art. Existing target commands and the existing Van dialogue are reused;
no new canon, NPC, quest or balance is introduced.

Two generated companion/outdoor PNG masters supplement the first three atlases.
They were generated with built-in imagegen; exact prompts, dimensions and hashes
are archived. Source/runtime PNGs are byte-identical. Atlas regions are metadata,
reviewed against full silhouettes rather than the imperfect generated cell grids.
Manifest v3 also trims harbor regions to remove neighboring-strip contamination.
Only atlases referenced by a composition are loaded.

The extension rehearsal is concrete: seven additional room/visual packs and new
manifest prop definitions reuse the pilot assembler without changing domain or
application code. Chalkboard, school facade, stalls and pier exercise both indoor
and outdoor composition. The initial authoring recipe refuses to overwrite final
packs; selected JSON is the source of subsequent review calibration.

Native review corrected outdoor roof clipping, foreground gaps and repeating-atlas
gradient artifacts. Water now uses padded mirrored repetition and a pause-aware
room clock; dust pauses too. Indoor labels, target anchors and the cafe pendant were
calibrated against actual props. The job scene follows the existing food-street
definition. Indoor proxies remain; fixed outdoor cards opt into silhouette shadows.
Travel locks input and defers room replacement out of the physics callback.

## Verification

- Architecture/reference/content checks passed, with 74 runtime scripts and 953
  Vietnamese catalog entries. Runtime files stay within 200 nonblank lines.
- Headless import/contracts/bootstrap passed: 705 checks, zero failures.
- Native GPU suite passed: 247 checks (64 interaction, 19 dialogue motion, 23 HD-2D,
  141 all-location). It checks every target approach/anchor/modal, safe spawns,
  unchanged progression, old room IDs, actual portals, input locking, pause,
  reduced motion, quality toggles, bounded outdoor follow and unmount cleanup.
- Windows debug/release exports passed standalone checks in clean temporary
  folders, including all eight painted rooms, save/load, ruleset isolation,
  resources and Vietnamese fonts. Generated masters/prompts are excluded from PCK.

Final High/Low and outdoor-edge captures are in evidence/hd09-locations-v4.
The native 46-second tour at evidence/hd09-tour-v1/world-tour.mp4 visits all eight
rooms, walks in each and ends with existing CLB dialogue. Fixed/movie cadence is
for review, not FPS measurement. Earlier captures and diagnosed failures are kept
as history; hd09-locations-v3 contains a capture-runner path assertion failure,
not a completed visual suite. The corrected v4 run passed all 141 checks.

The isolated HD08 newsroom baseline remains unchanged. Final-world real-clock
regression completed 18 runs and 64,818 measured frames: 1080p walking High/Low,
10-second warm-up, at least 30 seconds sampled and three repetitions per case.
All run-end focus flags are true; the input ledger was unchanged. VSync is disabled,
cap 120 FPS; the editor remained open without concurrent native tests/exports/encode.

| Location | p95 range across all six runs | High / Low median draw calls |
| --- | --- | --- |
| Club | 8.717–8.732 ms | 107 / 73 |
| School | 8.713–8.720 ms | 50 / 41 |
| Waterfront | 8.705–8.724 ms | 61 / 47 |

Maximum p99 is 8.826ms. No frame exceeded 33.333ms or 50ms. The proposed 16.7ms
target is met in these three device/session walking cases. Peak Godot video-memory
counter is 294.46MiB, not total driver allocation. The cap limits wall-time cost
comparisons; it does not imply High effects are free. Root GPU timings exclude
dialogue's child SubViewport and no distinct transparent-pass timing is claimed.

See evidence/hd09-profile-v1 for all raw samples, machine details, hashes, exact
measurement scripts and an archive of runtime/world text inputs. Input archives
preserve CRLF bytes that Git may normalize. Packaging and test evidence, including
exact shipped binary hashes, is in evidence/hd09-build-v1.

## Acceptance and practical limits

Agent visual review permits delivery under the user's instruction to finish all
chapters. Final user art acceptance remains pending. These generated painted
masters and retained actor atlases are reviewable art, not a claim of Octopath
pixel parity or final artist-authored production assets. Fixed frontal cameras are
intentional; free orbit would require additional side/back art and collision review.
Large outdoor grounds still reveal repeated painted material motifs.

Native behavior was reviewed for all eight rooms. Performance measurements cover
the newsroom baseline and the final club/school/waterfront regression on this
device/session, not every location or other hardware. Review future compositions
with the authoring guide and new versioned evidence rather than overwriting these
captures or treating technical checks as user approval of the art.
