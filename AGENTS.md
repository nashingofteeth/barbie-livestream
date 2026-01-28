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

# Validate JSON syntax
python3 -m json.tool < config/server-settings.json

# Check bash syntax (no execution)
bash -n scripts/setup-config.sh
bash -n scripts/setup-theme.sh
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
- `start.sh` - Main entry point (kept in root)

**Config:** All configuration in version control
- `config/server-settings.json` - Server settings
- `theme/custom.css` - Theme styles
- `theme/custom.js` - Client-side effects
- `.env` - Credentials (NOT in git, use `.env.example` template)

**Documentation:**
- `docs/human/` - User-facing guides
- `docs/llm/` - Technical docs for AI assistants
- `README.md` - Project intro (brief)

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
- `name` - Server name
- `serversummary` - Server summary/description
- `welcomemessage` - Chat welcome message
- `streamtitle` - Current stream title
- `offlinemessage` - Message shown when offline
- `pagecontent` - Custom markdown page content
- `tags` - Server tags (array)
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
