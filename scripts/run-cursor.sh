#!/usr/bin/env bash
set -e

# Approve MCP server (required in CI)
agent mcp approve gitea --yes

# Build prompt from comment
scripts/build-prompt.sh > prompt.md

# Run Cursor headless
cursor run \
  --headless \
  --prompt-file prompt.md
