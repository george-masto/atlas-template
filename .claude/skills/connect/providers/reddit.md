# Connect: Reddit

For read-only research integrations. Reddit has **two layers**: creating app
credentials (quick), and being granted Data API access (gated).

## Step 1 — create the app

1. Go to **reddit.com/prefs/apps** (logged in) and click
   **"create another app..."** (or "are you a developer? create an app").
2. Fill it in:
   - **name**: anything, e.g. `atlas`
   - **type**: choose **script** — the right type for a personal,
     single-user tool.
   - **redirect uri**: `http://localhost:8080` — required even for script
     apps; the client-credentials flow does not really use it.
3. Create it. The app now shows:
   - a **client ID** — the short string just under the app's name
   - a **client secret** — the longer `secret` field

4. Save both to `~/.claude/channels/reddit/client.json`:
   ```json
   {
     "client_id": "<id>",
     "client_secret": "<secret>",
     "user_agent": "atlas:personal:v1 (by /u/<username>)"
   }
   ```
   `chmod 600` it. Reddit expects a descriptive `user_agent` on every call.

## Step 2 — Data API access (the gated part)

Creating the app is not always enough. Reddit gates real Data API usage
behind an **API-access request form** and its Responsible Builder Policy.
The user may need to submit that form and wait — approval can take days.

If the request is **denied** (often a boilerplate "not in compliance with
the Responsible Builder Policy and/or lacks necessary details"), the move is
to reply to the support ticket with a fuller, specific justification:
personal and non-commercial, single user, read-only, public content only,
low volume, data kept local, nothing resold or used to train a model.
Complete and specific requests are the ones that get approved.

## Verify

Request an app-only (client-credentials) token:
```
curl -s -A "atlas:personal:v1" \
  --data-urlencode grant_type=client_credentials \
  -u "<client_id>:<client_secret>" \
  https://www.reddit.com/api/v1/access_token
```
A JSON response with an `access_token` means the credentials work. A `401`
means the ID or secret is wrong. A token that authenticates but then `403`s
on data endpoints means Step 2 (access approval) is still pending.
