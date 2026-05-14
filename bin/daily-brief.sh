#!/bin/bash
# Daily-briefing trigger. Fired by launchd at ~3am local so atlas
# composes the brief while you sleep.
#
# This script doesn't compose the briefing — it triggers atlas's running
# session to do so, because the data sources (Calendar / Gmail / Linear)
# live behind MCPs only the session can call.
set -u
PATH="/usr/local/bin:${HOME}/.bun/bin:${HOME}/.local/bin:/usr/bin:/bin"
LOG="${HOME}/atlas/logs/daily-brief.log"
mkdir -p "${HOME}/atlas/logs"

ts() { date "+%Y-%m-%d %H:%M:%S %Z"; }
log() { printf '%s  %s\n' "$(ts)" "$1" >> "${LOG}"; }

log "=== daily-brief trigger ==="

PROMPT='@@@DAILY-BRIEFING@@@ Daily briefing time. See CLAUDE.md "Daily briefing trigger" for the recipe. Send the resulting message to the user via Telegram.'

if ! "${HOME}/atlas/bin/atlas-tell.sh" "${PROMPT}"; then
  log "ERROR: atlas-tell.sh failed; atlas may be down"
  exit 1
fi

log "trigger delivered to atlas session"
