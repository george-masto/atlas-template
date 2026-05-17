---
name: connect
description: >-
  Guided, interactive setup for the API credentials and OAuth clients atlas
  needs to reach outside services — Telegram, Google, Reddit, and more. Walks
  the user provider by provider with current, click-by-click steps, writes
  each secret to the right file, and verifies it before moving on. Use when
  setting atlas up for the first time or connecting a new service.
---

# connect — guided credential setup

Getting credentials is the sharpest friction in standing atlas up. Every
provider hides its developer console somewhere different, the OAuth dance
varies, and some (Reddit) gate access behind an approval form. This skill
turns that into a guided conversation: one provider at a time, one step at
a time, verified as you go.

## How to run it

1. **Ask what to connect.** Show the user this menu and let them pick one or
   more. Do not start until they choose.

   | Service  | What it unlocks |
   |----------|-----------------|
   | Telegram | The bot that is atlas's front door. Required. |
   | Google   | Calendar, Gmail, Drive, Docs — the daily brief and drafting. |
   | Reddit   | Read-only Reddit access for research integrations. |

   Telegram is mandatory for atlas to run at all. If its credentials are
   missing, recommend starting there.

2. **For each chosen service**, read `providers/<service>.md` from this
   skill's directory and walk the user through it. Rules for the walk:
   - Present **one step at a time.** Wait for the user to do it and report
     back before showing the next. Never paste the whole guide at once.
   - Console UIs drift. If a label the guide names is not on screen, reason
     about the equivalent and adapt — do not stall.
   - When the user hits an error, help debug it before moving on.
   - **Verify** with the check at the end of each provider guide before
     declaring that service done.

3. **Handle secrets carefully.**
   - Secrets belong in files, not in chat history. Write them yourself to
     the path the guide specifies (under `~/.claude/channels/<service>/`)
     and `chmod 600` the file.
   - If the user pastes a secret into the chat, still write it to the file,
     and let them know the file is the system of record.
   - Never echo a full token back in plain text. A masked tail is enough.

4. **Close out.** Summarize what got connected and what is still pending —
   for example, Reddit's API-access form can take days to be approved.

## Adding more providers later

Each provider is just a `providers/<name>.md` file: click-by-click steps,
the destination path for the credential, and a verification command. To
support a new service, add one file in that shape and a row to the menu
above. Keep this SKILL.md as orchestration only — the per-provider detail
stays in its own file so it loads on demand.
