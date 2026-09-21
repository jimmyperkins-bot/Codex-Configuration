# Codex Configuration

Repeatable configuration guides and scripts for Codex.

## Local models on macOS

The macOS setup adds Ollama models to the Codex desktop model picker while preserving the OpenAI models available through an existing ChatGPT sign-in. It does not require an OpenAI API key.

- [Complete macOS guide](docs/codex-local-models-macos.md)
- [Setup script](scripts/setup-codex-local-models-macos.sh)
- [Verification script](scripts/verify-codex-local-models-macos.sh)

Quick start:

```bash
git clone https://github.com/jimmyperkins-bot/Codex-Configuration.git
cd Codex-Configuration
chmod +x scripts/*.sh
./scripts/setup-codex-local-models-macos.sh
```

The setup script selects a conservative Qwen model based on installed memory. Pass a model name to override the recommendation:

```bash
./scripts/setup-codex-local-models-macos.sh qwen3.5:4b
```

No credentials, tokens, Codex authentication files, or machine-specific backups belong in this repository.
