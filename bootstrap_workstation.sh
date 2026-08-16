#!/bin/bash
set -e

PLAYBOOK_NAME="provision_workspace.yml"

echo "🚀 Starting 100% automated infrastructure bootstrap for your Mac..."

# Step 1: Ensure Xcode Command Line Tools are active
if ! xcode-select -p &>/dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⚠️ Please complete the Apple system installer popup, then rerun this script."
    exit 1
else
    echo "✅ Xcode Command Line Tools are verified."
fi

# Step 2: Install Homebrew cleanly if missing
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew package manager..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Configure shell paths dynamically for Apple Silicon Macs
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew is verified."
fi

# Step 3: Install Ansible via Homebrew if missing
if ! command -v ansible-playbook &>/dev/null; then
    echo "⚙️ Installing Ansible via Homebrew sandbox..."
    brew install ansible
else
    echo "✅ Ansible is verified."
fi


