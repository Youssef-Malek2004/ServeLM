#!/usr/bin/env bash
# Generic vllm-mlx launcher. Pass MODEL=... to override.
# Example:
#   MODEL=mlx-community/Llama-3.2-3B-Instruct-4bit PORT=8002 ./serve.sh
set -euo pipefail

CONDA_ROOT="${CONDA_ROOT:-$HOME/miniconda3}"
CONDA_ENV="${CONDA_ENV:-base}"
# shellcheck disable=SC1091
source "$CONDA_ROOT/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV"

MODEL="${MODEL:?set MODEL=<hf-repo>}"
PORT="${PORT:-8000}"
HOST="${HOST:-localhost}"
MAX_NUM_SEQS="${MAX_NUM_SEQS:-4}"

EXTRA_ARGS=()
if [[ "${CONTINUOUS_BATCHING:-1}" == "1" ]]; then
  EXTRA_ARGS+=(--continuous-batching)
fi
if [[ "${PREFIX_CACHE:-1}" == "1" ]]; then
  EXTRA_ARGS+=(--enable-prefix-cache)
fi

exec vllm-mlx serve "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --max-num-seqs "$MAX_NUM_SEQS" \
  "${EXTRA_ARGS[@]}" \
  "$@"
