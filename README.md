# atlas

<p align="center">
  <img src="assets/atlas-hero.jpg" alt="atlas: a kneeling figure holds up a sphere woven from messages, calendar events, voice notes, video, and chat threads" width="720">
</p>

## *hold up your digital world*

atlas is a personal AI agent that runs on your own Mac, 24/7, and listens
to you through Telegram. It's a [Claude Code session](https://code.claude.com/docs/en/overview)
in channels mode: Claude Code stays open in the background and a Telegram
plugin pushes your messages straight into it, so the same session that has
your files open, your scripts ready, and your memory accumulated is the
one that replies on your phone.

Claude.ai has gotten very good. It remembers things across conversations
now, it can read your Gmail and Calendar through connectors, and Cowork
spins up sandboxes for real work. atlas covers a different shape: it lives
*on* the machine you use, not in a cloud sandbox. It reads the files only
you have access to, runs scripts you write, fires crons while you sleep,
and replies through whatever messaging app you live in. Two complementary
tools, not competing ones.

Setup is about 30 minutes, and you don't need an Anthropic API key. atlas
runs through your Claude Code installation, which authenticates against
your Claude Pro or Max subscription. You pay your usual subscription and
nothing per call.

(You could in theory deploy this on a cloud server too, but the whole
point is to have it on the machine where your life actually lives: your
laptop, your photos library, your notes, your text history. Cloud loses
the "your data never leaves" property.)

## What this looks like in practice

A handful of scenes drawn from real use.

### You want to talk about something you watched, read, or wrote

"What was that video Karpathy posted last week on the new agent
benchmark?" atlas searches your YouTube watch history (synced from your
liked videos + Takeout history), the captions of the videos themselves,
your browser history, and your saved articles. It finds the one you
meant, pulls the relevant section, and you have an actual conversation
about it grounded in what was actually said.

The same flow works for likes. You like a video on YouTube at 2am, atlas
notices the next morning, reads the title and channel against your
existing playlists, and proposes where to file it. You reply `yes` or
`<other-playlist>`. After a stretch of good calls it stops asking and
just sorts.

### You record a voice note while walking

You hold the mic button in Telegram, talk for 30 seconds, send. atlas
transcribes it locally via whisper.cpp, so no audio leaves your Mac, and
replies in seconds. iPhone voice memos sync via iCloud and get indexed
the same way. Weeks later you ask "what was that idea I had about
photoacoustic imaging while walking last month?" and atlas finds it in
the transcript archive.

Whisper handles dozens of languages and auto-detects per recording. You
can talk to atlas in Greek about something technical and it'll transcribe
and answer in whichever language fits the conversation.

### You wake up

A cron fires at 3am. While you sleep, atlas pulls today's calendar, the
overnight email, your open tracker tickets, the weather, watchlist debt,
events near you that match your interests, anything pending. By the time
you reach for your phone, a single Telegram message is waiting that ties
it all together. Sections with nothing get omitted. Things that need
action are surfaced first.

### An email needs a real reply

atlas studies a sample of your sent email and builds a writing-style
profile, then keeps refining it as you edit the drafts it produces.
Vocabulary signatures, lane registers, hard rules ("never use em-dashes"),
preferred sign-offs. When a human writes you a thread that warrants a
reply, atlas composes a draft and saves it to your Gmail Drafts folder.
It never sends. You open Drafts on your phone, edit if needed, hit send.
Every send and every edit feeds back into the profile, so the drafts get
closer to your actual voice over time.

### You want to know what you cared about six months ago

atlas queries your voice memos, your notes, your knowledge base, the
articles you saved, the films you logged, the threads you replied to.
It surfaces the throughline: what topics kept resurfacing, what changed,
what you stopped caring about. Cross-source questions that no single
cloud tool can answer because no single cloud tool has the whole
picture.

### You add atlas to a group chat with family or friends

Each group gets an isolated memory file at
`~/atlas/groups/<chat_id>/MEMORY.md`. The personal stuff in your DM
memory is loaded but treated as confidential. atlas knows it, never
volunteers it to the group, and deflects personal questions back to you.
Group memories don't bleed across to your DM, either.

The group's own memory tracks who's in it, the inside jokes, the
ongoing topics, and an explicit `## Consent` allowlist of facts you've
agreed atlas can share with that specific room. Want your sibling group
to be able to ask "is the user free Saturday?", add "calendar
availability" to that group's consent list. Want your work group to
know you're on a deadline but not your sleep schedule, say so once,
atlas remembers per-group.

You can add atlas to a family chat without worrying about it accidentally
repeating something from a private conversation.

## Why use this instead of Claude.ai directly

Claude.ai's chat, Cowork, and connectors are excellent for ad-hoc
sessions, browser work, and anything starting from a blank slate. The
shape atlas fills is the always-on, local-machine variant. The
differences are concrete:

- **Filesystem access to your actual machine.** atlas reads your
  Messages database, your Voice Memos, your Notes, your code repos,
  your music library metadata, your local kb. None of it has to be
  uploaded.
- **Arbitrary scripts and crons.** atlas runs Python, ffmpeg, whisper,
  yt-dlp, git, anything you can shell-execute. It can write its own
  scripts and run them on a schedule via launchd.
- **No Anthropic API key required.** Channels mode authenticates via
  your claude.ai account, so your Claude Pro or Max subscription covers
  everything. See [Claude Code channels](https://code.claude.com/docs/en/channels).
- **Telegram (or Discord, or iMessage) as the always-on interface.**
  Messages from the platform you already check on your phone arrive
  directly in the running session. You can reach atlas from anywhere
  without opening another app.
- **Self-modifying.** Tell atlas to change its behavior, it edits its
  own files in `~/atlas/`, commits the change, and reloads itself.
  Every behavior shift is version-controlled.

If you'd rather drive a cloud session from your phone, see [Remote
Control](https://code.claude.com/docs/en/remote-control). Different
shape, often complementary.

## What you need before starting

1. A Mac you can leave on. An older one works fine; atlas itself is light.
2. **Claude Code** installed: see [the docs](https://code.claude.com/docs/en/overview). You'll need a **Claude Pro** or **Claude Max** subscription.
3. **tmux** (`brew install tmux`). Used to keep Claude Code running in a detached pane that launchd can supervise.
4. **Bun** installed (`brew install oven-sh/bun/bun`). The channel plugins are Bun scripts.
5. A **Telegram** account and 5 minutes with [@BotFather](https://t.me/BotFather) to create a bot and grab a token.

Optional for the data-source use cases:

- **ffmpeg + whisper.cpp** for local audio transcription (`brew install ffmpeg whisper-cpp`).
- A **GitHub** account if you want atlas to track its own config changes with an audit trail.

## The fastest setup: let Claude Code do it

Open a fresh Claude Code session in your home directory, then:

```bash
git clone https://github.com/george-masto/atlas-template ~/atlas-bootstrap
cd ~/atlas-bootstrap
```

Then tell Claude Code: **"Read README.md and install.sh. Walk me through
setting up atlas on this Mac. Ask me for my Telegram bot token and user
ID when you need them. Don't run launchctl until I've reviewed the
plist."**

Claude Code will:

1. Run `install.sh` interactively, prompting you for your Telegram bot token (from BotFather) and your Telegram user ID (so only you can reach the bot).
2. Substitute your username into the launchd plists.
3. Write your bot config to `~/.claude/channels/telegram/.env` and the access allowlist to `~/.claude/channels/telegram/access.json`.
4. Show you each file before installing the launchd job.
5. Load the agent with `launchctl load -w ~/Library/LaunchAgents/com.<user>.atlas.plist`.
6. Walk you through sending the first `/start` to your bot to confirm round-trip works.

If you'd rather do it by hand, `install.sh` is short enough to read top to bottom. Each step is commented.

## What gets installed

```
~/atlas/
  CLAUDE.md              your operating instructions (auto-loaded by Claude Code)
  SOUL.md                voice and values for the agent
  MEMORY.md              durable scratchpad. survives restarts.
  bin/
    run.sh               tmux + claude wrapper invoked by launchd
    atlas-tell.sh        helper to inject a prompt into atlas's tmux session
    daily-brief.sh       launchd-fired morning brief trigger
  launchd/
    com.<user>.atlas.plist            keeps atlas alive 24/7
    com.<user>.atlas.daily-brief.plist  fires the brief at 3am local
  groups/
    RULES.md             group-chat behavior + confidentiality defaults
  integrations/          empty by default. add your own as you build.
  logs/                  gitignored runtime logs
```

Plus two outside `~/atlas/`:

```
~/Library/LaunchAgents/com.<user>.atlas.plist
~/.claude/channels/telegram/
  .env             # bot token, mode 600
  access.json      # who's allowed to reach atlas
```

## What it is not

- Not a replacement for Claude.ai. The Claude.ai app, Cowork, and the connectors stack are better for one-off questions, browser tasks, and anything that doesn't need filesystem access to your machine. Use both.
- Not a way to share your Claude subscription. atlas acts on your behalf only. The Telegram access allowlist enforces this; senders not on the list are silently dropped.
- Not a backup. Sessions can die. Anything that needs to persist gets written to `MEMORY.md` or to its own file. Don't trust in-session state to survive a restart.
- Not a way to make Claude write code unsupervised. atlas is supervised by default. You can opt specific tasks into autonomous mode after you've watched it make good decisions in that lane.

## One step at a time

Don't try to build all the integrations at once. Get the basic agent
alive, sleep on it for a couple of days, then add the morning brief.
Then the email drafter. Then a single data source you actually care
about. Each layer compounds with the previous, and the agent gets better
the longer it has to learn your taste.

The most useful thing atlas ends up doing is the cross-source question
that only it can answer because only it has your data colocated and
indexed. That payoff is months out, not days. But the setup is short
enough that there's no real reason not to start.

## Links

- [Claude Code overview](https://code.claude.com/docs/en/overview)
- [Claude Code channels](https://code.claude.com/docs/en/channels) (the feature atlas runs on)
- [Telegram channel plugin source](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/telegram)
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) for local audio transcription
- [Karpathy on LLM knowledge bases](https://karpathy.bearblog.dev/llm-knowledge-bases/), a pattern that pairs well with atlas

## License

MIT.
