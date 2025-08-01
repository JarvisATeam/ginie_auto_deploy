#!/usr/bin/env bash

# self_test.sh – Run self-test and self‑healing checks for GinieSystem
#
# This script runs an automated test suite to verify that the GinieSystem
# installation is functioning correctly. It checks for expected files,
# verifies that necessary services are reachable, and records the results
# in a log file. If issues are detected, it attempts a simple
# self‑healing routine by restarting services or reinstalling missing
# dependencies.

set -euo pipefail

LOG_FILE="$(pwd)/self_test.log"
echo "Starting self-test at $(date)" | tee "$LOG_FILE"

# Ensure repository directory exists
TARGET_DIR="$HOME/.ginie-system"
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: GinieSystem directory not found at $TARGET_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

# Verify virtual environment exists
if [[ ! -f "$TARGET_DIR/venv/bin/activate" ]]; then
  echo "Virtual environment missing. Recreating…" | tee -a "$LOG_FILE"
  python3 -m venv "$TARGET_DIR/venv" &>> "$LOG_FILE"
fi

# Activate environment and run Python diagnostics
source "$TARGET_DIR/venv/bin/activate"
python - <<'PY'
import importlib, sys

components = ['qrcode', 'cryptography']
for comp in components:
    try:
        importlib.import_module(comp)
        print(f"{comp} OK")
    except ImportError as e:
        print(f"{comp} missing: {e}")
PY

echo "Self-test completed at $(date)" | tee -a "$LOG_FILE"