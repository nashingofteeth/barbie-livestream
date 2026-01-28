# Configuration Reference

## Overview

All server settings are in **`config/server-settings.json`**. Edit this file and run `./setup-config.sh` to apply changes.

## Quick Reference

### File Locations

| What | Where |
|------|-------|
| Server config | `config/server-settings.json` |
| Theme CSS | `theme/custom.css` |
| Theme JS | `theme/custom.js` |
| Admin credentials | `.env` |
| Lobby page | `lobby/index.html` |

### Apply Changes

```bash
# Config changes
nano config/server-settings.json
./scripts/setup-config.sh

# Theme changes
nano theme/custom.css  # or theme/custom.js
./scripts/setup-theme.sh
```

## Configuration Options

### Basic Settings

```json
{
  "serverName": "Barbie Movie Night",
  "serverSummary": "2000s Barbie movie marathons",
  "serverWelcomeMessage": "Welcome to the Dreamhouse!",
  "streamTitle": "Fairytopia Marathon",
  "offlineMessage": "Stream offline, back soon!"
}
```

### Discovery & Tags

```json
{
  "tags": ["barbie", "movies", "2000s", "nostalgia"],
  "nsfw": false,
  "hideViewerCount": false
}
```

### Chat Settings

```json
{
  "chatDisabled": false,
  "chatJoinMessagesEnabled": true,
  "forbiddenUsernames": ["admin", "bot"],
  "suggestedUsernames": ["BarbieGirl", "KenDoll"]
}
```

### Social Links

```json
{
  "socialHandles": [
    {"platform": "discord", "url": "https://discord.gg/your-server"},
    {"platform": "twitter", "url": "https://twitter.com/handle"}
  ]
}
```

Supported platforms: discord, twitter, instagram, facebook, youtube, github, mastodon, tiktok, twitch

### Custom Page Content

Use Markdown with `\n` for line breaks:

```json
{
  "customPageContent": "## Tonight's Feature\n\n**Fairytopia** at 7:30 PM!"
}
```

## Theme Customization

### Change Colors

In `theme/custom.css`:

```css
:root {
  --theme-color-action: #FF69B4;  /* Main pink */
}
```

Pink options:
- `#FF69B4` - Hot Pink
- `#FF1493` - Deep Pink
- `#FFB6C1` - Light Pink
- `#C71585` - Medium Violet Red

### Adjust Sparkles

In `theme/custom.js`:

```javascript
const CONFIG = {
  maxSparkles: 30,      // Max sparkles on screen
  spawnInterval: 300,   // Milliseconds between spawns
};
```

Reduce sparkles: increase `spawnInterval` or lower `maxSparkles`

Disable sparkles: Add `return;` at top of file

## Complete Config Example

See `config/server-settings.json` for full template.

All options:

| Option | Type | Description |
|--------|------|-------------|
| `serverName` | string | Server display name |
| `serverSummary` | string | Short description |
| `serverWelcomeMessage` | string | Chat welcome message |
| `streamTitle` | string | Current stream title |
| `offlineMessage` | string | Message when offline |
| `tags` | array | Discovery tags |
| `nsfw` | boolean | NSFW flag |
| `hideViewerCount` | boolean | Hide viewer count |
| `chatDisabled` | boolean | Disable chat |
| `chatJoinMessagesEnabled` | boolean | Show join messages |
| `forbiddenUsernames` | array | Blocked usernames |
| `suggestedUsernames` | array | Auto-assigned names |
| `socialHandles` | array | Social media links |
| `customPageContent` | string | Markdown content |

## Common Tasks

### Update Stream Title

```json
{"streamTitle": "New Movie Title"}
```
```bash
./scripts/setup-config.sh
```

### Add Social Link

```json
{
  "socialHandles": [
    {"platform": "discord", "url": "https://discord.gg/xyz"}
  ]
}
```
```bash
./scripts/setup-config.sh
```

### Change Pink Shade

```css
/* theme/custom.css */
:root {
  --theme-color-action: #FF1493;  /* Darker pink */
}
```
```bash
./scripts/setup-theme.sh
```

## Troubleshooting

**Config not applying:**
- Check JSON syntax: `python3 -m json.tool < config/server-settings.json`
- Verify password in `.env` matches Owncast
- Hard refresh browser: Cmd+Shift+R

**Invalid JSON errors:**
- No trailing commas: `["tag1", "tag2",]` ❌
- Escape quotes in strings: `"Barbie's Stream"` ❌ → `"Barbie\\'s Stream"` ✓

## URLs

| What | URL |
|------|-----|
| Stream | http://localhost:8080 |
| Admin | http://localhost:8080/admin |
| OBS Server | rtmp://localhost:1935/live |
