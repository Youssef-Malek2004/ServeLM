#!/usr/bin/env bash
# Quick sanity check against a running server.
set -euo pipefail

HOST="${HOST:-localhost}"
PORT="${PORT:-8001}"
MODEL="${MODEL:-mlx-community/Qwen3-4b-4bit}"

curl -sS "http://${HOST}:${PORT}/v1/chat/completions" \
  -H 'Content-Type: application/json' \
  -d "{
    \"model\": \"${MODEL}\",
    \"messages\": [{\"role\":\"user\",\"content\":\"Say hi in 5 words.\"}],
    \"max_tokens\": 32
  }" | python3 -m json.tool
