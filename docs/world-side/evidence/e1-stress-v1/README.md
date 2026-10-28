# E1 — Stress render side-scroll (v1, tham chiếu RTX, một phần)

## Trạng thái và thay đổi mục tiêu phần cứng

- Đo xong trên **NVIDIA GeForce RTX 3050 Ti Laptop GPU** (3 lần lặp hợp lệ). Đây chỉ là
  **tham chiếu máy mạnh**.
- Ngày 2026-10-28 người dùng đổi mục tiêu: Hồi Âm là game casual, phải chạy trên laptop
  thường **không có GPU rời** (iGPU kiểu Intel UHD). Cũng ngày đó người dùng quyết định
  **dừng đo hiệu năng, tối ưu sau**: phần đo Intel UHD (Forward+ và Compatibility) **hoãn**,
  không có số liệu iGPU nào trong evidence này.
- Vì vậy `recommendation` trong `report.json` được **đặt theo thiết kế** cho mục tiêu casual
  (`"source": "design"`), **không suy ra từ đo**. Kết quả quy tắc đo trên RTX được giữ ở
  `measured_reference` và không còn là khuyến nghị của dự án.

## Khuyến nghị (theo thiết kế, chưa kiểm bằng đo iGPU)

| Mục | Giá trị |
| --- | --- |
| HDR 2D | tắt |
| Glow | tắt |
| Ánh sáng | vẽ sẵn vào plate |
| Light runtime tối đa | 2 |
| Sun shaft | sprite cộng (additive) |
| Plate nguồn | cỡ ~1920×1080, import lossless |
| Renderer | giữ `forward_plus`, chờ lần kiểm trên iGPU |

## Máy và môi trường

- CPU: 11th Gen Intel Core i7-11800H @ 2.30GHz; Windows 11 Home Single Language 10.0.26300.
- GPU đo: NVIDIA GeForce RTX 3050 Ti Laptop GPU, driver 32.0.16.1714 (máy còn Intel UHD
  Graphics driver 30.0.101.1273, không dùng trong lần đo này).
- Godot 4.7.2-stable (steam, ed1daf0bf), renderer `forward_plus`, API `d3d12` (feature 12_0).
- Màn hình đo: màn 2560×1440 (scale 1.0) là màn duy nhất Windows báo; editor Godot của
  người dùng vẫn mở trong lúc đo.

## Lệnh và giao thức

```
python tools/profile_side_stress.py --godot "D:/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"
```

Lệnh trên là phiên bản công cụ lúc đo, lưu nguyên byte ở `sources/tools/profile_side_stress.py`
(cùng mọi file đầu vào ở `sources/`; hash trong `report.json` → `inputs`). Phiên bản hiện tại
trong repo đã mở rộng thành `measure`/`recommend` và thêm biến thể casual cho lần kiểm iGPU sau.

- Native, có cửa sổ, không headless, không fixed-fps/movie mode. VSync tắt, `Engine.max_fps = 120`.
- Mỗi biến thể × độ phân giải: khởi động 10 s, đo 30 s theo thời gian thực giữa các frame
  (`Time.get_ticks_usec`). VRAM = max `Performance.RENDER_VIDEO_MEM_USED`; GPU = thời gian
  render viewport gốc (`viewport_get_measured_render_time_gpu`).
- Ba tiến trình Godot riêng = ba lần lặp. Ảnh chụp chỉ ở lần 1, ở 1920×1080.
- Cảnh `stress_v1`: 5 plate 3840×2160 sinh nhiễu lúc chạy (không commit ảnh 4K), mỗi lớp
  2 sprite cạnh nhau trong `Parallax2D`; blur `CanvasGroup` (mipmap, `textureLod`) cho lớp xa;
  3 `PointLight2D`; 1 sun shaft cộng; `GPUParticles2D` 120 hạt; `WorldEnvironment` nền Canvas;
  `CanvasModulate`; 2 actor có normal map phẳng (`CanvasTexture`); camera lia ±1400 px world
  chu kỳ 4 s; zoom để plate 2160 px vừa chiều cao cửa sổ.

## Kết quả RTX (tham chiếu)

p95 ba lần lặp; p50 là trung vị của ba lần; VRAM giống nhau giữa các lần.

| Biến thể | Độ phân giải | p50 ms | p95 ms (lần 1/2/3) | p99 max ms | GPU p50 ms (lần 1/2/3) | VRAM MiB |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| baseline | 1920×1080 | 8.32 | 8.36 / 8.36 / 8.35 | 8.38 | 2.93 / 2.37 / 2.35 | 294.1 |
| hdr | 1920×1080 | 8.32 | 8.36 / 8.36 / 8.35 | 8.39 | 2.68 / 2.42 / 2.53 | 314.3 |
| hdr_glow | 1920×1080 | 8.32 | 8.36 / 8.36 / 8.36 | 8.40 | 2.88 / 2.66 / 3.02 | 344.7 |
| hdr_glow_bptc | 1920×1080 | 8.32 | 8.35 / 8.35 / 8.36 | 8.39 | 2.40 / 2.80 / 2.46 | 232.2 |
| hdr_glow_lights32 | 1920×1080 | 8.32 | 8.35 / 8.36 / 8.36 | 8.38 | 6.49 / 5.81 / 5.78 | 371.3 |
| baseline | 2560×1440 | 8.32 | 8.36 / 8.38 / 8.36 | 8.59 | 3.05 / 2.98 / 2.98 | 352.4 |
| hdr | 2560×1440 | 8.32 | 8.36 / 8.36 / 8.36 | 8.39 | 3.58 / 3.28 / 3.24 | 387.5 |
| hdr_glow | 2560×1440 | 8.32 | 8.36 / 8.36 / 8.36 | 8.39 | 4.16 / 4.21 / 4.20 | 438.0 |
| hdr_glow_bptc | 2560×1440 | 8.32 | 8.36 / 8.36 / 8.36 | 8.39 | 4.47 / 4.46 / 4.02 | 325.5 |
| hdr_glow_lights32 | 2560×1440 | 12.09 | 12.97 / 12.38 / 13.15 | 13.56 | 10.98 / 11.65 / 11.83 | 464.6 |

Đọc số: cap 120 FPS nên frame ~8.33 ms che chi phí thật khi GPU nhanh hơn; cột GPU là tín
hiệu so sánh. Trên RTX mọi biến thể đạt p95 ≤ 16,7 ms ở 1080p và VRAM ≤ 1 GiB.

## Quan sát

- **Giới hạn light mỗi canvas item**: probe 32 `PointLight2D` lưới 8×4 chiếu lên một sprite
  trắng dưới `CanvasModulate` đen: chỉ **15/32** điểm sáng (`light_probe.png`). Không có
  project setting nào về giới hạn này (`light_settings` rỗng).
- **Chi phí light**: 32 light (thực nhận 15 mỗi item) tăng GPU p50 từ ~2,9 lên ~6 ms ở 1080p
  và ~4,2 lên ~11–12 ms ở 1440p.
- **Normal map tối ban đêm**: `CanvasModulate` đêm + một light gần actor, độ sáng trung bình
  vùng actor (trái/phải): không normal map 0,074/0,086; normal map phẳng, light height 0:
  0,046/0,050 (tối hơn ~40%); height 160: 0,058/0,063. Ảnh `night_normal_*.png`.
- **Lossless vs BPTC**: VRAM 344,7 → 232,2 MiB ở 1080p (5 plate 4K, ~22,5 MiB mỗi plate);
  PSNR giữa hai ảnh chụp 53,6 dB trên nhiễu procedural (không đại diện cho dải màu hoàng hôn).
- HDR 2D +~20 MiB VRAM, glow thêm ~30 MiB ở 1080p.

## Giới hạn

- Một cảnh tổng hợp, một máy, một phiên; không phải ngân sách từng phòng, không phải bản export.
- **Không có số iGPU**: mục tiêu phần cứng hiện tại chưa được đo.
- 1080p là cửa sổ borderless trên màn 1440p; ở 2560×1440 cửa sổ phủ kín màn và Godot báo
  `window_mode` 4 (exclusive fullscreen), nên điều kiện present giữa hai độ phân giải khác nhau.
- Lần đo này chỉ kiểm `window_mode` cuối mỗi biến thể (0 hoặc 4); bộ đếm frame bị thu nhỏ
  được thêm vào công cụ sau lần đo.
- Hai lần chạy trước bị loại và không nằm trong evidence: lần 1 tiến trình Godot thoát giữa chừng ở
  1440p, không rõ nguyên nhân (không có marker hoàn tất); lần 2 có lần lặp 3 bị thu nhỏ cửa sổ
  (`window_mode` 1). Một lần đo Intel UHD Forward+ bị đóng cửa sổ giữa chừng (4/8 biến thể)
  rồi dừng theo quyết định người dùng. Dữ liệu thô các lần này chỉ giữ cục bộ ở
  `artifacts/profile/` (bị gitignore), không dùng làm bằng chứng.

## File

- `report.json` — máy, `runs` (30 hàng), `recommendation` (theo thiết kế), `measured_reference`,
  `observations`, danh sách hoãn.
- `rtx-measured.json` — đầu ra nguyên vẹn của công cụ lúc đo (kèm khuyến nghị quy tắc cho RTX).
- `samples.json.gz` — mọi frame đã đo của ba lần lặp.
- `profile-run{1,2,3}.log` — log Godot.
- `*.png` — ảnh tổng quan nửa kích thước và `*_crop.png` 512 px gốc ở tâm.
- `sources/` — bản sao byte của mọi file đầu vào lúc đo.
