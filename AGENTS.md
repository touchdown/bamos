# AGENTS.md

Provisioning repo: bootstraps + Ansible playbooks build dev workstations.

## Layout

- `bootstrap/bootstrap_{macos,debian}.sh` — base toolchain (CLT/Homebrew/apt, Ansible). Entry: `./provision.sh <product|operation>`.
- `playbooks/{product,operations}.yml` — `hosts: localhost`. product = full env; operations = shell + git.
- `playbooks/roles/*` — thin playbooks, logic in roles. OS-specific values only in `playbooks/vars/{darwin,debian}.yml`.
- Role order (product.yml = dependencies): `system_tools` → `shell_config` → `git_github` → `python_uv` → `coding_agent`.

## Golden rule

Any machine capability (package, dotfile, tool wiring) MUST be encoded in a role/vars file here — never left as a manual change. If you install or configure something by hand, add equivalent Ansible tasks before finishing, so `./provision.sh product` reproduces it.

## Ansible

Read `playbooks/AGENTS.md` before editing anything under `playbooks/` — conventions, CI verification commands, single-role testing.

## Style

- 2-space indent (4 in `*.sh`), LF, final newline, no trailing whitespace (md exempt).
- Update `README.md` when roles are added/renamed/removed.
