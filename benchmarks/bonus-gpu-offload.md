# Bonus — GPU Offload (Metal) vs CPU

Model: `qwen2.5-1.5b-instruct-q4_k_m.gguf`  ·  Threads: `10`

| backend | tg64 (tok/s) | speedup |
|:---|---:|---:|
| CPU Only (-ngl 0) | 13.8 | 1.0x |
| Metal (-ngl 99) | 64.5 | 4.7x |

**Observation**: Offloading to Metal (GPU) provides a massive 4.7x speedup on Apple M4 hardware. The unified memory architecture allows the GPU to access the model weights with much higher bandwidth than the CPU, which is the primary bottleneck during LLM decoding.
