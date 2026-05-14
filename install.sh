#!/bin/bash
# atlas: interactive bootstrap installer.
#
# Walks you through:
#   1. Copying the template into ~/atlas
#   2. Substituting your username into the launchd plists
#   3. Setting up the Telegram bot config (.env + access.json)
#   4. Installing + loading the launchd jobs
#
# Run this from inside the cloned atlas-template directory.
# Safe to re-run: skips steps already done, prompts before overwriting.

set -eu

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${HOME}/atlas"
USER_NAME="$(id -un)"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
info() { printf '  %s\n' "$1"; }
warn() { printf '\033[33m  ⚠ %s\033[0m\n' "$1"; }
ok()   { printf '\033[32m  ✓ %s\033[0m\n' "$1"; }
ask()  { printf '\033[36m  ? %s\033[0m ' "$1"; }

bold "atlas installer"
echo
info "user:       ${USER_NAME}"
info "target:     ${TARGET_DIR}"
info "source:     ${SOURCE_DIR}"
echo

# ------------------------------------------------------------------
# Step 1 — prereq check
# ------------------------------------------------------------------
bold "1. Prerequisites"

MISSING=0
for cmd in tmux git curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    warn "missing: $cmd"
    MISSING=1
  else
    ok "found: $cmd"
  fi
done
if [ ! -x "${HOME}/.local/bin/claude" ] && ! command -v claude >/dev/null 2>&1; then
  warn "Claude Code 'claude' binary not found in ${HOME}/.local/bin or PATH"
  warn "install from https://docs.claude.com/en/docs/claude-code/overview"
  MISSING=1
else
  ok "found: claude"
fi

if [ "$MISSING" = "1" ]; then
  warn "install missing tools, then re-run this script"
  exit 1
fi
echo

# ------------------------------------------------------------------
# Step 2 — copy template to ~/atlas
# ------------------------------------------------------------------
bold "2. Copy template to ~/atlas"

if [ -e "${TARGET_DIR}" ]; then
  ask "${TARGET_DIR} already exists. Overwrite (existing MEMORY.md preserved)? [y/N]"
  read -r ANSWER
  if [ "${ANSWER:-N}" != "y" ] && [ "${ANSWER}" != "Y" ]; then
    info "skipping copy, using existing ${TARGET_DIR}"
  else
    # Preserve MEMORY.md if present
    if [ -f "${TARGET_DIR}/MEMORY.md" ]; then
      cp "${TARGET_DIR}/MEMORY.md" "/tmp/atlas-memory-backup.md"
      ok "backed up MEMORY.md to /tmp/atlas-memory-backup.md"
    fi
    rsync -a --exclude='.git' --exclude='install.sh' --exclude='assets' \
      "${SOURCE_DIR}/" "${TARGET_DIR}/"
    if [ -f "/tmp/atlas-memory-backup.md" ]; then
      mv "/tmp/atlas-memory-backup.md" "${TARGET_DIR}/MEMORY.md"
      ok "restored MEMORY.md"
    fi
    ok "copied scaffolding into ${TARGET_DIR}"
  fi
else
  rsync -a --exclude='.git' --exclude='install.sh' --exclude='assets' \
    "${SOURCE_DIR}/" "${TARGET_DIR}/"
  ok "created ${TARGET_DIR}"
fi

mkdir -p "${TARGET_DIR}/logs" "${TARGET_DIR}/integrations"
chmod +x "${TARGET_DIR}/bin/"*.sh
echo

# ------------------------------------------------------------------
# Step 3 — collect Telegram credentials
# ------------------------------------------------------------------
bold "3. Telegram setup"

CHANNELS_DIR="${HOME}/.claude/channels/telegram"
mkdir -p "${CHANNELS_DIR}"
chmod 700 "${CHANNELS_DIR}"

if [ -f "${CHANNELS_DIR}/.env" ] && grep -q TELEGRAM_BOT_TOKEN "${CHANNELS_DIR}/.env" 2>/dev/null; then
  ok "${CHANNELS_DIR}/.env already has a TELEGRAM_BOT_TOKEN — keeping it"
else
  echo
  info "you'll need a Telegram bot token from @BotFather (https://t.me/BotFather):"
  info "  1. open Telegram, message @BotFather"
  info "  2. send /newbot, follow the prompts, copy the token"
  echo
  ask "paste the bot token (input hidden):"
  stty -echo
  read -r TG_TOKEN
  stty echo
  echo

  if [ -z "${TG_TOKEN}" ]; then
    warn "no token given. skipping .env write — you can do this manually later."
  else
    echo "TELEGRAM_BOT_TOKEN=${TG_TOKEN}" > "${CHANNELS_DIR}/.env"
    chmod 600 "${CHANNELS_DIR}/.env"
    ok "wrote ${CHANNELS_DIR}/.env (mode 600)"
  fi
fi

if [ -f "${CHANNELS_DIR}/access.json" ]; then
  ok "${CHANNELS_DIR}/access.json already exists — leaving it alone"
else
  echo
  info "you'll also need your Telegram user ID so only you can reach the bot."
  info "easiest way: message @userinfobot in Telegram — it replies with your ID."
  echo
  ask "paste your Telegram user ID (numeric, ~9-10 digits):"
  read -r TG_USER_ID
  if [ -z "${TG_USER_ID}" ]; then
    warn "no user ID given. atlas will not be reachable until you set access.json manually."
  else
    cat > "${CHANNELS_DIR}/access.json" <<JSON
{
  "dmPolicy": "allowlist",
  "allowFrom": [
    "${TG_USER_ID}"
  ],
  "groups": {},
  "pending": {}
}
JSON
    chmod 600 "${CHANNELS_DIR}/access.json"
    ok "wrote ${CHANNELS_DIR}/access.json — only your user ID can reach the bot"
  fi
fi
echo

# ------------------------------------------------------------------
# Step 4 — template launchd plists with the username
# ------------------------------------------------------------------
bold "4. Render launchd plists"

LA_DIR="${HOME}/Library/LaunchAgents"
mkdir -p "${LA_DIR}"

for src in "${TARGET_DIR}/launchd/"com.user.atlas*.plist; do
  base="$(basename "$src" | sed "s/com\.user\./com.${USER_NAME}./")"
  dst="${LA_DIR}/${base}"
  if [ -f "${dst}" ]; then
    ok "${dst} already exists — leaving it alone"
    continue
  fi
  sed "s/{{USER}}/${USER_NAME}/g" "${src}" > "${dst}"
  ok "rendered ${dst}"
done
echo

# ------------------------------------------------------------------
# Step 5 — review + load
# ------------------------------------------------------------------
bold "5. Load launchd jobs"

info "before loading, give the rendered plists in ${LA_DIR} a quick read."
info "they will:"
info "  - keep atlas alive 24/7 via run.sh (com.${USER_NAME}.atlas.plist)"
info "  - fire a daily briefing trigger at 07:03 local (com.${USER_NAME}.atlas.daily-brief.plist)"
echo
ask "load both now with 'launchctl load -w'? [y/N]"
read -r ANSWER
if [ "${ANSWER:-N}" = "y" ] || [ "${ANSWER}" = "Y" ]; then
  for plist in "${LA_DIR}/com.${USER_NAME}.atlas"*.plist; do
    launchctl load -w "${plist}"
    ok "loaded $(basename "${plist}")"
  done
else
  info "skipped. to load later:"
  info "  launchctl load -w ${LA_DIR}/com.${USER_NAME}.atlas.plist"
  info "  launchctl load -w ${LA_DIR}/com.${USER_NAME}.atlas.daily-brief.plist"
fi
echo

# ------------------------------------------------------------------
# Done
# ------------------------------------------------------------------
bold "Done."
echo
info "next steps:"
info "  1. open Telegram, search for the bot you created, send /start"
info "  2. if atlas is loaded, it should reply within a few seconds"
info "  3. tail the logs to watch it come up:"
info "     tail -f ${TARGET_DIR}/logs/atlas.log"
info "  4. if anything looks off, check:"
info "     ${TARGET_DIR}/logs/launchd.err.log"
info "     launchctl list | grep ${USER_NAME}.atlas"
echo
info "the agent's behavior is governed by ${TARGET_DIR}/CLAUDE.md."
info "edit it to teach atlas about your life, your preferences, and what to do on a schedule."
echo
info "for personal-data integrations (YouTube, Gmail drafting, Voice Memos, events, etc.):"
info "  see the README's 'What this looks like in practice' section,"
info "  then ask atlas to scaffold them one at a time."
