# Final-world regression protocol

Selected rooms: club, school and waterfront. Each runs 1920x1080 walking High/Low,
10 seconds warm-up followed by at least 30 seconds measured, three repetitions.
VSync is disabled with a 120 FPS cap. This uses actual elapsed time, not fixed FPS
or movie mode. The user's editor remains open; no native test, export or encode
is run concurrently. Lightweight document/evidence work continues.

inputs.json was recorded before measurement and the runner verifies every listed
hash again on completion. Exact GDScript/Python measurement sources are preserved
here. text-inputs.zip retains original runtime/world/import text bytes, including
CRLF that Git may normalize. The selected PNG files retain their original bytes
in committed source/runtime folders, with hashes in the art manifests.

The final summary/report and losslessly compressed samples retain all runs and
every measured frame, with hashes. Machine details include CPU, GPU and Windows
driver. A completed matrix and inspection of all repetitions are required before
accepting the measured result.

The cap limits cost comparisons. Root GPU timestamps exclude dialogue's child
SubViewport; wall time includes all passes. No separate transparent-pass timing
or exported release FPS certification is claimed. The five other locations have
native functional/visual review but are outside this regression matrix.
