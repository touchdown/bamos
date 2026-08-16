#!/usr/bin/env bash
# ==============================================================================
# Usage: ./provision.sh <role> [ansible-options]
# Examples:
#   ./provision.sh product
#   ./provision.sh operation -K
# ==============================================================================

set -euo pipefail

BOOTSTRAP_SCRIPT="./bootstrap_workstation.sh"
PLAYBOOKS_DIR="./playbooks"

usage() {
    cat <<EOF
Usage: $0 <role> [ansible-options]

Available roles:
  product    - Runs playbooks/product.yml
  operation  - Runs playbooks/operation.yml

Extra arguments are passed directly to ansible-playbook.
EOF
    exit 1
}

if [[ $# -lt 1 ]]; then
    echo "Error: Missing role argument."
    usage
fi

ROLE="$1"
shift  # Shift parameters so "$@" contains ONLY extra flags (-K, -v, etc.)

ensure_bootstrap() {
    if [[ -f "$BOOTSTRAP_SCRIPT" ]]; then
        echo "==> Running bootstrap script (${BOOTSTRAP_SCRIPT})..."
        chmod +x "$BOOTSTRAP_SCRIPT"
        "$BOOTSTRAP_SCRIPT"
    else
        echo "Warning: Bootstrap script '${BOOTSTRAP_SCRIPT}' not found. Skipping bootstrap step." >&2
    fi
}

run_playbook() {
    local role_name="$1"
    shift # Remove role_name so "$@" holds remaining extra flags
    
    local playbook_path="${PLAYBOOKS_DIR}/${role_name}.yml"

    if [[ ! -f "$playbook_path" ]]; then
        echo "Error: Playbook '${playbook_path}' not found." >&2
        exit 1
    fi

    echo "==> Running Playbook: ${playbook_path}"
    # Explicitly pass the resolved path FIRST, then remaining flags
    ansible-playbook "$playbook_path" "$@"
}

# --- Execution Entrypoint ---

case "$ROLE" in
    product|operation)
        ensure_bootstrap
        run_playbook "$ROLE" "$@"
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "Error: Unknown role '$ROLE'."
        usage
        ;;
esac

