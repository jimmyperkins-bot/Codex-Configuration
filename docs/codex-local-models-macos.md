# Use local Ollama models in Codex on macOS

This guide configures the Codex desktop app on a Mac so its model picker contains both:

- local models served by Ollama; and
- OpenAI models available through the Mac's existing ChatGPT sign-in.

No OpenAI API key is required. Each Mac still needs its own normal ChatGPT/Codex sign-in.

## What the integration changes

Ollama's supported Codex-app launcher creates a combined model catalog and points Codex's built-in OpenAI provider at Ollama's local routing endpoint. Ollama then sends local model requests to the Mac and passes OpenAI model requests through the existing Codex/ChatGPT authentication route.

The launcher manages these user-level files and settings:

- `~/.codex/config.toml`
- `~/.codex/ollama-launch-models.json`
- backups under `~/.ollama/backup/codex-app/`

Do not commit those generated files. They can contain machine-specific settings, and Codex authentication must never be copied between computers.

OpenAI documents that provider-routing settings such as `openai_base_url` belong in the user-level Codex configuration, and that `model_catalog_json` is loaded when Codex starts:

- [Codex advanced configuration](https://learn.chatgpt.com/docs/config-file/config-advanced)
- [Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)

## Recommended model size

The setup script uses a conservative default intended to keep the Mac responsive:

| Installed unified memory | Default model | Guidance |
| --- | --- | --- |
| Less than 16 GB | `qwen3.5:2b` | Safest option for 8 GB Macs and machines running several apps at once. |
| 16 GB or more | `qwen3.5:4b` | Better general and coding quality while remaining practical on most Apple Silicon Macs. |

The 4B model is the default ceiling in the automatic script. Larger models can be tried manually on higher-memory Macs, but they are not part of the unattended setup because context, other open applications, and macOS memory pressure all affect stability.

## One-command setup

Prerequisites:

1. Install the ChatGPT/Codex desktop app and sign in normally.
2. Install Homebrew from [brew.sh](https://brew.sh/) if it is not already installed.
3. Clone this repository.

Run:

```bash
cd Codex-Configuration
chmod +x scripts/*.sh
./scripts/setup-codex-local-models-macos.sh
```

To force a particular model:

```bash
./scripts/setup-codex-local-models-macos.sh qwen3.5:4b
```

The script will:

1. confirm that it is running on macOS;
2. install or update Ollama with Homebrew;
3. start Ollama as a background service;
4. select a model based on installed memory, unless one is supplied;
5. download the model;
6. use Ollama's official `codex-app` launcher to create the combined picker; and
7. run the repository's verification script.

After it finishes, completely quit the ChatGPT/Codex desktop app, including any menu-bar instance, and reopen it. Start a new Codex task and open the model dropdown beneath the composer.

## Manual setup

If you prefer to run each step yourself:

```bash
brew update
brew install ollama
brew services start ollama
ollama pull qwen3.5:4b
ollama launch codex-app --model qwen3.5:4b --config -y
```

If Ollama is already installed, `brew upgrade ollama` can be used in place of `brew install ollama`.

Then fully quit and reopen Codex. Both the local model and the normal OpenAI models should appear in the same dropdown.

## Verify the setup

Run:

```bash
./scripts/verify-codex-local-models-macos.sh
```

Also perform these two desktop tests:

1. Select the local Qwen model and ask it to reply with `LOCAL_ROUTE_OK`.
2. Start a new task, select an OpenAI model, and ask it to reply with `OPENAI_ROUTE_OK`.

The first local response can take longer because Ollama must load the model into unified memory.

## Update or change the local model

```bash
brew update
brew upgrade ollama
ollama pull qwen3.5:4b
ollama launch codex-app --model qwen3.5:4b --config -y
```

Fully quit and reopen Codex after regenerating the catalog.

## Remove the integration

To restore Codex to its pre-Ollama configuration:

```bash
ollama launch chatgpt --restore
```

Then fully quit and reopen the desktop app. Ollama keeps a backup under `~/.ollama/backup/codex-app/` before changing the Codex configuration.

## Troubleshooting

### The local model does not appear

Confirm Ollama is running and the model is installed:

```bash
curl --fail http://127.0.0.1:11434/api/tags
ollama list
```

Regenerate the integration and restart Codex:

```bash
ollama launch codex-app --model qwen3.5:4b --config -y
```

### OpenAI models disappeared

Do not manually set `model_provider = "ollama"` for the desktop app. That replaces the provider for the whole session. Use `ollama launch codex-app`, which creates the combined catalog and routing configuration.

### Codex cannot connect

Restart Ollama:

```bash
brew services restart ollama
curl --fail http://127.0.0.1:11434/api/tags
```

Then fully quit and reopen Codex.

### The Mac becomes slow or reports memory pressure

Switch to the smaller model:

```bash
ollama pull qwen3.5:2b
ollama launch codex-app --model qwen3.5:2b --config -y
```

Close memory-heavy applications before using a local model. The OpenAI models in the same picker do not load local model weights into the Mac's memory.

## Validation history

The combined routing method was validated on Windows with Ollama 0.34.2 and Codex CLI 0.155.0-alpha.9 on September 21, 2026. Both a local Qwen route and an OpenAI route completed successfully without an OpenAI API key. The macOS commands in this guide use Ollama's cross-platform `codex-app` integration documented by the installed launcher and the linked reference workflow.
