#!/usr/bin/env bash
# Pre-download a model to the local HF cache without starting a server.
# Skips work if the model is already cached.
#
# Usage:
#   ./download.sh                                       # default: Qwen3-4B-4bit
#   ./download.sh mlx-community/Llama-3.2-3B-Instruct-4bit
#   MODEL=mlx-community/Phi-3.5-mini-instruct-4bit ./download.sh
set -euo pipefail

CONDA_ROOT="${CONDA_ROOT:-$HOME/miniconda3}"
CONDA_ENV="${CONDA_ENV:-serve-lm}"
# shellcheck disable=SC1091
source "$CONDA_ROOT/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV"

MODEL="${1:-${MODEL:-mlx-community/Qwen3-4b-4bit}}"
HF_CACHE="${HF_HOME:-$HOME/.cache/huggingface}/hub"
# HF cache dir convention: models--<org>--<repo>
CACHE_DIR_NAME="models--${MODEL//\//--}"
CACHE_PATH="$HF_CACHE/$CACHE_DIR_NAME"

if [[ -d "$CACHE_PATH" && -n "$(ls -A "$CACHE_PATH/snapshots" 2>/dev/null)" ]]; then
  echo "Already cached: $MODEL"
  echo "  -> $CACHE_PATH"
  exit 0
fi

echo "Downloading $MODEL ..."
exec vllm-mlx download "$MODEL"
