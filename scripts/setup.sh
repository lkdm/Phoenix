#!/usr/bin/env bash

set -euo pipefail

# Get the directory of the current script
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Add helpers directory to PATH for all scripts to use
export PATH="$SCRIPT_DIR/helpers:$PATH"

# Execute each scirpt in base
for script in "$SCRIPT_DIR"/base/*.sh; do
  if [[ -f "$script" ]]; then
    echo "::group::===$(basename "$script")==="
    bash "$script"
    echo "::endgroup::"
  fi
done
