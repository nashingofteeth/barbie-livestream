# Barbie Dreamhouse Livestream Server

A Barbie-themed Owncast server for hosting 2000s movie watch parties with automated configuration-as-code.

## Features

- Pink Dreamhouse aesthetic with sparkle effects
- Automated setup via configuration files
- Custom Barbie-themed lobby page with sparkles and links
- Docker-based deployment
- OBS streaming integration

## Quick Start

```bash
./start.sh
```

Access your stream at http://localhost:8080

**First time setup:**
1. Change admin password at http://localhost:8080/admin (default: `admin`/`abc123`)
2. Update password in `.env` file to match

## Requirements

- Docker and Docker Compose
- Ports 8080 and 1935 available
- bash, curl (standard on most systems)

## Project Structure

```
barbie-livestream/
├── start.sh                    # Main entry point
├── scripts/
│   ├── setup-config.sh         # Apply server configuration
│   ├── setup-theme.sh          # Apply CSS/JS theme
│   └── setup-logo.sh           # Upload logo image
├── config/
│   ├── server-settings.json    # All server settings
│   └── page-content.md         # Custom page content (markdown)
├── theme/
│   ├── custom.css              # Barbie theme CSS
│   ├── custom.js               # Sparkle effects
│   └── logo.png                # Server logo
├── lobby/
│   └── index.html              # Landing page
└── data/                       # Owncast data (persisted)
```

## Configuration

### Quick Reference

| File | Purpose | Apply with |
|------|---------|------------|
| `config/server-settings.json` | Server name, tags, chat, social links, notifications | `./scripts/setup-config.sh` |
| `theme/custom.css` | Colors, fonts, layout | `./scripts/setup-theme.sh` |
| `theme/custom.js` | Sparkle effects | `./scripts/setup-theme.sh` |
| `config/page-content.md` | Custom markdown page content | `./scripts/setup-config.sh` |

### Basic Settings

Edit `config/server-settings.json`:

```json
{
  "serverName": "Barbie Movie Night",
  "serverSummary": "2000s Barbie movie marathons",
  "serverWelcomeMessage": "Welcome to the Dreamhouse!",
  "streamTitle": "Fairytopia Marathon",
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
  "chatEstablishedUsersOnlyMode": false,
  "forbiddenUsernames": ["admin", "bot"],
  "suggestedUsernames": ["BarbieGirl", "KenDoll"]
}
```

### Browser Notifications

Configure in `config/server-settings.json`:

```json
{
  "notifications": {
    "browser": {
      "enabled": false,
      "goLiveMessage": ""
    }
  }
}
```

Set `enabled: true` to show browser notification button when stream goes live.

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

### Theme Customization

**Change colors** in `theme/custom.css`:

```css
:root {
  --theme-color-action: #FF69B4;  /* Main pink */
}
```

Pink options: `#FF69B4` (Hot Pink), `#FF1493` (Deep Pink), `#FFB6C1` (Light Pink), `#C71585` (Medium Violet Red)

**Adjust sparkles** in `theme/custom.js`:

```javascript
const CONFIG = {
  maxSparkles: 30,      // Max sparkles on screen
  spawnInterval: 300,   // Milliseconds between spawns
};
```

Reduce sparkles: increase `spawnInterval` or lower `maxSparkles`. To disable: add `return;` at top of file.

## Streaming Setup

### Get Stream Key

Admin panel: Configuration > Stream Keys → Copy key

### Configure OBS Studio

Settings > Stream:
- Service: `Custom`
- Server: `rtmp://localhost:1935/live`
- Stream Key: (paste from above)

Add your video source, then click "Start Streaming"

## Custom Emojis

### Required Specifications

- **Format**: PNG with transparency
- **Size**: 64x64px recommended (32-128px supported)
- **File size**: Under 100KB each
- **Colors**: Use Barbie theme (#FF69B4, #FFD700, #FFB6C1)

### Adding Emojis

1. Prepare 64x64px PNG images
2. Admin panel: General > Chat > Custom Emoji
3. Upload and name each emoji (e.g., "sparkle", "heart", "crown")
4. Users type `:sparkle:` to use

### Free Resources

- **Flaticon** (flaticon.com) - Search for "crown", "sparkle", "heart"
- **Icons8** (icons8.com) - Pink-themed icons
- **Noun Project** (thenounproject.com) - Simple icons

## Sharing Your Stream

**Local network (same WiFi):**
```bash
# Find your IP
ifconfig | grep "inet "

# Share: http://YOUR_IP:8080
```

**Internet hosting:**
- Requires port forwarding or hosting provider
- See https://owncast.online/docs/sslproxies/

## Troubleshooting

### Server won't start
```bash
docker-compose logs    # Check error messages
docker-compose restart # Restart container
```

### Theme not applying
```bash
./scripts/setup-theme.sh       # Reapply theme
# Then hard refresh browser: Cmd+Shift+R
```

### Config not applying
- Check password in `.env` matches Owncast
- Validate JSON: `python3 -m json.tool < config/server-settings.json`
- Check for trailing commas or unescaped quotes

### Stream not appearing
- Verify OBS is connected and streaming
- Check stream key matches
- Check logs: `docker-compose logs -f`

## Useful Commands

```bash
# View logs
docker-compose logs -f

# Stop server
docker-compose stop

# Restart server
docker-compose restart

# Remove everything (keeps data/)
docker-compose down

# Reset everything (deletes data/)
docker-compose down -v
```

## Backup

Your data is in `./data/` directory:
```bash
# Backup
tar -czf backup-$(date +%Y%m%d).tar.gz data/

# Restore
tar -xzf backup-YYYYMMDD.tar.gz
```

## Configuration-as-Code Philosophy

This project uses **configuration-as-code**: all settings are defined in version-controlled files rather than configured through the admin panel.

**Benefits:**
- **Reproducible**: Same config every time you deploy
- **Version controlled**: Track changes, rollback if needed
- **Portable**: Easy to share or migrate to new servers
- **Automated**: One command applies everything

Run `./start.sh` and everything is configured automatically. Changes made in the admin panel will be overwritten when scripts run.

## Resources

- [Owncast Documentation](https://owncast.online/docs/)
- [Owncast API Documentation](https://owncast.online/api/latest)
- [OBS Studio](https://obsproject.com/)
- [Barbie Films on Wikipedia](https://en.wikipedia.org/wiki/List_of_Barbie_films)

## Legal

Fan project for personal use. Barbie trademarks owned by Mattel, Inc. Not affiliated with or endorsed by Mattel. Respect copyright laws when streaming content.

---

Made with sparkles for Barbie movie nights!
