# Setup Guide

## Quick Start

```bash
# One command to start everything
./start.sh
```

This automatically:
- Starts Owncast in Docker
- Applies Barbie theme and configuration
- Shows URLs to access

**Access:**
- Stream: http://localhost:8080
- Admin: http://localhost:8080/admin (default: `admin`/`abc123`)

## First Time Setup

1. **Change admin password**
   - Go to http://localhost:8080/admin
   - Login with: `admin` / `abc123`
   - Navigate: General > Server Config
   - Set new password and save

2. **Update .env file**
   ```bash
   nano .env
   ```
   Change `OWNCAST_ADMIN_PASSWORD` to match your new password

3. **Verify theme applied**
   - Open http://localhost:8080
   - Should see pink colors and sparkles
   - If not, run `./setup-theme.sh`

## Streaming Setup

### Get Stream Key

Admin panel: Configuration > Stream Keys → Copy key

### Configure OBS Studio

Settings > Stream:
- Service: `Custom`
- Server: `rtmp://localhost:1935/live`
- Stream Key: (paste from above)

Add your video source, then click "Start Streaming"

## Adding Custom Emojis

See [EMOJI-GUIDE.md](EMOJI-GUIDE.md) for details.

Quick steps:
1. Prepare 64x64px PNG images
2. Admin panel: General > Chat > Custom Emoji
3. Upload and name each emoji

## Customization

All settings in these files:
- `config/server-settings.json` - server name, tags, chat, etc.
- `theme/custom.css` - colors, fonts
- `theme/custom.js` - sparkle effects

After editing, run:
```bash
./scripts/setup-config.sh    # For config changes
./scripts/setup-theme.sh     # For theme changes
```

See [CONFIGURATION.md](CONFIGURATION.md) for details.

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
- Verify JSON syntax: `python3 -m json.tool < config/server-settings.json`

### Stream not appearing
- Verify OBS is connected
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
```

## Backup

Your data is in `./data/` directory:
```bash
# Backup
tar -czf backup-$(date +%Y%m%d).tar.gz data/

# Restore
tar -xzf backup-YYYYMMDD.tar.gz
```

## Resources

- Owncast docs: https://owncast.online/docs/
- OBS Studio: https://obsproject.com/
- Configuration reference: [CONFIGURATION.md](CONFIGURATION.md)
