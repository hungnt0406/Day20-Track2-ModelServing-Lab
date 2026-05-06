#!/usr/bin/env bash
# Launch native llama-server with metrics enabled.
set -euo pipefail

cd "$(dirname "$0")/.."

MODEL=$(python -c 'import json; print(json.load(open("models/active.json"))["primary_model"])')
THREADS=$(python -c 'import json; hw=json.load(open("hardware.json")); print(hw["cpu"].get("cores_physical") or 4)')
GPU_LAYERS="${LAB_N_GPU_LAYERS:-99}"
PARALLEL="${LAB_PARALLEL:-4}"
CTX="${LAB_N_CTX:-2048}"

SERVER_BIN="./BONUS-llama-cpp-optimization/llama.cpp/build/bin/llama-server"

if [ ! -f "$SERVER_BIN" ]; then
    echo "ERROR: Native llama-server not found at $SERVER_BIN"
    echo "Run 'make build-llama' first."
    exit 1
fi

echo "==> Starting native llama-server"
echo "    model     : $MODEL"
echo "    threads   : $THREADS"
echo "    gpu_layers: $GPU_LAYERS"
echo "    parallel  : $PARALLEL"
echo "    ctx       : $CTX"
echo "    metrics   : enabled (/metrics)"
echo "    listening : http://0.0.0.0:8080"
echo

exec "$SERVER_BIN" \
    --model "$MODEL" \
    --host 0.0.0.0 --port 8080 \
    --threads "$THREADS" \
    --n-gpu-layers "$GPU_LAYERS" \
    --ctx-size "$CTX" \
    --parallel "$PARALLEL" \
    --metrics
