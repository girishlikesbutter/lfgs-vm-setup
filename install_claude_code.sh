#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. Update and Upgrade System Packages ---
echo "--- Updating and upgrading system packages ---"
sudo apt update -y
sudo apt upgrade -y

# --- 2. Install nvm (Node Version Manager) ---
# nvm is highly recommended for managing Node.js versions
# The pipe ensures the script is executed.
echo "--- Installing nvm (Node Version Manager) ---"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Source nvm for the current session
# The nvm installer adds these lines to ~/.bashrc (or similar)
# We need to source them manually for nvm to be available in this script.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Verify nvm is available
if ! command -v nvm &> /dev/null
then
    echo "Error: nvm could not be found after installation and sourcing."
    echo "Please check the nvm installation process manually."
    exit 1
fi
echo "nvm installed and sourced successfully."

# --- 3. Install Node.js LTS via nvm ---
echo "--- Installing Node.js LTS via nvm ---"
nvm install --lts
nvm use --lts

# Verify Node.js and npm are available from nvm
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null
then
    echo "Error: Node.js or npm could not be found after nvm installation."
    echo "Please check the nvm install --lts command."
    exit 1
fi
echo "Node.js (LTS) and npm installed via nvm successfully."
node -v
npm -v

# --- 4. Install system-wide nodejs and npm (COMMENTED OUT - AVOID CONFLICTS WITH NVM) ---
# As a general rule, avoid installing Node.js via both nvm and apt.
# nvm gives you better control over Node.js versions for development.
# If you install it via apt, it might conflict with the nvm-managed version.
# If you absolutely need a system-wide Node.js that's independent of nvm,
# then uncomment the following lines. However, be aware of potential PATH conflicts.
# echo "--- Installing system-wide Node.js and npm (typically not needed with nvm) ---"
# sudo apt install -y nodejs npm

# --- 5. Install Claude Code CLI ---
echo "--- Installing Claude Code CLI globally ---"
# Ensure npm's global binaries are in the PATH for the current script.
# nvm typically manages this, but explicitly adding it is safer in scripts.
# The `npm install -g` command requires correct permissions. If you encounter
# EACCES errors, you might need to fix npm's permissions (see previous advice).
# nvm's setup usually handles this so you don't need sudo with npm.
npm install -g @anthropic-ai/claude-code

echo "--- Claude Code installation complete! ---"
echo "You may need to close and reopen your terminal (or SSH session) for the nvm paths to be fully persistent."
echo "Once reconnected, run 'claude' to start the Claude Code CLI and follow the authentication steps."
