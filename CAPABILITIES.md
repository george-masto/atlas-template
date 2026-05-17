# What atlas can do

atlas-template ships the **agent core** — the always-on, Telegram-shaped
agent. The integrations are things you build *on* that core, one at a
time, as you need them. This page is the menu: what works out of the box,
and what you can grow it into. Everything here is drawn from a real atlas
in daily use.

## Ships in the template

The core. Alive the moment you finish setup.

| Capability | What it is |
|---|---|
| Telegram front door | Reach atlas from your phone — DMs or group chats. No app to build; Telegram is the interface. |
| Always-on | Runs 24/7 as a launchd daemon. Restarts itself after a crash; works while you sleep. |
| Persistent memory | A durable scratchpad that survives restarts, so atlas accumulates context over time. |
| Filesystem + shell | Reads the machine it lives on; runs scripts, `git`, `ffmpeg`, anything shell-executable. |
| Scheduled triggers | Fire jobs on a cron — a morning briefing, a nightly task, a reminder. |
| Self-modifying | Edits its own config, commits the change, reloads itself. Every behavior shift is version-controlled. |
| MCP connectors | Calendar, Gmail, Linear, and more, through Claude Code — no API key; your Claude subscription covers it. |
| Daily briefing | One scheduled message each morning that ties your day together. |
| Group chats | Join a family or work chat; per-group memory; private context stays private. |
| Voice in | Voice notes you send are transcribed locally (whisper.cpp) — talk to atlas, no typing. |

## Build on top

The integration menu. You add these as you go — the template gives you
the pattern; each one is its own small module.

| Integration | What it gives you |
|---|---|
| Knowledge bases | A research wiki and a private reflections vault. "What have I been thinking about re: X?" answered from your own notes. |
| Email drafting | atlas studies your sent mail, learns your voice, and drafts replies into your Gmail Drafts. It never sends. |
| Voice out | atlas sends you spoken voice notes — local neural TTS, no cloud, no cost. |
| Document collaboration | atlas drafts into a Google Doc; you leave inline comments and edits; it reads them, revises in place, and replies on the threads. |
| Slides + images | Generate an image from a description, build it into a slide deck. |
| Data sources | YouTube history, voice memos, films, local events — indexed and cross-referenced. Ask questions no single app could answer. |
| Proactive pings | atlas reaches out on its own — a finished task, something worth seeing — not only when you message first. |

## What you end up using it for

- *"What was that video / article / note from last month?"* — found across everything you've saved.
- *"Draft a reply to this."* — in your voice, waiting in your Drafts.
- *"What's on my plate today?"* — the morning brief: calendar, mail, tasks, weather, in one message.
- *"What did past-me think about X?"* — answered from your own knowledge base.
- Build or edit a document by talking to it.
- Add atlas to a group chat — it knows what's private and what isn't.

The narrative versions of these, drawn from real use, are in the
[README](README.md#what-this-looks-like-in-practice).

## The honest frame

atlas is a [Claude Code](https://code.claude.com/docs/en/overview) session
in channels mode, running on your own machine. It is not a product you
install — it is a pattern you grow. The template is the seed; the
integrations above are what you choose to plant.
