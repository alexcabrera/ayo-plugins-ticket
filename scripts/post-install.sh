#!/bin/bash
set -euo pipefail

# Post-install script for ayo-plugins-ticket
# Creates symlink to tk binary in user's PATH

PLUGIN_DIR="$1"
TK_BIN="$PLUGIN_DIR/bin/tk"

# Ensure the tk binary exists and is executable
if [[ ! -x "$TK_BIN" ]]; then
    echo "Error: tk binary not found or not executable at $TK_BIN" >&2
    exit 1
fi

# Determine target directory for symlink
# Prefer ~/.local/bin if it exists, otherwise try to create it
TARGET_DIR="${HOME}/.local/bin"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Creating $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
fi

# Create symlink
TARGET_LINK="$TARGET_DIR/tk"

if [[ -L "$TARGET_LINK" ]]; then
    # Remove existing symlink
    rm "$TARGET_LINK"
elif [[ -e "$TARGET_LINK" ]]; then
    echo "Warning: $TARGET_LINK exists and is not a symlink, skipping" >&2
    exit 0
fi

ln -s "$TK_BIN" "$TARGET_LINK"
echo "Created symlink: $TARGET_LINK -> $TK_BIN"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
    echo ""
    echo "Note: $TARGET_DIR is not in your PATH."
    echo "Add this to your shell profile:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
