#!/bin/bash

# Barbie Dreamhouse Server Configuration Setup
# Applies all Owncast configuration from config/server-settings.json via the admin API

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PINK}✨ Barbie Dreamhouse Configuration Setup ✨${NC}"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "Please copy .env.example to .env and configure your credentials"
    exit 1
fi

# Check required variables
if [ -z "$OWNCAST_ADMIN_PASSWORD" ]; then
    echo -e "${RED}❌ Error: OWNCAST_ADMIN_PASSWORD not set in .env${NC}"
    exit 1
fi

# Set defaults
OWNCAST_URL=${OWNCAST_URL:-http://localhost:8080}
OWNCAST_ADMIN_USER=${OWNCAST_ADMIN_USER:-admin}
CONFIG_FILE="config/server-settings.json"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Error: $CONFIG_FILE not found${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Checking Owncast server...${NC}"

# Wait for Owncast to be ready (max 60 seconds)
MAX_ATTEMPTS=60
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s -f "$OWNCAST_URL/api/status" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Owncast server is ready${NC}"
        break
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
        echo -e "${RED}❌ Error: Owncast server not responding after $MAX_ATTEMPTS seconds${NC}"
        echo "Please make sure Owncast is running at $OWNCAST_URL"
        exit 1
    fi
    
    echo -e "${YELLOW}⏳ Waiting for Owncast server... ($ATTEMPT/$MAX_ATTEMPTS)${NC}"
    sleep 1
done

echo ""
echo -e "${BLUE}📄 Reading configuration...${NC}"

# Function to extract JSON value using grep and sed (no jq needed)
get_json_value() {
    local json="$1"
    local key="$2"
    echo "$json" | grep "\"$key\"" | head -1 | sed 's/.*: "\(.*\)".*/\1/' | sed 's/",$//'
}

# Function to extract JSON array
get_json_array() {
    local json="$1"
    local key="$2"
    echo "$json" | sed -n "/\"$key\"/,/\]/p" | grep -v "\"$key\"" | grep -v "\]" | sed 's/.*"\(.*\)".*/\1/' | sed 's/",$//' | sed 's/^[[:space:]]*//'
}

# Function to make API call
api_call() {
    local endpoint="$1"
    local value="$2"
    local description="$3"
    
    echo -e "${BLUE}⚙️  Setting $description...${NC}"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -u "$OWNCAST_ADMIN_USER:$OWNCAST_ADMIN_PASSWORD" \
        -H "Content-Type: application/json" \
        -d "{\"value\":$value}" \
        "$OWNCAST_URL/api/admin/config/$endpoint")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ $description set successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Error setting $description (HTTP $HTTP_CODE)${NC}"
        echo "$BODY"
        return 1
    fi
}

# Function to escape string for JSON
json_escape() {
    local string="$1"
    string="${string//\\/\\\\}"
    string="${string//\"/\\\"}"
    string="${string//$'\n'/\\n}"
    string="${string//$'\r'/\\r}"
    string="${string//$'\t'/\\t}"
    echo "$string"
}

# Read config file
CONFIG=$(cat "$CONFIG_FILE")

echo -e "${GREEN}✓ Configuration loaded${NC}"
echo ""

# Apply each configuration setting
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🎨 Applying Server Configuration${NC}"
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Server Name
SERVER_NAME=$(echo "$CONFIG" | grep '"serverName"' | sed 's/.*: "\(.*\)".*/\1/' | sed 's/",$//')
if [ -n "$SERVER_NAME" ]; then
    SERVER_NAME_ESCAPED=$(json_escape "$SERVER_NAME")
    api_call "name" "\"$SERVER_NAME_ESCAPED\"" "server name"
fi

# Server Summary
SERVER_SUMMARY=$(echo "$CONFIG" | grep '"serverSummary"' | sed 's/.*: "\(.*\)".*/\1/' | sed 's/",$//')
if [ -n "$SERVER_SUMMARY" ]; then
    SERVER_SUMMARY_ESCAPED=$(json_escape "$SERVER_SUMMARY")
    api_call "serversummary" "\"$SERVER_SUMMARY_ESCAPED\"" "server summary"
fi

# Welcome Message
WELCOME_MSG=$(echo "$CONFIG" | grep '"serverWelcomeMessage"' | sed 's/.*: "\(.*\)".*/\1/' | sed 's/",$//')
if [ -n "$WELCOME_MSG" ]; then
    WELCOME_MSG_ESCAPED=$(json_escape "$WELCOME_MSG")
    api_call "welcomemessage" "\"$WELCOME_MSG_ESCAPED\"" "welcome message"
fi

# Stream Title
STREAM_TITLE=$(echo "$CONFIG" | grep '"streamTitle"' | sed 's/.*: "\(.*\)".*/\1/' | sed 's/",$//')
if [ -n "$STREAM_TITLE" ]; then
    STREAM_TITLE_ESCAPED=$(json_escape "$STREAM_TITLE")
    api_call "streamtitle" "\"$STREAM_TITLE_ESCAPED\"" "stream title"
fi

# Offline Message
OFFLINE_MSG=$(echo "$CONFIG" | grep '"offlineMessage"' | sed 's/.*: "\(.*\)".*/\1/' | sed 's/",$//')
if [ -n "$OFFLINE_MSG" ]; then
    OFFLINE_MSG_ESCAPED=$(json_escape "$OFFLINE_MSG")
    api_call "offlinemessage" "\"$OFFLINE_MSG_ESCAPED\"" "offline message"
fi

# Tags (as array)
TAGS=$(echo "$CONFIG" | sed -n '/"tags"/,/\]/p' | grep '"' | sed 's/.*"\(.*\)".*/\1/' | sed 's/,$//' | tr '\n' ',' | sed 's/,$//')
if [ -n "$TAGS" ]; then
    # Convert to JSON array format
    TAG_ARRAY="["
    IFS=',' read -ra TAG_ARR <<< "$TAGS"
    for i in "${!TAG_ARR[@]}"; do
        if [ $i -gt 0 ]; then
            TAG_ARRAY="$TAG_ARRAY,"
        fi
        TAG_ARRAY="$TAG_ARRAY\"${TAG_ARR[$i]}\""
    done
    TAG_ARRAY="$TAG_ARRAY]"
    api_call "tags" "$TAG_ARRAY" "server tags"
fi

# Boolean settings
NSFW=$(echo "$CONFIG" | grep '"nsfw"' | sed 's/.*: \([^,]*\).*/\1/')
if [ -n "$NSFW" ]; then
    api_call "nsfw" "$NSFW" "NSFW flag"
fi

HIDE_VIEWER_COUNT=$(echo "$CONFIG" | grep '"hideViewerCount"' | sed 's/.*: \([^,]*\).*/\1/')
if [ -n "$HIDE_VIEWER_COUNT" ]; then
    api_call "hideviewercount" "$HIDE_VIEWER_COUNT" "viewer count visibility"
fi

CHAT_DISABLED=$(echo "$CONFIG" | grep '"chatDisabled"' | sed 's/.*: \([^,]*\).*/\1/')
if [ -n "$CHAT_DISABLED" ]; then
    api_call "chat/disable" "$CHAT_DISABLED" "chat status"
fi

CHAT_JOIN=$(echo "$CONFIG" | grep '"chatJoinMessagesEnabled"' | sed 's/.*: \([^,]*\).*/\1/')
if [ -n "$CHAT_JOIN" ]; then
    api_call "chat/joinmessagesenabled" "$CHAT_JOIN" "chat join messages"
fi

# Custom Page Content (from markdown file)
PAGE_CONTENT_FILE="config/page-content.md"
if [ -f "$PAGE_CONTENT_FILE" ]; then
    CUSTOM_CONTENT=$(cat "$PAGE_CONTENT_FILE")
    CUSTOM_CONTENT_ESCAPED=$(json_escape "$CUSTOM_CONTENT")
    api_call "pagecontent" "\"$CUSTOM_CONTENT_ESCAPED\"" "custom page content"
fi

echo ""
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Configuration complete! ✨${NC}"
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📺 Your server is now configured:${NC}"
echo -e "   ${OWNCAST_URL}"
echo ""
echo -e "${YELLOW}💡 Tip: To update settings, edit config/server-settings.json and run this script again${NC}"
echo ""
