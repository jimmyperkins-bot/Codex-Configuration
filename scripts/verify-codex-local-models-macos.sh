#!/usr/bin/env bash

set -euo pipefail

expected_model="${1:-}"
codex_config="${HOME}/.codex/config.toml"
model_catalog="${HOME}/.codex/ollama-launch-models.json"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This verification script is for macOS only." >&2
  exit 1
fi

if ! command -v ollama >/dev/null 2>&1; then
  echo "Ollama is not installed or is not on PATH." >&2
  exit 1
fi

if ! curl --silent --fail http://127.0.0.1:11434/api/tags >/dev/null; then
  echo "Ollama is not responding at http://127.0.0.1:11434." >&2
  exit 1
fi

if [[ ! -f "$codex_config" ]]; then
  echo "Missing Codex configuration: ${codex_config}" >&2
  exit 1
fi

if [[ ! -f "$model_catalog" ]]; then
  echo "Missing Ollama-generated model catalog: ${model_catalog}" >&2
  exit 1
fi

if ! grep -q 'openai_base_url.*127.0.0.1:11434/api/codex/v1' "$codex_config"; then
  echo "Codex is not pointed at Ollama's combined routing endpoint." >&2
  exit 1
fi

if ! grep -q 'ollama-launch-models.json' "$codex_config"; then
  echo "Codex is not using the Ollama-generated combined model catalog." >&2
  exit 1
fi

if [[ -n "$expected_model" ]] && ! ollama list | awk 'NR > 1 {print $1}' | grep -Fxq "$expected_model"; then
  echo "Expected Ollama model is not installed: ${expected_model}" >&2
  exit 1
fi

if ! grep -q '"slug"[[:space:]]*:[[:space:]]*"gpt-' "$model_catalog"; then
  echo "No OpenAI model entry was found in the combined catalog." >&2
  exit 1
fi

echo "Verified Ollama server, Codex routing configuration, local model catalog, and OpenAI catalog entries."
echo "Final UI check: restart Codex and test one local model and one OpenAI model from the dropdown."
