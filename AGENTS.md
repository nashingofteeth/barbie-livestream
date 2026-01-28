# Agent Guidelines for Barbie Dreamhouse Livestream

## Project Overview

Barbie-themed Owncast livestream server with configuration-as-code. Bash scripts automate setup by reading JSON/CSS/JS files and POSTing to Owncast admin API. No build system - this is a configuration management project, not a traditional app.

## Technology Stack

- **Bash**: All automation scripts
- **JavaScript**: Client-side theme effects (vanilla JS, no frameworks)
- **CSS**: Theme styling
- **JSON**: Configuration storage
- **Docker**: Container orchestration
- **Owncast**: Go-based streaming server (external dependency)

## Testing & Running

### No Traditional Build/Test System

This project has no `npm`, `make`, or test runners. Testing is manual.

### Testing Scripts

```bash
# Test full setup (requires Docker running)
./start.sh

# Test config application (requires Owncast running)
./scripts/setup-config.sh

# Test theme application (requires Owncast running)
./scripts/setup-theme.sh

# Upload logo (requires Owncast running)
./scripts/setup-logo.sh theme/logo.png

# Validate JSON syntax
python3 -m json.tool < config/server-settings.json

# Check bash syntax (no execution)
bash -n scripts/setup-config.sh
bash -n scripts/setup-theme.sh
bash -n scripts/setup-logo.sh
bash -n start.sh
```

### Running Owncast Locally

```bash
# Start Owncast in Docker
docker-compose up -d

# View logs
docker-compose logs -f

# Stop server
docker-compose stop

# Reset everything
docker-compose down -v
```

### Quick Validation Workflow

```bash
# 1. Validate JSON
python3 -m json.tool < config/server-settings.json > /dev/null && echo "✓ JSON valid"

# 2. Check bash syntax
bash -n scripts/*.sh start.sh && echo "✓ Bash scripts valid"

# 3. Test full flow (requires Docker)
./start.sh
```

## Code Style Guidelines

### Bash Scripts

**Structure:**
- Shebang: `#!/bin/bash`
- Strict mode: `set -e` (exit on error)
- Functions before main logic
- Main execution at bottom

**Variables:**
- UPPERCASE for constants/env vars: `OWNCAST_URL`, `CONFIG_FILE`
- lowercase for local vars: `api_call()`, `json_escape()`
- Use descriptive names: `SERVER_NAME` not `SN`

**Formatting:**
- 4-space indentation (not tabs)
- Space before `{` in functions: `function_name() {`
- Quote variables: `"$VAR"` not `$VAR`
- Use `$()` not backticks: `$(command)` not `` `command` ``

**Error Handling:**
```bash
# Check required files
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Error: $CONFIG_FILE not found${NC}"
    exit 1
fi

# Check HTTP responses
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Success${NC}"
else
    echo -e "${RED}❌ Error (HTTP $HTTP_CODE)${NC}"
    return 1
fi
```

**Color Output:**
- Use ANSI color codes defined at top: `RED`, `GREEN`, `YELLOW`, `BLUE`, `PINK`, `NC`
- Format: `echo -e "${COLOR}message${NC}"`
- Always reset with `${NC}` (No Color)

**Comments:**
- Use `#` for single-line comments
- Add function docstrings for complex functions
- Comment non-obvious regex/sed operations

### JavaScript (theme/custom.js)

**Style:**
- ES6+ features allowed (const, let, arrow functions, template literals)
- Strict mode: `'use strict';`
- IIFE wrapper: `(function() { ... })();`
- Configuration objects at top
- Pure functions where possible

**Naming:**
- PascalCase for objects/constructors: `SparkleManager`
- camelCase for functions/variables: `createSparkle()`, `maxSparkles`
- UPPER_SNAKE_CASE for true constants: `CONFIG`

**DOM Manipulation:**
- Vanilla JS only (no jQuery)
- Use modern APIs: `querySelector`, `addEventListener`
- Check existence before manipulating: `if (element) { ... }`
- Clean up resources: remove event listeners, clear intervals

**Comments:**
- JSDoc-style for public functions
- Inline comments for complex logic
- Section headers with `/** SECTION NAME */`

### CSS (theme/custom.css)

**Structure:**
- CSS variables in `:root` at top
- Group related styles together
- Mobile-first approach (desktop overrides in media queries)

**Naming:**
- BEM-style: `.block__element--modifier`
- CSS variables: `--theme-color-action`, `--font-display`
- Lowercase with hyphens

**Formatting:**
- One selector per line for multi-selector rules
- Space after `:` in declarations
- Alphabetize properties (loosely)
- 2-space indentation

### JSON Configuration

**Format:**
- 2-space indentation
- Double quotes for strings
- No trailing commas
- Escape special characters: `\"`, `\n`, `\\`

**Validation:**
- Must pass `python3 -m json.tool` or `jq .`
- Required fields: `serverName`, `serverSummary`, `tags`

## File Organization

**Scripts:** All automation in `scripts/` directory
- `scripts/setup-config.sh` - Apply server config
- `scripts/setup-theme.sh` - Apply CSS/JS theme
- `scripts/setup-logo.sh` - Upload logo image
- `start.sh` - Main entry point (kept in root)

**Config:** All configuration in version control
- `config/server-settings.json` - Server settings (includes notifications)
- `config/page-content.md` - Custom page content (markdown)
- `theme/custom.css` - Theme styles
- `theme/custom.js` - Client-side effects
- `theme/logo.png` - Server logo (optional, auto-uploaded on start)
- `.env` - Credentials (NOT in git, use `.env.example` template)

**Frontend:**
- `lobby/index.html` - Landing page with sparkles, links to stream

**Data (Persisted):**
- `data/` - Owncast data volume (database, recordings, etc.)
- `data/emoji/` - Custom emoji images for chat
- `data/public/images/` - User-uploaded assets (logo, backgrounds)

**Documentation:**
- `README.md` - User guide with setup, config, troubleshooting
- `AGENTS.md` - This file (agent guidelines)

## Common Patterns

### JSON Parsing Without jq

```bash
# Extract string value
SERVER_NAME=$(echo "$CONFIG" | grep '"serverName"' | sed 's/.*: "\(.*\)".*/\1/' | sed 's/",$//')

# Extract boolean
NSFW=$(echo "$CONFIG" | grep '"nsfw"' | sed 's/.*: \(.*\),*/\1/')

# Extract array (complex)
TAGS=$(echo "$CONFIG" | sed -n '/"tags"/,/\]/p' | grep '"' | sed 's/.*"\(.*\)".*/\1/')
```

### JSON Escaping Function

```bash
json_escape() {
    local string="$1"
    string="${string//\\/\\\\}"      # Backslashes first!
    string="${string//\"/\\\"}"      # Quotes
    string="${string//$'\n'/\\n}"    # Newlines
    string="${string//$'\r'/\\r}"    # Carriage returns
    string="${string//$'\t'/\\t}"    # Tabs
    echo "$string"
}
```

### API Call Pattern

```bash
curl -s -w "\n%{http_code}" -X POST \
    -u "$OWNCAST_ADMIN_USER:$OWNCAST_ADMIN_PASSWORD" \
    -H "Content-Type: application/json" \
    -d "{\"value\":$value}" \
    "$OWNCAST_URL/api/admin/config/$endpoint"
```

## Owncast API Reference

**Base URL:** `http://localhost:8080/api/admin/config/`

**Authentication:** HTTP Basic Auth (username: `admin`, password from `.env`)

**Common Endpoints** (all lowercase, all POST):
- `name` - Server name (string)
- `serversummary` - Server summary/description (string)
- `welcomemessage` - Chat welcome message (string)
- `streamtitle` - Current stream title (string)
- `offlinemessage` - Message shown when offline (string)
- `pagecontent` - Custom markdown page content (string)
- `logo` - Server logo (base64 data URI string)
- `tags` - Server tags (array of strings)
- `socialhandles` - Social media links (array of objects)
- `externalactions` - Custom action buttons (array of objects)
- `nsfw` - NSFW flag (boolean)
- `hideviewercount` - Hide viewer count (boolean)
- `chat/disable` - Disable chat (boolean)
- `chat/joinmessagesenabled` - Show join messages (boolean)
- `chat/forbiddenusernames` - Set forbidden usernames (array)
- `chat/suggestedusernames` - Set suggested usernames (array)
- `chat/establishedusermode` - Established user mode (boolean)
- `chat/spamprotectionenabled` - Spam protection (boolean)
- `chat/slurfilterenabled` - Slur filter (boolean)

**Request Format:**
```json
{
  "value": "string or boolean or array"
}
```

**Full API Documentation:** https://owncast.online/api/latest

**IMPORTANT:** All endpoint names are lowercase. Common mistakes:
- ❌ `summary` → ✅ `serversummary`
- ❌ `serverWelcomeMessage` → ✅ `welcomemessage`
- ❌ `pageContent` → ✅ `pagecontent`
- ❌ `customofflinemessage` → ✅ `offlinemessage`
- ❌ `chatdisabled` → ✅ `chat/disable`
- ❌ `chatjoinmessagesenabled` → ✅ `chat/joinmessagesenabled`

**Note:** Chat-related endpoints use a `/chat/` subpath structure.

## API Behavior Notes

**Logo Upload:**
- Send as base64 data URI: `data:image/png;base64,<encoded-data>`
- Owncast decodes and saves to `data/logo.png`
- Served publicly at `/logo`
- Config stores just filename: `"logo.png"`

**Empty Arrays:**
- Always send empty arrays as `[]`, not omit the field
- API may return `null` for empty arrays (functionally equivalent)
- Empty arrays clear existing values (tags, socialHandles, externalActions)

**Boolean Parsing:**
- Extract with: `sed 's/.*: \([^,]*\).*/\1/'` (captures until comma)
- NOT: `sed 's/.*: \(.*\),*/\1/'` (includes trailing comma)

**Array Parsing Pitfall:**
- DON'T use: `sed -n '/"field"/,/\]/p'` (matches ANY `]`)
- DO check for empty: `grep '"field"' | grep -q '\[\]'`
- For populated arrays, use targeted extraction within bounds

**Page Content:**
- Read from `config/page-content.md` (not JSON)
- Send full markdown content as string
- Owncast converts markdown → HTML automatically

## Git Workflow

**Never commit:**
- `.env` (credentials)
- `data/` directory (Owncast runtime data)

**Always commit:**
- Config files (`config/`, `theme/`)
- Scripts
- Documentation (only when user explicitly requests updates)

**Commit messages:**
- Present tense: "Add feature" not "Added feature"
- Imperative: "Fix bug" not "Fixes bug"
- Descriptive: "Update theme colors for better contrast" not "Update CSS"

## Documentation Policy

**IMPORTANT:** DO NOT create, update, or modify documentation files unless the user explicitly requests it.

This includes:
- `README.md`
- Files in `docs/human/`
- Files in `docs/llm/`
- This `AGENTS.md` file

When making code changes, focus on the code itself. Documentation updates require explicit user approval.

## Common Tasks for Agents

**Adding new config option:**
1. Add field to `config/server-settings.json`
2. Add parsing logic to `scripts/setup-config.sh`
3. Add API call with appropriate endpoint
4. DO NOT update docs unless explicitly requested by user

**Modifying theme:**
1. Edit `theme/custom.css` or `theme/custom.js`
2. Test with `./scripts/setup-theme.sh`
3. Verify in browser (hard refresh: Cmd+Shift+R)
4. DO NOT update docs unless explicitly requested by user

**Debugging:**
1. Check Docker: `docker ps`
2. Check logs: `docker-compose logs -f`
3. Validate JSON: `python3 -m json.tool < config/server-settings.json`
4. Check bash syntax: `bash -n scripts/setup-config.sh`
5. Test API manually: `curl -u admin:password http://localhost:8080/api/status`

## Architecture Notes

- **Stateless scripts**: Idempotent operations, can run multiple times
- **No external dependencies**: Pure bash (no jq, no node, no python runtime)
- **Wait-for-ready pattern**: Scripts poll Owncast API before configuration
- **Error propagation**: Use `set -e` and explicit error checking
- **Configuration-as-code**: Files are source of truth, not database

## System Architecture

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

## Environment & Ports

**Environment Variables** (defined in `.env`):
- `OWNCAST_ADMIN_USER` - Admin username (default: "admin")
- `OWNCAST_ADMIN_PASSWORD` - Admin password (must match Owncast)
- `OWNCAST_URL` - Base URL (default: "http://localhost:8080")

**Port Configuration:**
- **8080**: Owncast web UI, admin panel, API
- **1935**: RTMP ingest for OBS streaming

## Dependencies

**Required:**
- Docker & Docker Compose
- bash, curl, grep, sed (standard on most systems)

**NOT Required:**
- jq (removed - using pure bash)
- python (only for JSON validation)
- node.js

## Script Implementation Details

### start.sh

**Purpose:** Main entry point

**Flow:**
1. Check if Docker is running
2. Start Owncast container via `docker-compose up -d`
3. Wait for API to respond (60s timeout)
4. Call `setup-config.sh`
5. Call `setup-theme.sh`
6. Display success message with URLs

**Wait Logic:**
```bash
for i in {1..60}; do
    if curl -s "$OWNCAST_URL/api/status" > /dev/null; then
        break
    fi
    sleep 1
done
```

### setup-config.sh

**Purpose:** Apply server configuration

**Flow:**
1. Check prerequisites (.env, config file exists)
2. Source environment variables
3. Parse each field from JSON
4. POST each field to appropriate API endpoint
5. Report success/failure for each field

**Error Handling:**
- Validates HTTP response codes
- Continues on individual field failure
- Reports which fields succeeded/failed

### setup-theme.sh

**Purpose:** Apply CSS/JS theme

**Flow:**
1. Read `theme/custom.css` into variable
2. Read `theme/custom.js` into variable
3. JSON-escape both using `json_escape()`
4. POST CSS to `/api/admin/config/customstyles`
5. POST JS to `/api/admin/config/customjavascript`

**Escaping is critical:** Unescaped quotes or newlines break the JSON payload.

### setup-logo.sh

**Purpose:** Upload logo image

**Implementation:** Base64-encodes image and POSTs as data URI to `/api/admin/config/logo`

## Configuration File Format

### config/server-settings.json

```json
{
  "serverName": "string",
  "serverSummary": "string",
  "serverWelcomeMessage": "string",
  "streamTitle": "string",
  "offlineMessage": "string",
  "tags": ["string"],
  "nsfw": false,
  "hideViewerCount": false,
  "disableSearchIndexing": false,
  "chatDisabled": false,
  "chatJoinMessagesEnabled": true,
  "chatEstablishedUsersOnlyMode": false,
  "forbiddenUsernames": ["string"],
  "suggestedUsernames": ["string"],
  "notifications": {
    "browser": {
      "enabled": false,
      "goLiveMessage": ""
    }
  },
  "socialHandles": [
    {
      "platform": "discord|twitter|instagram|...",
      "url": "https://..."
    }
  ],
  "externalActions": [
    {
      "url": "https://...",
      "title": "string",
      "description": "string",
      "icon": "https://...",
      "color": "#hex",
      "openExternally": true
    }
  ],
  "customPageContent": "markdown string\n\nwith newlines"
}
```

### Special Characters Handling

**Newlines in JSON:** Must be `\n` literal in JSON file
```json
{
  "customPageContent": "Line 1\n\nLine 2"
}
```

**Quotes in JSON:** Must be escaped with `\"`
```json
{
  "serverName": "Barbie's \"Dreamhouse\" Stream"
}
```

## Error Handling

### Network Errors
- Owncast not running (connection refused)
- API timeout (no response after 60s)
- HTTP errors (401, 404, 500, etc.)

### Configuration Errors
- Invalid JSON detected during parsing (fails fast)
- Missing required fields (skipped with warning)
- Invalid values (API rejects, script continues)

### Authentication Errors
- HTTP 401: Password mismatch between .env and Owncast
- Solution: Update password in admin panel OR in .env

## Limitations

### What CAN Be Configured via Files
- Server metadata (name, description, etc.)
- Stream settings (title, tags)
- Chat settings
- Social links
- Browser notifications
- Custom CSS/JS
- Page content

### What CANNOT Be Configured via Files
- **Logo upload** - Requires multipart/form-data (handled by setup-logo.sh)
- **Emoji upload** - Requires multipart/form-data (manual via admin panel)
- **Video codec settings** - Different API endpoints
- **Stream keys** - Security concern, managed via admin panel
- **User bans/mods** - Runtime-only data

## Performance

**Configuration Apply Time:** ~2-3 seconds (10-15 API calls)
**Theme Apply Time:** ~1 second (2 API calls)
**Startup Time:** ~15-25 seconds total from `./start.sh` to ready
  - Docker startup: ~5-10 seconds
  - Owncast ready: ~5-10 seconds
  - Config apply: ~3 seconds
  - Theme apply: ~1 second
