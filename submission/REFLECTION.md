# Reflection — Lab 20 (Personal Report)

> **Đây là báo cáo cá nhân.** Mỗi học viên chạy lab trên laptop của mình, với spec của mình. Số liệu của bạn không so sánh được với bạn cùng lớp — chỉ so sánh **before vs after trên chính máy bạn**. Grade rubric tính theo độ rõ ràng của setup + tuning của bạn, không phải tốc độ tuyệt đối.

---

**Họ Tên:** Trần Ngọc Hùng-2A202600429
**Cohort:** A20-K1
**Ngày submit:** 2026-05-06

---

## 1. Hardware spec (từ `00-setup/detect-hardware.py`)

- **OS:** macOS 15.1.1 (Darwin 24.1.0)
- **CPU:** Apple M4
- **Cores:** 10 physical / 10 logical
- **CPU extensions:** NEON, ASIMD, DOTPROD, AES, CRC32, SHA1, SHA2, SHA3, I8MM
- **RAM:** 24.0 GB
- **Accelerator:** Apple Metal
- **llama.cpp backend đã chọn:** Metal
- **Recommended model tier:** Qwen2.5-1.5B-Instruct (Q4_K_M)

**Setup story** (≤ 80 chữ): Lab chạy mượt mà trên Apple M4. Tôi đã thực hiện build llama.cpp từ source để tận dụng tối đa backend Metal. Mọi dependencies được cài đặt qua script macos-setup.sh một cách nhanh chóng. Việc sử dụng native server thay vì bản Python wrapper giúp cải thiện tính ổn định và observability qua endpoint /metrics.

---

## 2. Track 01 — Quickstart numbers (từ `benchmarks/01-quickstart-results.md`)

| Model | Load (ms) | TTFT P50/P95 (ms) | TPOT P50/P95 (ms) | E2E P50/P95/P99 (ms) | Decode rate (tok/s) |
|---|--:|--:|--:|--:|--:|
| qwen2.5-1.5b-instruct-q4_k_m.gguf | 1078 | 47 / 57 | 14.2 / 14.7 | 943 / 970 / 971 | 70.3 |
| qwen2.5-1.5b-instruct-q2_k.gguf | 668 | 47 / 56 | 14.2 / 14.4 | 939 / 954 / 957 | 70.5 |

**Một quan sát** (≤ 50 chữ): Q4_K_M và Q2_K có độ trễ (TTFT/TPOT) gần như tương đương trên M4. Q2_K tải nhanh hơn 38% nhưng chất lượng kém hơn. Với RAM 24GB, Q4_K_M là lựa chọn tối ưu vì chất lượng tốt hơn mà không làm giảm tốc độ inference đáng kể.

---

## 3. Track 02 — llama-server load test

| Concurrency | Total RPS | TTFB P50 (ms) | E2E P95 (ms) | E2E P99 (ms) | Failures |
|--:|--:|--:|--:|--:|--:|
| 10 | 1.21 | 6600 | 9000 | 9900 | 0 |
| 50 | 1.18 | 12000 | 27000 | 29000 | 0 |

**KV-cache observation** (từ `record-metrics.py`): peak `llamacpp:kv_cache_usage_ratio` ở concurrency 50 = 0.00, nghĩa là khối lượng context trong load test rất nhỏ so với context size 2048 được cấu hình, KV cache chưa bị chiếm dụng đáng kể.

---

## 4. Track 03 — Milestone integration

- **N16 (Cloud/IaC):** stub: localhost only
- **N17 (Data pipeline):** stub: in-memory dict
- **N18 (Lakehouse):** stub: SQLite
- **N19 (Vector + Feature Store):** stub: TOY_DOCS

**Nơi tốn nhiều ms nhất** trong pipeline (đo bằng `time.perf_counter` trong `pipeline.py`):

- embed: 0.1 ms (stubbed/minimal)
- retrieve: 0.1 ms
- llama-server: 1586.1 ms

**Reflection** (≤ 60 chữ): Bottleneck rõ ràng nằm ở llama-server (LLM inference). Điều này đúng với kỳ vọng vì retrieval chỉ là lookup trên dictionary nhỏ, trong khi LLM phải thực hiện tính toán heavy-weight trên Metal.

---

## 5. Bonus — The single change that mattered most

**Change:** Kích hoạt GPU offload qua Metal (`-ngl 99`) so với chạy thuần CPU (`-ngl 0`).

**Before vs after** (từ llama-bench):

```
before: 13.84 tok/s (CPU only, -ngl 0, -t 10)
after:  64.52 tok/s (Metal offload, -ngl 99, -t 10)
speedup: ~4.66×
```

**Tại sao nó work**:

Việc offload toàn bộ layers sang Metal cho phép tận dụng Unified Memory của Apple Silicon và hàng ngàn GPU cores thay vì chỉ 10 CPU cores. Tốc độ decode tăng vọt từ 13.8 tok/s lên hơn 64 tok/s vì GPU có băng thông bộ nhớ (memory bandwidth) lớn hơn nhiều so với CPU khi truy xuất trọng số model trong quá trình auto-regressive decoding. Đây là minh chứng rõ nhất cho việc model 1.5B vẫn hưởng lợi cực lớn từ GPU tăng tốc dù kích thước model nhỏ.

---

## 6. (Optional) Điều ngạc nhiên nhất

Tôi ngạc nhiên khi thấy throughput (RPS) gần như không đổi khi tăng từ 10 lên 50 users, trong khi latency tăng vọt. Điều này cho thấy server đã chạm ngưỡng bão hòa compute/memory bandwidth từ 10 users.

---

## 7. Self-graded checklist

- [x] `hardware.json` đã commit
- [x] `models/active.json` đã commit (hoặc paste path snapshot vào section 1)
- [x] `benchmarks/01-quickstart-results.md` đã commit
- [x] `benchmarks/02-server-results.md` (hoặc CSV từ `record-metrics.py`) đã commit
- [x] `benchmarks/bonus-*.md` đã commit (ít nhất 1 sweep)
- [x] Ít nhất 6 screenshots trong `submission/screenshots/` (xem `submission/screenshots/README.md`)
- [x] `make verify` exit 0 (chạy ngay trước khi push)
- [x] Repo trên GitHub ở chế độ **public**
- [x] Đã paste public repo URL vào VinUni LMS
