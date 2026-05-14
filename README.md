# atlas

<p align="center">
  <img src="assets/atlas-hero.jpg" alt="atlas: a kneeling figure holds up a sphere woven from messages, calendar events, voice notes, video, and chat threads" width="720">
</p>

An always-on Claude Code agent that runs 24/7 on your Mac, listens via Telegram,
and quietly does the work. No API key. No cloud upload of personal data. No
monthly bill beyond your Claude subscription.

Setup is about 30 minutes. Hand the cloning + install over to Claude Code
itself and it'll walk you through every step.

## The shape of it

Claude.ai is brilliant but request-response. You open the app, ask a thing,
get an answer, close it. The agent has no memory of last week, no awareness
of your inbox or calendar, no ability to act while you sleep, and no view
into the files on your own machine. Every conversation starts blank.

atlas is the alternative. It's a long-lived Claude Code session running under
launchd on your Mac. It stays up around the clock. It listens on a Telegram
channel that only you can reach. It has read and write access to your
filesystem under your control. It can run scripts, query MCPs (calendar,
email, drive, Linear, GitHub), edit its own configuration, and commit those
edits to a git repo. It builds a memory of you over time.

The shift is small but compounds fast. Instead of asking Claude to do a
thing, you build an agent that already knows the shape of your work and
shows up with the right context every morning.

## What this looks like in practice

A handful of scenes drawn from real use:

### You watch a YouTube video and want to talk about it

You text atlas the link or just say "what did you think of that ai-and-art
video Karpathy posted yesterday?" atlas pulls the video from your local
YouTube catalog (synced from your liked videos), reads the auto-fetched
captions, and answers grounded in what was actually said. If no captions
exist it transcribes the audio locally via whisper.cpp before responding.
When you're done it can file the video into the right playlist on your
YouTube account.

### You record a voice note while walking

You hold the mic button in Telegram, talk for 30 seconds, send. atlas
auto-transcribes it locally via whisper.cpp — **no audio leaves your Mac**
— and replies in seconds. Or your iPhone voice memo syncs to your Mac via
iCloud and atlas indexes it the same way. Weeks later you ask "what was
that idea I had about photoacoustic imaging while I was on a walk last
month?" and atlas searches your own spoken thoughts and finds it.

Voice messages work in any language whisper supports — English, Greek,
Spanish, Mandarin, Hindi, dozens of others. atlas auto-detects the
language per recording. You can speak Greek to a voice message about
something technical and atlas will transcribe and answer in whichever
language is appropriate for the conversation.

### You wake up

A cron fires at 7am. atlas pulls today's calendar, your unread email, open
tickets in your task tracker, the weather, watchlist debt, any pending
work, plus events near you that match your interests. You get a single
Telegram message tying it all together. Sections that have nothing get
omitted. Sections that need action are surfaced first.

### An email needs a real reply

atlas reads a sample of your sent email and builds a writing-style profile
(vocabulary signatures, lane registers, hard rules like "never use
em-dashes"). When a human writes you a thread that needs a reply, atlas
composes a draft and saves it to Gmail. It never sends. You open Drafts,
edit, hit send.

### You want to know what you cared about six months ago

atlas queries your voice memos, your notes, your knowledge base, the
articles you saved, the films you logged, the threads you replied to.
It surfaces the throughline.

### You add atlas to a group chat with family or friends

Each group gets its own isolated memory file at
`~/atlas/groups/<chat_id>/MEMORY.md`. **The personal stuff in your DM
memory is loaded but treated as confidential — atlas knows it, but never
volunteers it to the group.** Private memories don't bleed across.

The group's own memory tracks who's in it, the inside jokes, the
ongoing topics, and an explicit `## Consent` allowlist of facts you've
agreed atlas can share with that specific room. Want your sibling group
to be able to ask "is George free Saturday?" — add "calendar
availability" to that group's consent list. Want your work group to
know you're on a deadline but not your sleep schedule — say so once,
atlas remembers per-group.

It deflects personal questions it doesn't have consent for, welcomes
new members, and stays quiet unless tagged. You can add atlas to a
family chat without worrying about it accidentally repeating something
from a private conversation.

### You like a YouTube video at 2am

The next morning, atlas notices the new like, reads the video's title +
description + channel, looks at your existing playlists, and proposes a
playlist to file it under. You reply `yes` or `no` or `<other-playlist>`.
After a stretch of accurate proposals you flip a flag and atlas just
applies its best guess directly, with a digest message after.

None of this requires an API key. atlas uses your existing Claude Pro or
Max subscription through Claude Code, so you pay your usual subscription
and nothing per call.

## What you need before starting

1. A Mac you can leave on. An older one works fine. atlas itself is light.
2. **Claude Code** installed: <https://docs.claude.com/en/docs/claude-code/overview>. You need a **Claude Pro** or **Claude Max** subscription.
3. **tmux**: `brew install tmux`. Used to keep Claude Code running in a detached pane.
4. A **Telegram** account, and 5 minutes with [@BotFather](https://t.me/BotFather) to create a bot and get a token.

Optional for the data-source use cases:

- **ffmpeg + whisper.cpp** for local audio transcription: `brew install ffmpeg whisper-cpp`
- A **GitHub** account if you want atlas to track its own config changes with an audit trail

## The fastest setup: let Claude Code do it

Open a fresh Claude Code session in your home directory, then:

```bash
git clone https://github.com/george-masto/atlas-template ~/atlas-bootstrap
cd ~/atlas-bootstrap
```

Then tell Claude Code: **"Read README.md and install.sh. Walk me through
setting up atlas on this Mac. Ask me for my Telegram bot token and user ID
when you need them. Don't run launchctl until I've reviewed the plist."**

Claude Code will:

1. Run `install.sh` interactively, prompting you for your Telegram bot token
   (from BotFather) and your Telegram user ID (so only you can reach the
   bot).
2. Substitute your username into the launchd plists.
3. Write your bot config to `~/.claude/channels/telegram/.env` and the
   access allowlist to `~/.claude/channels/telegram/access.json`.
4. Show you each file before installing the launchd job.
5. Load the agent with `launchctl load -w ~/Library/LaunchAgents/com.<user>.atlas.plist`.
6. Walk you through sending the first `/start` to your bot to confirm
   round-trip works.

If you'd rather do it by hand, `install.sh` is short and you can read it
top to bottom. Each step has a comment explaining what's happening and why.

## What gets installed

```
~/atlas/
  CLAUDE.md              your operating instructions (auto-loaded by Claude Code)
  SOUL.md                voice and values for the agent
  MEMORY.md              durable scratchpad — survives restarts
  bin/
    run.sh               tmux + claude wrapper invoked by launchd
    atlas-tell.sh        helper to inject a prompt into atlas's tmux session
    daily-brief.sh       launchd-fired morning brief trigger
  launchd/
    com.<user>.atlas.plist           keeps atlas alive 24/7
    com.<user>.atlas.daily-brief.plist  fires the brief at 7:03am local
  groups/
    RULES.md             group-chat behavior + confidentiality defaults
  integrations/          empty by default — add your own as you build
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

- **Not a replacement for Claude.ai.** It complements it. Use the official
  app for one-off questions, browser tasks, or anything that needs the
  latest UI features. Use atlas for the always-on, your-data, scheduled,
  integrated parts.
- **Not a relay for other people.** You don't proxy your Claude
  subscription to friends or family. atlas acts on your behalf only. The
  Telegram access allowlist enforces this.
- **Not a backup.** Sessions can die. Anything you want to persist must be
  written to `MEMORY.md` or to its own file. Don't trust in-session state
  to survive a restart.
- **Not a way to make Claude write code without your review.** atlas is
  supervised by default. It can be flipped to autonomous mode per task
  once you've verified it's making good decisions in that lane.

## One step at a time

Don't try to build all the integrations at once. Get the basic agent alive
first, sleep on it for a couple of days, then add the morning brief. Then
the email drafter. Then a single data source you actually care about. Each
layer compounds with the previous. The longest-running gains come from the
agent learning your taste over weeks of use, not from cramming integrations
in on day one.

The most useful thing the agent ends up doing is the thing you didn't
expect: the cross-source question that only it can answer because only it
has your data colocated and indexed. That payoff is months out, not days.
But the setup is short enough that there's no real reason not to start.

## Links

- [Claude Code docs](https://docs.claude.com/en/docs/claude-code/overview)
- [Telegram channels plugin](https://github.com/anthropics/claude-plugins-official) — official, in the marketplace
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) for local audio transcription
- [Karpathy on LLM knowledge bases](https://karpathy.bearblog.dev/llm-knowledge-bases/) — a pattern that pairs well with atlas

## License

MIT.
