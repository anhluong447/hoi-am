# Final Windows build evidence

Debug/release were exported from the final selected eight-room working tree with
Godot 4.7.2 Steam; the official 4.7.2 template has the same engine commit. Each
package was copied with licenses into a clean temporary directory, without source
project.godot, and its native self-check completed. No performance run was concurrent.

The logs retain 705 headless contracts, all 247 native checks and packaged checks.
inputs.json fingerprints runtime scenes/scripts/shaders, content, world assets and
import settings, plus project/export configuration and the build runner. binaries.json
records exact package bytes/hashes. Actual deliverables live in build/windows/debug
and build/windows/release (ignored in Git); ship the whole release directory.

text-inputs.zip preserves exact measured/exported text bytes because Git may
normalize CRLF to LF. PNG bytes remain unchanged in their committed source/runtime
paths. Restore the archive over a clean branch checkout to reproduce those exact
authored input bytes. The normal engine import/export pipeline regenerates derived
resources; binary-identical rebuilds are not claimed.

Diagnostic logs retain the empty-atmosphere lifecycle failure and profiler startup
typing failure discovered during development. They are not successful test results.
The subsequent contract/native checks and profiler smoke passed after corrections.
