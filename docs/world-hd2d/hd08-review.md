# Newsroom performance and packaging

Real-clock matrix: 42 runs, 151,242 measured frames. Every case has 10 seconds
warm-up, at least 30 seconds sampling and three repetitions. Static/walk/dialogue
High and Low run at both 1280x720 and 1920x1080; hidden content and effects-off
add 1080p controls. VSync is disabled, cap 120fps, no fixed/movie FPS.

Hardware: i7-11800H, RTX 3050 Ti Laptop GPU, Windows 11, NVIDIA Windows driver
32.0.16.1714; Godot 4.7.2 Steam Forward+ / D3D12. The user's editor remained open.
No native test, export or video encoding ran concurrently. Lightweight authoring
work continued; every measured frame is retained. All run-end focus flags are true.

Across all runs p95 is 8.633–8.731ms; maximum p99 is 8.849ms. No measured frame
exceeded 33.333ms. 1080p High static/walk/dialogue p95 is 8.674–8.726ms, meeting
the proposed 16.7ms target in this device/session matrix. This does not certify
other hardware, future scenes, or release-build FPS.

High static has 107 total draw calls versus Low's 73. The frame cap limits wall-time
comparisons; this does not mean effects are free. Root GPU timestamps exclude
dialogue's child SubViewport; wall timing includes all passes. No distinct
transparent-pass timing is claimed. Peak reported rendering video memory is
309.78MiB (Godot counter, not total driver allocation). Raw samples also retain
CPU/physics timing, object count and static memory.

See [the report](evidence/hd08-profile-v3/report.md), machine/summary JSON and
losslessly compressed raw samples with hashes. Startup failures in v1/v2 are
preserved and are not performance runs. The world runtime/config measured is
HD07 commit 349bee6; unselected HD09 draft packs were not mounted. Current
authoring data was not used to retrospectively change those measurements.

The measured scene does not justify adding batching or a LOD framework. Import
mipmaps/cutout remain selected; export excludes original art masters and source
prompts while Git preserves them. Packaged checks assert those exclusions and
live catalog world signage alongside existing gameplay/save/font checks.

The hd08-build-v1 evidence records a tracked HD07 runtime snapshot plus the exact
HD08 export/check overrides. Debug/release native clean-folder results, contracts
and binary hashes are retained there. This build review excludes unselected HD09
draft assets so it remains reproducible independently of the working tree.

The reusable [authoring guide](authoring.md) covers assets, regions, prop pivots,
collision/anchors, room selection, legacy IDs, motion, checks and exports.
Agent review permits HD09 continuation; final user art acceptance remains pending.
