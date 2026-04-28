#!/usr/bin/env bash
# Serve Qwen3-4B-4bit on localhost with continuous batching.
set -euo pipefail

CONDA_ROOT="${CONDA_ROOT:-$HOME/miniconda3}"
CONDA_ENV="${CONDA_ENV:-serve-lm}"
# shellcheck disable=SC1091
source "$CONDA_ROOT/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV"

MODEL="${MODEL:-mlx-community/Qwen3-4b-4bit}"
PORT="${PORT:-8001}"
HOST="${HOST:-localhost}"
MAX_NUM_SEQS="${MAX_NUM_SEQS:-4}"

exec vllm-mlx serve "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --continuous-batching \
  --enable-prefix-cache \
  --max-num-seqs "$MAX_NUM_SEQS" \
  --enable-auto-tool-choice \
  --tool-call-parser qwen \
  --reasoning-parser qwen3
