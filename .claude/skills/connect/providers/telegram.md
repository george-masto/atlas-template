# Connect: Telegram

Telegram is atlas's front door — the bot the user messages. atlas cannot
run without it. `install.sh` collects this during first install; use this
guide to (re)do it, rotate a token, or set it up by hand.

Destination: `~/.claude/channels/telegram/.env` and `access.json`.

## Steps

1. **Create the bot.** In Telegram, open a chat with **@BotFather**
   (https://t.me/BotFather) and send `/newbot`. Follow the prompts:
   - a display name (anything, e.g. "atlas")
   - a username that must end in `bot` (e.g. `your_atlas_bot`)

   BotFather replies with an **HTTP API token** shaped like
   `123456789:AAH...`. That is the secret.

2. **Save the token.** Write it to `~/.claude/channels/telegram/.env`:
   ```
   TELEGRAM_BOT_TOKEN=<the token>
   ```
   Create the directory first if needed (`mkdir -p`), then `chmod 600` the
   file.

3. **Get the user's numeric ID.** Have the user message **@userinfobot** in
   Telegram. It replies with their user ID — a 9-10 digit number. This is
   who atlas will allow to reach it.

4. **Write the access policy.** Create `~/.claude/channels/telegram/access.json`:
   ```json
   {
     "dmPolicy": "allowlist",
     "allowFrom": ["<the user's numeric id>"],
     "groups": {},
     "pending": {}
   }
   ```
   `chmod 600` it. `allowlist` means only the listed IDs can reach atlas.

5. **(Optional) Group behavior.** Leaving BotFather's default privacy mode
   ON is correct: in groups the bot then only sees messages that @mention
   it or reply to it, which is what atlas's group rules expect.

## Verify

```
curl -s "https://api.telegram.org/bot<TOKEN>/getMe"
```
A JSON response with `"ok":true` and the bot's username means the token is
live. A `401` means the token is wrong — recheck step 2.
