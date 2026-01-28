# Barbie Dreamhouse Livestream Server

A Barbie-themed Owncast server for hosting 2000s movie watch parties with automated configuration-as-code.

## Features

- Pink Dreamhouse aesthetic with sparkle effects
- Automated setup via configuration files
- Custom Barbie-themed lobby page
- Docker-based deployment
- OBS streaming support

## Quick Start

```bash
./start.sh
```

Access your stream at http://localhost:8080

**First time:**
1. Change admin password at http://localhost:8080/admin (default: `admin`/`abc123`)
2. Update password in `.env` file

## What's Included

- **Barbie theme** - Pink colors, sparkles, custom fonts
- **Configuration system** - All settings in JSON files, applied via API
- **Lobby page** - Landing page with movie info and links
- **Custom emojis** - Barbie-themed chat emojis
- **OBS integration** - Stream movies from OBS Studio

## Project Structure

```
barbie-livestream/
├── start.sh                    # Main entry point
├── scripts/
│   ├── setup-config.sh         # Apply configuration
│   └── setup-theme.sh          # Apply theme
├── config/
│   └── server-settings.json    # All server config
├── theme/
│   ├── custom.css              # Barbie theme CSS
│   └── custom.js               # Sparkle effects
├── lobby/
│   └── index.html              # Landing page
├── data/                       # Owncast data (persisted)
└── docs/                       # Documentation
    ├── human/                  # Setup & config guides
    └── llm/                    # Technical docs for AI assistants
```

## Documentation

**For humans:**
- [Setup Guide](docs/human/SETUP.md) - Installation and streaming setup
- [Configuration Reference](docs/human/CONFIGURATION.md) - Customize settings and theme
- [Emoji Guide](docs/human/EMOJI-GUIDE.md) - Add custom emojis

**For LLMs:**
- [Context](docs/llm/CONTEXT.md) - Project overview and file map
- [Implementation](docs/llm/IMPLEMENTATION.md) - Technical details and API info

## Customization

Edit these files and run the corresponding script:

| File | Purpose | Apply with |
|------|---------|------------|
| `config/server-settings.json` | Server name, tags, chat, etc. | `./scripts/setup-config.sh` |
| `theme/custom.css` | Colors, fonts, layout | `./scripts/setup-theme.sh` |
| `theme/custom.js` | Sparkle effects | `./scripts/setup-theme.sh` |

## Streaming

1. Get stream key from admin panel (Configuration > Stream Keys)
2. Configure OBS Studio:
   - Server: `rtmp://localhost:1935/live`
   - Stream Key: (from step 1)
3. Start streaming in OBS
4. View at http://localhost:8080

## Requirements

- Docker and Docker Compose
- Ports 8080 and 1935 available
- bash, curl (standard on most systems)

## Configuration-as-Code

This project uses file-based configuration instead of manual admin panel setup:

- All settings in `config/server-settings.json`
- Theme in `theme/` directory
- Scripts read files and POST to Owncast API
- Everything version controlled and reproducible

Run `./start.sh` and everything is configured automatically.

## Troubleshooting

See [Setup Guide](docs/human/SETUP.md#troubleshooting) for common issues.

Quick fixes:
```bash
# Restart server
docker-compose restart

# Reapply theme
./scripts/setup-theme.sh

# View logs
docker-compose logs -f
```

## Resources

- [Owncast Documentation](https://owncast.online/docs/)
- [OBS Studio](https://obsproject.com/)
- [Barbie Films on Wikipedia](https://en.wikipedia.org/wiki/List_of_Barbie_films)

## Legal

Fan project for personal use. Barbie trademarks owned by Mattel, Inc. Not affiliated with or endorsed by Mattel. Respect copyright laws when streaming content.

---

Made with sparkles for Barbie movie nights!
