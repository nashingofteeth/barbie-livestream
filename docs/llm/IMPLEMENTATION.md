# Technical Implementation Details

## Configuration-as-Code System

### Overview

Owncast stores all configuration in a SQLite database. This project wraps the Owncast admin API with bash scripts that read JSON/CSS/JS files and POST them via HTTP.

**Benefits:**
- All config in version control
- Reproducible deployments
- No manual admin panel clicks
- Infrastructure-as-code approach

### Architecture

```
                   ┌─────────────────────────┐
                   │  config/                │
                   │  server-settings.json   │
                   └───────────┬─────────────┘
                               │
                               │ read by
                               ↓
                   ┌─────────────────────────┐
                   │  scripts/               │
                   │  setup-config.sh        │
                   │  - Parse JSON (bash)    │
                   │  - Extract values       │
                   │  - Build API calls      │
                   └───────────┬─────────────┘
                               │
                               │ HTTP POST
                               ↓
                   ┌─────────────────────────┐
                   │  Owncast Admin API      │
                   │  localhost:8080/api     │
                   │  HTTP Basic Auth        │
                   └───────────┬─────────────┘
                               │
                               │ write to
                               ↓
                   ┌─────────────────────────┐
                   │  Owncast Database       │
                   │  (SQLite in data/)      │
                   └─────────────────────────┘
```

## JSON Parsing Without jq

### Implementation

The `json_escape()` function handles JSON special characters:

```bash
json_escape() {
    local string="$1"
    string="${string//\\/\\\\}"      # Backslashes first
    string="${string//\"/\\\"}"      # Double quotes
    string="${string//$'\n'/\\n}"    # Newlines
    string="${string//$'\r'/\\r}"    # Carriage returns
    string="${string//$'\t'/\\t}"    # Tabs
    echo "$string"
}
```

### Value Extraction

Simple properties extracted with grep + sed:

```bash
# Extract string value
SERVER_NAME=$(grep '"serverName"' "$CONFIG_FILE" | sed 's/.*"serverName": *"\(.*\)".*/\1/')

# Extract array
TAGS=$(grep '"tags"' "$CONFIG_FILE" | sed 's/.*"tags": *\[\(.*\)\].*/\1/')

# Extract boolean
NSFW=$(grep '"nsfw"' "$CONFIG_FILE" | sed 's/.*"nsfw": *\(true\|false\).*/\1/')
```

### Limitations

- No nested object parsing (arrays of objects extracted as-is)
- Assumes well-formed JSON (no validation)
- Single-line extraction only (multi-line strings need special handling)

**Why it works:** Owncast config is simple, flat structure. Complex nesting handled by extracting entire array/object as string.

## API Endpoints Reference

All endpoints use HTTP Basic Auth. Base URL: `http://localhost:8080/api/admin/config`

### Server Information

| Endpoint | Payload | Example |
|----------|---------|---------|
| `/name` | `{"value":"string"}` | Server name |
| `/summary` | `{"value":"string"}` | Short description |
| `/serverWelcomeMessage` | `{"value":"string"}` | Chat welcome message |
| `/streamtitle` | `{"value":"string"}` | Current stream title |
| `/offlineMessage` | `{"value":"string"}` | Offline message |

### Discovery

| Endpoint | Payload | Type |
|----------|---------|------|
| `/tags` | `{"value":["tag1","tag2"]}` | Array |
| `/nsfw` | `{"value":true/false}` | Boolean |
| `/hideViewerCount` | `{"value":true/false}` | Boolean |

### Chat

| Endpoint | Payload | Type |
|----------|---------|------|
| `/chat/disable` | `{"value":true/false}` | Boolean |
| `/chat/joinmessagesenabled` | `{"value":true/false}` | Boolean |
| `/chat/establishedusermode` | `{"value":true/false}` | Boolean |
| `/forbiddenUsernames` | `{"value":["name1"]}` | Array |
| `/suggestedUsernames` | `{"value":["name1"]}` | Array |

### Social & Integrations

| Endpoint | Payload | Type |
|----------|---------|------|
| `/socialhandles` | `{"value":[{"platform":"discord","url":"..."}]}` | Array of objects |
| `/externalactions` | `{"value":[{"url":"...","title":"..."}]}` | Array of objects |

### Content

| Endpoint | Payload | Type |
|----------|---------|------|
| `/pagecontent` | `{"value":"markdown string"}` | String (Markdown) |
| `/customstyles` | `{"value":"css code"}` | String (CSS) |
| `/customjavascript` | `{"value":"js code"}` | String (JS) |

### Authentication

All API calls use HTTP Basic Auth:

```bash
curl -X POST "$OWNCAST_URL/api/admin/config/name" \
    -u "$OWNCAST_ADMIN_USER:$OWNCAST_ADMIN_PASSWORD" \
    -H "Content-Type: application/json" \
    -d '{"value":"New Name"}'
```

Credentials sourced from `.env` file.

## Script Implementation

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

Scripts check for:
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
- Custom CSS/JS
- Page content

### What CANNOT Be Configured via Files

- **Logo upload** - Requires multipart/form-data (binary)
- **Emoji upload** - Requires multipart/form-data (images)
- **Video codec settings** - Different API endpoints
- **Stream keys** - Security concern, managed via admin panel
- **User bans/mods** - Runtime-only data

These require admin panel or different tooling.

## Dependencies Rationale

### Why No jq?

Originally used `jq` for JSON escaping. Removed because:
- Extra dependency to install
- Not available in minimal environments
- Bash string manipulation sufficient for this use case
- Reduces barriers to entry

### Why Bash?

- Available everywhere
- No runtime (Python/Node) needed
- Simple for this task
- Integrates with shell scripts naturally

### Why curl?

- Standard HTTP client
- Supports authentication
- Available in most environments

## Performance Considerations

### Configuration Apply Time

- ~2-3 seconds for full config (10-15 API calls)
- Network bound (localhost is fast)
- Sequential API calls (could parallelize with `&` but unnecessary)

### Theme Apply Time

- ~1 second (2 API calls for CSS + JS)
- CSS/JS size negligible (< 10KB each)

### Startup Time

- Docker startup: ~5-10 seconds (cold start)
- Wait for Owncast ready: ~5-10 seconds
- Config apply: ~3 seconds
- Theme apply: ~1 second
- **Total:** ~15-25 seconds from `./start.sh` to ready

## Testing

### Manual Testing

```bash
# Test config without restarting
./scripts/setup-config.sh

# Test theme without restarting
./scripts/setup-theme.sh

# Verify via admin panel
open http://localhost:8080/admin
```

### JSON Validation

```bash
# Validate JSON syntax
python3 -m json.tool < config/server-settings.json

# Or with jq (if installed)
jq . config/server-settings.json
```

### API Testing

```bash
# Test API directly
curl -u admin:password http://localhost:8080/api/admin/config/name \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"value":"Test"}'
```

## Future Enhancements

### Possible Additions

1. **JSON Schema Validation** - Validate config before applying
2. **Diff Detection** - Only POST changed values
3. **Rollback Support** - Save previous config, restore on failure
4. **Multi-environment** - Support dev/staging/prod configs
5. **Image Upload** - Add logo/emoji via base64 encoding

### Implementation Notes

**Schema validation:** Could use `ajv-cli` or Python `jsonschema`

**Diff detection:** Compare current API state with file (requires GET endpoints)

**Rollback:** Save API responses before changes, restore on error

## Troubleshooting Guide

### Config Not Applying

**Symptoms:** Script runs but changes don't appear

**Diagnosis:**
```bash
# Check Owncast is running
docker ps

# Check API is accessible
curl http://localhost:8080/api/status

# Check credentials
grep PASSWORD .env
```

**Common causes:**
- Wrong password in .env
- Owncast not fully started
- Browser cache (need hard refresh)

### JSON Parse Errors

**Symptoms:** Extracted values are empty or wrong

**Diagnosis:**
```bash
# Validate JSON
python3 -m json.tool < config/server-settings.json

# Check for common mistakes
grep -n trailing comma
grep -n "unescaped quotes"
```

**Common causes:**
- Trailing commas in arrays
- Unescaped quotes in strings
- Missing closing brackets

### API Authentication Failures

**Symptoms:** HTTP 401 errors

**Diagnosis:**
```bash
# Test auth manually
curl -u admin:password http://localhost:8080/api/admin/config/name
```

**Solution:** Password in .env must match Owncast admin password

## Security Considerations

### .env File

- Contains admin password in plaintext
- In `.gitignore` (never commit)
- Should have restricted permissions: `chmod 600 .env`

### API Access

- Only accessible from localhost by default
- For remote access, use SSH tunnel or VPN
- Don't expose admin API to internet

### Stream Keys

- Not managed via config files (security)
- Generate via admin panel
- Keep secret, rotate periodically
