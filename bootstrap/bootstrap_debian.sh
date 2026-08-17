#!/bin/bash
set -e

echo "🚀 Starting Debian/Ubuntu bootstrap..."

# Step 1: Ensure apt is available
if ! command -v apt-get &>/dev/null; then
    echo "❌ apt-get not found. Only Debian/Ubuntu are supported."
    exit 1
fi

# Step 2: Install base packages and Ansible
if ! command -v ansible-playbook &>/dev/null; then
    echo "📦 Installing base packages and Ansible..."
    sudo apt-get update
    sudo apt-get install -y ansible git curl zsh
else
    echo "✅ Ansible is verified."
fi
