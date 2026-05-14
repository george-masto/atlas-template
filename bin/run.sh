#!/bin/bash
# atlas: long-running Claude Code session with the Telegram channels plugin.
# Invoked by ~/Library/LaunchAgents/com.<user>.atlas.plist with KeepAlive=true.
# When the inner claude exits, this script exits and launchd restarts it
# (subject to ThrottleInterval).

set -u

# Explicit PATH so launchd/tmux subprocesses can find homebrew, bun, claude
# without relying on user shell init (.zshrc isn't loaded under launchd).
export PATH="/usr/local/bin:${HOME}/.bun/bin:${HOME}/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

SESSION_NAME="atlas"
TMUX_BIN="$(command -v tmux || echo /usr/local/bin/tmux)"
CLAUDE_BIN="${HOME}/.local/bin/claude"
LOG_DIR="${HOME}/atlas/logs"

mkdir -p "${LOG_DIR}"

ts() { date "+%Y-%m-%d %H:%M:%S"; }
log() { printf '%s  %s\n' "$(ts)" "$1" >> "${LOG_DIR}/run.log"; }

log "=== wrapper start (PATH=${PATH}) ==="

# Kill any stale tmux session so we start clean.
"${TMUX_BIN}" kill-session -t "${SESSION_NAME}" 2>/dev/null && \
  log "killed pre-existing tmux session" || true

# Start the claude session under a detached tmux pane.
"${TMUX_BIN}" new-session -d -s "${SESSION_NAME}" \
  "${CLAUDE_BIN} --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions"

# Mirror everything in the pane to a log file so we can tail it without attaching.
"${TMUX_BIN}" pipe-pane -t "${SESSION_NAME}" "cat >> ${LOG_DIR}/atlas.log"

log "spawned claude under tmux session '${SESSION_NAME}'"

# Auto-dismiss the two initial trust prompts that claude shows on first run
# of an unfamiliar workspace and the first invocation of the plugin's bun
# subprocess. Send Enters at staggered intervals; both prompts default to
# "Yes, trust" so Enter is the correct action. Safe to send extras: when
# the REPL is idle, Enter just executes empty input.
( sleep 8;  "${TMUX_BIN}" send-keys -t "${SESSION_NAME}" Enter;
  sleep 4;  "${TMUX_BIN}" send-keys -t "${SESSION_NAME}" Enter;
  sleep 10; "${TMUX_BIN}" send-keys -t "${SESSION_NAME}" Enter; ) &
log "scheduled auto-Enter to clear trust prompts"

# Block until the session disappears (claude exited). Cheap poll; this script
# is itself supervised by launchd, so we don't try to be clever.
while "${TMUX_BIN}" has-session -t "${SESSION_NAME}" 2>/dev/null; do
  sleep 10
done

log "tmux session ended; wrapper exiting so launchd can restart"
exit 1
