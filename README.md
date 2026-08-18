# bamos

**Ba**sic **mos** ... no — it's short for "bootstrap environments".

## About Me

`bamos` is my personal, repeatable way to stand up a fresh workstation. Instead of
clicking through installers and pasting aliases by hand, a single command walks a new (or
re-imaged) machine through the whole pipeline: base toolchain → Ansible → provisioning
playbooks. The result is a consistent shell, Git identity, and language/LLM toolchain on
every machine I touch.

## Purpose

This repository provisions development environments from scratch, end to end:

- **Bootstrap layer** — per-OS scripts install and verify the base toolchain:
  - `bootstrap/bootstrap_macos.sh` — Xcode CLT, Homebrew, Ansible (macOS)
  - `bootstrap/bootstrap_debian.sh` — apt, Ansible (Debian/Ubuntu)
- **Provisioning layer** — `provision.sh` auto-detects the OS, runs the matching bootstrap
  script, then hands off to Ansible playbooks locally (`hosts: localhost`).
- **Per-OS variables** — `playbooks/vars/{darwin,debian}.yml` hold OS-specific settings
  (package manager, package lists, binary paths, Git credential helper) so the roles stay
  OS-agnostic.
- **Roles** — reusable Ansible roles that keep the playbooks thin and composable:

  | Role           | What it configures                                        |
  | -------------- | --------------------------------------------------------- |
  | `system_tools` | CLI tools (ripgrep, jq, fzf, etc.)                        |
  | `shell_config` | Zsh, Oh My Zsh, shell/runtime aliases                     |
  | `git_github`   | `.gitconfig`, Git aliases, GitHub SSH setup               |
  | `python_uv`    | `uv` and standalone Python                                |
  | `llm`          | LLM CLI utilities, Ollama models, local AI desktop apps  |

The `llm` role pulls `gemma4:12b-mlx` (the default used by OpenCode) and
`qwen3.8:27b-mlx` into Ollama.

Two environment profiles are supported:

- **`product`** — full dev environment: shell + Git + Python + LLM toolchain
- **`operation`** — minimal ops environment: shell + Git only

## Instructions

### Prerequisites

- macOS (Apple Silicon or Intel) or Debian/Ubuntu
- A terminal and an internet connection
- Administrator access (used during Homebrew/apt/CLT installs)

### Quick start

```bash
git clone git@github.com:touchdown/bamos.git
cd bamos

# Full development environment
./provision.sh product

# Minimal ops environment
./provision.sh operation
```

### What each script does

`provision.sh` detects the OS, runs the matching bootstrap script, then hands off to
`ansible-playbook` for the chosen role:

```bash
./provision.sh <role> [ansible-options]

# Example: prompt for the Ansible sudo/BECOME password (for package installs)
./provision.sh product -K
```

Extra arguments are passed straight through to `ansible-playbook`
(e.g. `-K`, `-v`, `--check`).

## CI

Pull requests are checked with:

- **editorconfig-checker** — enforces `.editorconfig` style rules
- **ShellCheck** — lints `bootstrap/*.sh` and `provision.sh`
- **ansible-lint** — lints the playbooks (installed via uv, with pinned
  `ansible-lint` 6.22 / `ansible-core` 2.18)

### First-run notes

- The `product` playbook asks for your **Git user name and email** the first time and
  saves them to `~/.config/vamos/local_vars.yml` (`0600`) so later runs skip the prompt.
- On macOS, if Xcode Command Line Tools are missing, the bootstrap script starts the Apple
  installer popup, then exits — **rerun the script** after the install completes.
- Homebrew is configured for Apple Silicon (`/opt/homebrew`) automatically.
- On Debian/Ubuntu, package installs run with `sudo` (pass `-K` if prompted).
