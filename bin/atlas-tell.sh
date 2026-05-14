#!/bin/bash
# Inject a prompt into the running atlas claude session via tmux.
#
# launchd-fired scripts use this to ask atlas to do work that needs MCP tools
# (Calendar, Gmail, Linear, etc.) which only live inside the running session.
# The bridge: tmux send-keys delivers the text to claude's stdin exactly as if
# the user had typed it.
#
# Convention: prompts triggered this way start with "@@@<NAME>@@@" so atlas's
# CLAUDE.md can recognize them and respond without reaching for a Telegram reply
# unless the task expects one.
set -u
TMUX_BIN="$(command -v tmux || echo /usr/local/bin/tmux)"
SESSION="atlas"

if [ -z "${1:-}" ]; then
  echo "usage: $0 '<prompt text>'" >&2
  exit 2
fi

if ! "${TMUX_BIN}" has-session -t "${SESSION}" 2>/dev/null; then
  echo "no tmux session '${SESSION}' — atlas isn't running" >&2
  exit 3
fi

# send-keys with -l so leading dashes in the prompt don't get parsed as flags
"${TMUX_BIN}" send-keys -t "${SESSION}" -l -- "$1"
"${TMUX_BIN}" send-keys -t "${SESSION}" Enter
