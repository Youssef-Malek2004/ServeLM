# AGENTS.md

Context for future agents working in this directory.

## Purpose

Shell scripts that launch a local OpenAI-compatible LLM server on this Mac
using `vllm-mlx` (Apple Silicon MLX backend for vLLM). The server is for
**this machine's own consumption** — code in other repos on this Mac calls
`http://localhost:8001/v1`.

## Hard constraints

- **Localhost-only.** Bind to `localhost`, never `0.0.0.0`. Do not add
  tunnels, port-forwards, or LAN exposure.
  - Reason: this is a **Procore-managed Mac**. The macOS application
    firewall is profile-enforced (block-all is off, but adding
    exceptions or installing overlay tools like Tailscale / ngrok /
    Cloudflare Tunnel may violate IT policy). The user explicitly
    chose the localhost-only path to sidestep that question.
  - If a future task needs cross-machine access, **ask the user first**
    — don't unilaterally add LAN binding or tunneling.

- **Use the conda `base` env.** All Python deps (`vllm-mlx`, `aiohttp`,
  etc.) live in `~/miniconda3` / `base`. Both serve scripts already
  source `conda.sh` and `conda activate base`. Don't bypass that by
  calling `vllm-mlx` directly from a fresh shell.

- **Don't claim Procore IT policy authoritatively.** If a question
  about what's allowed on this Mac comes up, flag uncertainty and tell
  the user to verify with Procore IT.

## Files

| File | What it does |
|---|---|
| `serve-qwen3.sh` | Default launcher: `mlx-community/Qwen3-4b-4bit` on `localhost:8001` with continuous batching, prefix cache, Qwen3 tool/reasoning parsers, `max-num-seqs=4`. |
| `serve.sh` | Generic launcher. Required: `MODEL=<hf-repo>`. Same defaults otherwise. |
| `download.sh` | Pre-fetch a model into the HF cache without starting a server. No-ops if already cached. Note: `serve` also auto-downloads on first use — this script is for warming the cache ahead of time. |
| `test-client.sh` | One-shot `curl` to `/v1/chat/completions` against `localhost:8001`. |

Override defaults via env vars: `MODEL`, `PORT`, `HOST`, `MAX_NUM_SEQS`,
`CONDA_ROOT`, `CONDA_ENV`.

## Gotchas

- **Model name is case-sensitive.** vllm-mlx registers the served model
  as `mlx-community/Qwen3-4b-4bit` (lowercase `b`). Clients that send
  `Qwen3-4B-4bit` get a 404 with `detail: The model ... does not exist`.
  The HF repo redirects between cases, but the API string must match
  what the server logs.
- **`--continuous-batching`** is the correct flag (note spelling — not
  `--continous-batching`).
- **`max-num-seqs=4`** is the current ceiling. Above that, extra
  requests queue. Tested: at concurrency=8 the first 4 finish in ~3.9s,
  the other 4 wait and finish at ~7.4s — that's the cap behaving
  correctly, not a bug. Raise it only if unified memory headroom
  allows; KV cache scales with active sequences.
- **Server takes ~5-10s to be ready** after launch (model load + prefix
  cache restore). Poll `GET /v1/models` before sending real traffic.

## Running the server

```bash
./serve-qwen3.sh                    # default Qwen3-4B-4bit on :8001
MAX_NUM_SEQS=8 ./serve-qwen3.sh     # bump batch ceiling
MODEL=mlx-community/Llama-3.2-3B-Instruct-4bit PORT=8002 ./serve.sh
```

Stop with Ctrl-C, or `kill <pid>` if backgrounded.
