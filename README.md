# bamos

**Ba**sic **mos** ... no — it's short for "bootstrap environments".

## About Me

`bamos` is my personal, repeatable way to stand up a fresh macOS workstation. Instead of
clicking through installers and pasting aliases by hand, a single command walks a new (or
re-imaged) Mac through the whole pipeline: Xcode Command Line Tools → Homebrew → Ansible →
provisioning playbooks. The result is a consistent shell, Git identity, and language/LLM
toolchain on every machine I touch.

## Purpose

This repository provisions macOS development environments from scratch, end to end:

- **Bootstrap layer** — `bootstrap_workstation.sh` installs and verifies the base
  toolchain (Xcode CLT, Homebrew, Ansible).
- **Provisioning layer** — `provision.sh` runs Ansible playbooks locally
  (`hosts: localhost`) that configure the environment by role.
- **Roles** — reusable Ansible roles that keep the playbooks thin and composable:

  | Role           | What it configures                                        |
  | -------------- | --------------------------------------------------------- |
  | `system_tools` | CLI tools via Homebrew (ripgrep, jq, fzf, etc.)        |
  | `shell_config` | Zsh, Oh My Zsh, shell/runtime aliases                     |
  | `git_github`   | `.gitconfig`, Git aliases, GitHub SSH setup               |
  | `python_uv`    | `uv`, standalone Python, `mlx-lm`                         |
  | `llm`          | LLM CLI utilities and local AI desktop apps               |

Two environment profiles are supported:

- **`product`** — full dev environment: shell + Git + Python + LLM toolchain
- **`operation`** — minimal ops environment: shell + Git only

## Instructions

### Prerequisites

- macOS (Apple Silicon or Intel)
- A terminal and an internet connection
- Administrator access (used during Homebrew/CLT installs)

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

`provision.sh` first runs `bootstrap_workstation.sh`, then hands off to
`ansible-playbook` for the chosen role:

```bash
./provision.sh <role> [ansible-options]

# Example: prompt for the Ansible sudo/BECOME password (for cask installs)
./provision.sh product -K
```

Extra arguments are passed straight through to `ansible-playbook`
(e.g. `-K`, `-v`, `--check`).

### First-run notes

- The `product` playbook asks for your **Git user name and email** the first time and
  saves them to `~/.config/vamos/local_vars.yml` (`0600`) so later runs skip the prompt.
- If Xcode Command Line Tools are missing, the bootstrap script starts the Apple
  installer popup, then exits — **rerun the script** after the install completes.
- Homebrew is configured for Apple Silicon (`/opt/homebrew`) automatically.

