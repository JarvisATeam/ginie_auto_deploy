#!/usr/bin/env bash

# install.sh – Universal install script for GinieSystem
#
# This script is designed to run on macOS systems and prepares the host
# environment for the GinieSystem installation. It checks for required
# tooling (such as Homebrew), installs them if missing, clones the
# repository, and sets up a virtual environment. Throughout the process
# it logs its actions to a file in the current directory (install.log).

set -euo pipefail

LOG_FILE="$(pwd)/install.log"
echo "Starting GinieSystem installation at $(date)" | tee "$LOG_FILE"

# Check the operating system
OS_NAME=$(uname -s)
if [[ "$OS_NAME" != "Darwin" ]]; then
  echo "ERROR: This installer is intended for macOS (Darwin), but detected '$OS_NAME'." | tee -a "$LOG_FILE"
  exit 1
fi

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew…" | tee -a "$LOG_FILE"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | tee -a "$LOG_FILE"
else
  echo "Homebrew is already installed." | tee -a "$LOG_FILE"
fi

# Install dependencies
echo "Installing required packages…" | tee -a "$LOG_FILE"
brew install --quiet git python@3.11 qrencode &>> "$LOG_FILE"

# Clone or update GinieSystem repository
REPO_URL="https://github.com/${GIT_USER:-your-github-username}/ginie_auto_deploy.git"
TARGET_DIR="$HOME/.ginie-system"
if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "Updating existing GinieSystem repo…" | tee -a "$LOG_FILE"
  git -C "$TARGET_DIR" pull &>> "$LOG_FILE"
else
  echo "Cloning GinieSystem repo…" | tee -a "$LOG_FILE"
  git clone "$REPO_URL" "$TARGET_DIR" &>> "$LOG_FILE"
fi

# Set up Python virtual environment
echo "Setting up Python virtual environment…" | tee -a "$LOG_FILE"
python3 -m venv "$TARGET_DIR/venv" &>> "$LOG_FILE"
source "$TARGET_DIR/venv/bin/activate"
pip install --quiet -r "$TARGET_DIR/requirements.txt" &>> "$LOG_FILE"

echo "Installation completed at $(date)" | tee -a "$LOG_FILE"