#!/usr/bin/env bash
# Provision the conda env this repo runs in.
# - If `$ENV_NAME` already exists: no-op (idempotent).
# - Otherwise: create the env and install vllm-mlx from GitHub (latest).
#
# Override defaults via env vars: CONDA_ROOT, ENV_NAME, PYTHON_VERSION.
set -euo pipefail

CONDA_ROOT="${CONDA_ROOT:-$HOME/miniconda3}"
ENV_NAME="${ENV_NAME:-serve-lm}"
PYTHON_VERSION="${PYTHON_VERSION:-3.13}"
VLLM_MLX_SPEC="${VLLM_MLX_SPEC:-git+https://github.com/waybarrios/vllm-mlx.git}"

if [[ ! -f "$CONDA_ROOT/etc/profile.d/conda.sh" ]]; then
  echo "conda not found at $CONDA_ROOT — install miniconda or set CONDA_ROOT" >&2
  exit 1
fi

# shellcheck disable=SC1091
source "$CONDA_ROOT/etc/profile.d/conda.sh"

# `conda env list` first column is the env name; match exactly.
if conda env list | awk 'NF && $1 !~ /^#/ {print $1}' | grep -qx "$ENV_NAME"; then
  echo "Conda env '$ENV_NAME' already exists — nothing to do."
  exit 0
fi

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "Warning: vllm-mlx requires Apple Silicon (arm64 Darwin). Continuing anyway." >&2
fi

echo "Creating conda env '$ENV_NAME' (python=$PYTHON_VERSION) ..."
conda create -y -n "$ENV_NAME" "python=$PYTHON_VERSION"

conda activate "$ENV_NAME"

echo "Installing vllm-mlx from $VLLM_MLX_SPEC ..."
pip install --upgrade "$VLLM_MLX_SPEC"

# aiohttp is used by the concurrency test client; keep it in the env so
# `test-client.sh` and any python-based clients work out of the box.
pip install aiohttp

echo
echo "Done. To use:"
echo "  conda activate $ENV_NAME"
echo "  ./serve-qwen3.sh"
