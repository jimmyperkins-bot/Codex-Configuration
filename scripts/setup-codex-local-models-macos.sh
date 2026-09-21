#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup script is for macOS only." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh/ and run this script again." >&2
  exit 1
fi

memory_bytes="$(sysctl -n hw.memsize)"
memory_gib="$((memory_bytes / 1024 / 1024 / 1024))"

requested_model="${1:-}"
if [[ -n "$requested_model" ]]; then
  selected_model="$requested_model"
elif (( memory_gib < 16 )); then
  selected_model="qwen3.5:2b"
else
  selected_model="qwen3.5:4b"
fi

echo "Detected approximately ${memory_gib} GiB of unified memory."
echo "Selected local model: ${selected_model}"

if command -v ollama >/dev/null 2>&1; then
  echo "Updating Ollama if a Homebrew update is available..."
  brew upgrade ollama || true
else
  echo "Installing Ollama..."
  brew install ollama
fi

echo "Starting Ollama..."
brew services start ollama >/dev/null 2>&1 || brew services restart ollama >/dev/null 2>&1

echo "Waiting for the Ollama server..."
ollama_ready=0
for _ in {1..30}; do
  if curl --silent --fail http://127.0.0.1:11434/api/tags >/dev/null; then
    ollama_ready=1
    break
  fi
  sleep 2
done

if (( ollama_ready == 0 )); then
  echo "Ollama did not become ready. Run 'brew services restart ollama' and try again." >&2
  exit 1
fi

if ! ollama launch --help 2>&1 | grep -qE 'chatgpt|codex-app'; then
  echo "This Ollama version does not include the Codex desktop launcher. Update Ollama and retry." >&2
  exit 1
fi

echo "Downloading ${selected_model}..."
ollama pull "$selected_model"

echo "Adding Ollama and OpenAI models to the Codex desktop picker..."
ollama launch codex-app --model "$selected_model" --config -y

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${script_dir}/verify-codex-local-models-macos.sh" "$selected_model"

echo
echo "Configuration complete."
echo "Fully quit the ChatGPT/Codex desktop app, reopen it, start a new task, and use the model dropdown."
echo "To remove the integration later, run: ollama launch chatgpt --restore"
