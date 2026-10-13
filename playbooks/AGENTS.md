# AGENTS.md — playbooks/

Ansible conventions. Root `AGENTS.md` has the layout.

## Roles

- Prefix vars with role name (`coding_agent_*`). Shared exception: `coding_agent` fact (claude-code | opencode) — prompted in product.yml, persisted to `~/.config/vamos/local_vars.yml`.
- Overridable defaults in `defaults/main.yml`; empty-list defaults keep roles cross-OS. Per-OS values only in `vars/{darwin,debian}.yml`. Defaults referencing other roles' vars need `| default(...)` so roles run standalone.
- Tasks in numbered sections: prereqs → install → configure → verify. Check prereqs before side effects (`failed_when: false` + `fail`); verify after (`stat` + `fail`).
- Idempotent: prefer `package`/`file`/`template`/`copy`/`git`; `command` requires honest `changed_when`. Second run = `changed=0`.
- `become: "{{ package_install_become }}"`. Secrets via vars + `no_log`, never committed.
- One role = one concern; tasks sharing the agent choice + dotdirs stay together (skills + Hindsight in `coding_agent`).

## Verify (CI gates — run all, must pass)

```bash
editorconfig-checker
shellcheck --severity=warning bootstrap/*.sh provision.sh
.venv/bin/ansible-lint playbooks/   # CI pins ansible-lint==6.22, ansible-core==2.18 (uv venv)
ansible-playbook --syntax-check playbooks/product.yml
ansible-playbook --syntax-check playbooks/operations.yml
```

## Test one role

Throwaway playbook: `include_vars` the OS vars (absolute path), list only that role. Then:

```bash
ANSIBLE_ROLES_PATH=playbooks/roles ansible-playbook /tmp/test_role.yml -e coding_agent=opencode
```

`-e` for prompted vars; `--check` to skip heavy installs; run twice to prove idempotency.
