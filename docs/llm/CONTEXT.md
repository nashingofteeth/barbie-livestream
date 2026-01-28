# Project Context for LLMs

## Purpose

Barbie Dreamhouse Livestream Server - A themed Owncast server for hosting 2000s Barbie movie watch parties. Uses Docker to run Owncast with automated configuration-as-code for reproducible deployments.

## Core Architecture

```
User runs ./start.sh
    ↓
1. Starts Owncast in Docker (docker-compose.yml)
    ↓
2. Waits for Owncast API to be ready
    ↓
3. Applies config from config/server-settings.json (setup-config.sh)
    ↓
4. Applies theme from theme/ files (setup-theme.sh)
    ↓
Result: Fully configured Barbie-themed server ready to use
```

### Key Innovation

Instead of manual admin panel configuration, this project uses **configuration-as-code**:
- All settings defined in JSON files (version controlled)
- Bash scripts read files and POST to Owncast admin API
- No `jq` dependency - pure bash JSON parsing
- One command (`./start.sh`) configures everything

## File Map

### Core Scripts

| File | Purpose | Key Functions |
|------|---------|---------------|
| `start.sh` | Main entry point | Starts Docker, calls setup scripts |
| `scripts/setup-config.sh` | Applies server configuration | Reads `config/server-settings.json`, POSTs to API endpoints |
| `scripts/setup-theme.sh` | Applies CSS/JS theme | Reads `theme/*` files, escapes for JSON, POSTs to API |

### Configuration Files

| File | Purpose | Format |
|------|---------|--------|
| `config/server-settings.json` | All Owncast settings | JSON with server name, tags, chat settings, social links, etc. |
| `theme/custom.css` | Barbie theme styles | CSS - pink colors, fonts, layout |
| `theme/custom.js` | Sparkle effects | JavaScript - floating sparkle animations |
| `.env` | Admin credentials | Shell variables for API auth |
| `.env.example` | Template for `.env` | Example credentials |

### Docker Setup

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Defines Owncast container, ports, volumes |

### Frontend

| File | Purpose |
|------|---------|
| `lobby/index.html` | Landing page with sparkles, links to stream |

### Data (Persisted)

| Directory | Purpose |
|-----------|---------|
| `data/` | Owncast data volume (database, recordings, etc.) |
| `data/emoji/` | Custom emoji images for chat |
| `data/public/images/` | User-uploaded assets (logo, backgrounds) |

### Documentation

| File | Audience |
|------|----------|
| `README.md` | Humans - quick intro, links to detailed docs |
| `docs/human/SETUP.md` | Humans - setup guide |
| `docs/human/CONFIGURATION.md` | Humans - config reference |
| `docs/human/EMOJI-GUIDE.md` | Humans - emoji setup |
| `docs/llm/CONTEXT.md` | LLMs - this file |
| `docs/llm/IMPLEMENTATION.md` | LLMs - technical details |

## Component Relationships

### Configuration Flow

```
config/server-settings.json
    ↓ read by
setup-config.sh
    ↓ uses credentials from
.env
    ↓ authenticates to
Owncast Admin API (HTTP Basic Auth)
    ↓ updates
Owncast Database
    ↓ serves to
Users viewing stream
```

### Theme Flow

```
theme/custom.css + theme/custom.js
    ↓ read by
setup-theme.sh
    ↓ JSON-escapes content (json_escape function)
    ↓ uses credentials from
.env
    ↓ POSTs to
Owncast Admin API
    ↓ stores in
Owncast Database
    ↓ injects into pages for
All users
```

## Key Technologies

- **Owncast**: Open-source livestreaming server (Go)
- **Docker**: Containerization for easy deployment
- **Bash**: All automation scripts
- **Owncast Admin API**: HTTP REST API with Basic Auth
- **RTMP**: Streaming protocol for OBS → Owncast

## Key Patterns

### 1. Configuration-as-Code
All settings in version-controlled JSON files, applied via API instead of database manipulation or manual UI clicks.

### 2. Pure Bash JSON Parsing
Instead of requiring `jq`, uses bash string manipulation:
```bash
json_escape() {
    string="${string//\\/\\\\}"     # Escape backslashes
    string="${string//\"/\\\"}"     # Escape quotes
    string="${string//$'\n'/\\n}"   # Escape newlines
    # ...
}
```

### 3. Stateless Automation
Scripts are idempotent - running `./setup-config.sh` multiple times produces same result. No state tracking needed.

### 4. Wait-for-Ready Pattern
`start.sh` polls Owncast API until server responds before attempting configuration.

## API Endpoints Used

All endpoints require HTTP Basic Auth with admin credentials.

| Endpoint | Method | Purpose | Payload |
|----------|--------|---------|---------|
| `/api/admin/config/name` | POST | Set server name | `{"value":"..."}` |
| `/api/admin/config/summary` | POST | Set summary | `{"value":"..."}` |
| `/api/admin/config/streamtitle` | POST | Set stream title | `{"value":"..."}` |
| `/api/admin/config/tags` | POST | Set tags | `{"value":["..."]}` |
| `/api/admin/config/socialhandles` | POST | Set social links | `{"value":[{...}]}` |
| `/api/admin/config/customstyles` | POST | Set custom CSS | `{"value":"..."}` |
| `/api/admin/config/customjavascript` | POST | Set custom JS | `{"value":"..."}` |

See `docs/llm/IMPLEMENTATION.md` for complete list and details.

## Dependencies

### Required
- Docker & Docker Compose
- bash
- curl
- grep
- sed

### NOT Required
- jq (removed - using pure bash)
- python
- node.js

## Environment Variables

Defined in `.env`:
- `OWNCAST_ADMIN_USER` - Admin username (default: "admin")
- `OWNCAST_ADMIN_PASSWORD` - Admin password (must match Owncast)
- `OWNCAST_URL` - Base URL (default: "http://localhost:8080")

## Port Configuration

- **8080**: Owncast web UI, admin panel, API
- **1935**: RTMP ingest for OBS streaming

## Common Modification Points

### Change Server Settings
Edit `config/server-settings.json`, run `./scripts/setup-config.sh`

### Change Theme
Edit `theme/custom.css` or `theme/custom.js`, run `./scripts/setup-theme.sh`

### Change Colors
`theme/custom.css` - Look for CSS variables like `--theme-color-action`

### Adjust Sparkles
`theme/custom.js` - Modify `CONFIG` object (`maxSparkles`, `spawnInterval`)

### Change Ports
`docker-compose.yml` - Modify ports mapping

## Data Persistence

The `./data` directory is mounted as a Docker volume and contains:
- Owncast database (SQLite)
- Stream recordings
- User-uploaded assets
- Configuration changes made via admin panel

**Important**: Config files (`config/*.json`, `theme/*`) are NOT stored in Owncast database. They must be reapplied after container recreation.
