# Connect: Google (Calendar, Gmail, Drive, Docs)

There are two ways atlas reaches Google, and most users want the first.

## Path A — Claude's built-in Google connectors (recommended)

atlas runs on Claude Code. Claude can connect Google Calendar, Gmail, and
Drive directly, with Google's OAuth handled for you — no cloud project, no
client secret. The daily-brief recipe in `CLAUDE.md` uses exactly these.

Steps:
1. In Claude (the Claude app or claude.ai), open **Settings → Connectors**
   (also called Integrations).
2. Connect **Google Calendar**, **Gmail**, and **Google Drive**. Each runs
   a normal Google sign-in and consent.
3. Back in atlas, those appear as the `Google_Calendar`, `Gmail`, and
   `Google_Drive` MCP tools. Nothing to store on disk.

If all the user wants is the morning brief and email drafting, stop here.

## Path B — a self-managed Google Cloud OAuth client (advanced)

Only needed for **custom integrations that call a Google API directly** —
for example a YouTube watch-history importer, or a Google Docs editor built
on the Docs API. Those need their own OAuth client.

Steps:
1. Go to **console.cloud.google.com** and create a project (top bar →
   project picker → New Project).
2. **Enable the APIs** the integration needs: APIs & Services → Library →
   search for and Enable each one (e.g. *YouTube Data API v3*, *Google Docs
   API*, *Google Drive API*, *Google Sheets API*, *Google Slides API*).
3. **OAuth consent screen**: APIs & Services → OAuth consent screen → choose
   **External**, fill the basics, and under *Test users* add the user's own
   Google address. Staying in "testing" mode is fine for personal use — no
   Google verification review needed.
4. **Create the client**: APIs & Services → Credentials → Create Credentials
   → **OAuth client ID** → application type **Desktop app**. (A "Web
   application" type with a loopback redirect such as
   `http://127.0.0.1:8765/callback` also works, and is what some atlas
   integrations expect — match whatever that integration's own docs say.)
5. **Download the client JSON** and save it to
   `~/.claude/channels/<service>/client.json` (e.g. `.../youtube/client.json`).
   `chmod 600` it.
6. Run that integration's `auth` command. It opens a Google consent page,
   captures the redirect, and writes a `token.json` next to `client.json`.

## Verify

- Path A: ask atlas to list today's calendar events. If it returns them,
  the connector works.
- Path B: run the integration's `auth`, then its `whoami`-style check. A
  successful account readout means the client and token are both good.

## Note

Console layouts shift over time. If a menu name here is not exact, look for
the nearest equivalent under *APIs & Services* — the flow (enable APIs →
consent screen → create OAuth client → download JSON) stays the same.
