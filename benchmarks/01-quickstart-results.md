# 01 — Quickstart Results

Settings: `n_threads=10`, `n_ctx=2048`, `n_batch=512`, `n_gpu_layers=99`.

| Model | Load (ms) | TTFT P50/P95 (ms) | TPOT P50/P95 (ms) | E2E P50/P95/P99 (ms) | Decode rate (tok/s) |
|---|---:|---:|---:|---:|---:|
| qwen2.5-1.5b-instruct-q4_k_m.gguf | 1078 | 47 / 57 | 14.2 / 14.7 | 943 / 970 / 971 | 70.3 |
| qwen2.5-1.5b-instruct-q2_k.gguf | 668 | 47 / 56 | 14.2 / 14.4 | 939 / 954 / 957 | 70.5 |

## Observations

- **TTFT (P50: 47ms)** and **TPOT (P50: 14.2ms)** are nearly identical between Q4_K_M and Q2_K for this 1.5B model on Apple M4 hardware.
- **Decode rate (~70 tok/s)** is well above the "fluent" reading threshold (~5-10 tok/s), placing this setup in the "instant/interactive" category.
- **Load time** is the primary differentiator: Q2_K loads ~38% faster (668ms vs 1078ms) due to its smaller file size.
- Since there is no significant latency penalty for **Q4_K_M**, it is the superior choice for general use as it offers better output quality for the same inference speed.
- Using `n_threads=10` (matching physical cores) on the M4 provides highly stable performance with very low variance between P50 and P95.
