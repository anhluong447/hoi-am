# Real-clock HD-2D profile

VSync disabled; 120 FPS cap; 10-second warm-up and at least 30 seconds measured, three repetitions.
All runs retained. Editor remains open. These are device/session measurements, not exported-build certification.

| Location | Resolution | Case | Repeat | Median ms | p95 ms | p99 ms | >33 ms |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| club | 1920x1080 | walk-high | 1 | 8.37 | 8.72 | 8.79 | 0 |
| club | 1920x1080 | walk-high | 2 | 8.35 | 8.72 | 8.80 | 0 |
| club | 1920x1080 | walk-high | 3 | 8.32 | 8.73 | 8.81 | 0 |
| club | 1920x1080 | walk-low | 1 | 8.41 | 8.73 | 8.83 | 0 |
| club | 1920x1080 | walk-low | 2 | 8.30 | 8.72 | 8.80 | 0 |
| club | 1920x1080 | walk-low | 3 | 8.33 | 8.73 | 8.82 | 0 |
| school | 1920x1080 | walk-high | 1 | 8.34 | 8.72 | 8.80 | 0 |
| school | 1920x1080 | walk-high | 2 | 8.32 | 8.71 | 8.79 | 0 |
| school | 1920x1080 | walk-high | 3 | 8.33 | 8.72 | 8.80 | 0 |
| school | 1920x1080 | walk-low | 1 | 8.29 | 8.72 | 8.81 | 0 |
| school | 1920x1080 | walk-low | 2 | 8.17 | 8.71 | 8.79 | 0 |
| school | 1920x1080 | walk-low | 3 | 8.30 | 8.72 | 8.79 | 0 |
| waterfront | 1920x1080 | walk-high | 1 | 8.34 | 8.71 | 8.79 | 0 |
| waterfront | 1920x1080 | walk-high | 2 | 8.40 | 8.71 | 8.81 | 0 |
| waterfront | 1920x1080 | walk-high | 3 | 8.32 | 8.71 | 8.78 | 0 |
| waterfront | 1920x1080 | walk-low | 1 | 8.29 | 8.72 | 8.79 | 0 |
| waterfront | 1920x1080 | walk-low | 2 | 8.28 | 8.72 | 8.80 | 0 |
| waterfront | 1920x1080 | walk-low | 3 | 8.27 | 8.72 | 8.79 | 0 |

Root GPU timestamps exclude dialogue SubViewport passes; wall frame time includes them.
Draw/object counters are total counters. No separate transparent-pass timing is claimed.
See summary.json for adapter/driver/memory and samples.json.gz for every measured frame.
