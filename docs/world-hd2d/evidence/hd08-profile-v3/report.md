# Real-clock HD-2D profile

VSync disabled; 120 FPS cap; 10-second warm-up and at least 30 seconds measured, three repetitions.
All runs retained. Editor remains open. These are device/session measurements, not exported-build certification.

| Resolution | Case | Repeat | Median ms | p95 ms | p99 ms | >33 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1280x720 | static-high | 1 | 8.37 | 8.66 | 8.72 | 0 |
| 1280x720 | static-high | 2 | 8.32 | 8.65 | 8.71 | 0 |
| 1280x720 | static-high | 3 | 8.32 | 8.66 | 8.72 | 0 |
| 1280x720 | static-low | 1 | 8.44 | 8.65 | 8.73 | 0 |
| 1280x720 | static-low | 2 | 8.35 | 8.65 | 8.71 | 0 |
| 1280x720 | static-low | 3 | 8.31 | 8.66 | 8.71 | 0 |
| 1280x720 | walk-high | 1 | 8.29 | 8.68 | 8.75 | 0 |
| 1280x720 | walk-high | 2 | 8.31 | 8.68 | 8.76 | 0 |
| 1280x720 | walk-high | 3 | 8.23 | 8.69 | 8.76 | 0 |
| 1280x720 | walk-low | 1 | 8.26 | 8.69 | 8.75 | 0 |
| 1280x720 | walk-low | 2 | 8.30 | 8.69 | 8.76 | 0 |
| 1280x720 | walk-low | 3 | 8.26 | 8.68 | 8.75 | 0 |
| 1280x720 | dialogue-high | 1 | 8.36 | 8.64 | 8.72 | 0 |
| 1280x720 | dialogue-high | 2 | 8.34 | 8.64 | 8.71 | 0 |
| 1280x720 | dialogue-high | 3 | 8.33 | 8.65 | 8.71 | 0 |
| 1280x720 | dialogue-low | 1 | 8.30 | 8.63 | 8.69 | 0 |
| 1280x720 | dialogue-low | 2 | 8.32 | 8.63 | 8.69 | 0 |
| 1280x720 | dialogue-low | 3 | 8.32 | 8.63 | 8.70 | 0 |
| 1920x1080 | static-high | 1 | 8.31 | 8.68 | 8.76 | 0 |
| 1920x1080 | static-high | 2 | 8.27 | 8.70 | 8.80 | 0 |
| 1920x1080 | static-high | 3 | 8.30 | 8.68 | 8.76 | 0 |
| 1920x1080 | static-low | 1 | 8.20 | 8.69 | 8.79 | 0 |
| 1920x1080 | static-low | 2 | 8.27 | 8.70 | 8.78 | 0 |
| 1920x1080 | static-low | 3 | 8.25 | 8.70 | 8.78 | 0 |
| 1920x1080 | walk-high | 1 | 8.41 | 8.71 | 8.81 | 0 |
| 1920x1080 | walk-high | 2 | 8.28 | 8.73 | 8.81 | 0 |
| 1920x1080 | walk-high | 3 | 8.30 | 8.72 | 8.80 | 0 |
| 1920x1080 | walk-low | 1 | 8.31 | 8.72 | 8.80 | 0 |
| 1920x1080 | walk-low | 2 | 8.40 | 8.73 | 8.82 | 0 |
| 1920x1080 | walk-low | 3 | 8.26 | 8.72 | 8.79 | 0 |
| 1920x1080 | dialogue-high | 1 | 8.33 | 8.67 | 8.77 | 0 |
| 1920x1080 | dialogue-high | 2 | 8.31 | 8.70 | 8.81 | 0 |
| 1920x1080 | dialogue-high | 3 | 8.36 | 8.70 | 8.77 | 0 |
| 1920x1080 | dialogue-low | 1 | 8.32 | 8.68 | 8.77 | 0 |
| 1920x1080 | dialogue-low | 2 | 8.34 | 8.73 | 8.85 | 0 |
| 1920x1080 | dialogue-low | 3 | 8.34 | 8.71 | 8.78 | 0 |
| 1920x1080 | hidden | 1 | 8.36 | 8.70 | 8.77 | 0 |
| 1920x1080 | hidden | 2 | 8.39 | 8.69 | 8.77 | 0 |
| 1920x1080 | hidden | 3 | 8.29 | 8.69 | 8.78 | 0 |
| 1920x1080 | effects-off | 1 | 8.42 | 8.69 | 8.76 | 0 |
| 1920x1080 | effects-off | 2 | 8.31 | 8.72 | 8.80 | 0 |
| 1920x1080 | effects-off | 3 | 8.24 | 8.70 | 8.77 | 0 |

Root GPU timestamps exclude dialogue SubViewport passes; wall frame time includes them.
Draw/object counters are total counters. No separate transparent-pass timing is claimed.
See summary.json for adapter/driver/memory and samples.json.gz for every measured frame.
