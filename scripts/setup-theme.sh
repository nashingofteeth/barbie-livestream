#!/bin/bash

# Barbie Dreamhouse Theme Setup Script
# Automatically injects custom CSS and JavaScript into Owncast via the admin API

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PINK}✨ Barbie Dreamhouse Theme Setup ✨${NC}"
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

# Set defaults if not specified
OWNCAST_URL=${OWNCAST_URL:-http://localhost:8080}
OWNCAST_ADMIN_USER=${OWNCAST_ADMIN_USER:-admin}

# Theme files
CSS_FILE="theme/custom.css"
JS_FILE="theme/custom.js"

# Check if theme files exist
if [ ! -f "$CSS_FILE" ]; then
    echo -e "${RED}❌ Error: $CSS_FILE not found${NC}"
    exit 1
fi

if [ ! -f "$JS_FILE" ]; then
    echo -e "${RED}❌ Error: $JS_FILE not found${NC}"
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
echo -e "${BLUE}📄 Reading theme files...${NC}"

# Function to escape string for JSON (without jq dependency)
json_escape() {
    local string="$1"
    # Escape backslashes first
    string="${string//\\/\\\\}"
    # Escape double quotes
    string="${string//\"/\\\"}"
    # Escape newlines
    string="${string//$'\n'/\\n}"
    # Escape carriage returns
    string="${string//$'\r'/\\r}"
    # Escape tabs
    string="${string//$'\t'/\\t}"
    echo "$string"
}

# Read CSS file and escape for JSON
CSS_RAW=$(cat "$CSS_FILE")
CSS_ESCAPED=$(json_escape "$CSS_RAW")
echo -e "${GREEN}✓ Loaded $CSS_FILE${NC}"

# Read JS file and escape for JSON
JS_RAW=$(cat "$JS_FILE")
JS_ESCAPED=$(json_escape "$JS_RAW")
echo -e "${GREEN}✓ Loaded $JS_FILE${NC}"

echo ""
echo -e "${BLUE}🎨 Applying custom CSS...${NC}"

# Apply CSS via API
CSS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -u "$OWNCAST_ADMIN_USER:$OWNCAST_ADMIN_PASSWORD" \
    -H "Content-Type: application/json" \
    -d "{\"value\":\"$CSS_ESCAPED\"}" \
    "$OWNCAST_URL/api/admin/config/customstyles")

# Extract HTTP status code (last line)
CSS_HTTP_CODE=$(echo "$CSS_RESPONSE" | tail -n1)
CSS_BODY=$(echo "$CSS_RESPONSE" | sed '$d')

if [ "$CSS_HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Custom CSS applied successfully${NC}"
else
    echo -e "${RED}❌ Error: Failed to apply CSS (HTTP $CSS_HTTP_CODE)${NC}"
    echo "$CSS_BODY"
    exit 1
fi

echo ""
echo -e "${BLUE}✨ Applying custom JavaScript...${NC}"

# Apply JavaScript via API
JS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -u "$OWNCAST_ADMIN_USER:$OWNCAST_ADMIN_PASSWORD" \
    -H "Content-Type: application/json" \
    -d "{\"value\":\"$JS_ESCAPED\"}" \
    "$OWNCAST_URL/api/admin/config/customjavascript")

# Extract HTTP status code (last line)
JS_HTTP_CODE=$(echo "$JS_RESPONSE" | tail -n1)
JS_BODY=$(echo "$JS_RESPONSE" | sed '$d')

if [ "$JS_HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Custom JavaScript applied successfully${NC}"
else
    echo -e "${RED}❌ Error: Failed to apply JavaScript (HTTP $JS_HTTP_CODE)${NC}"
    echo "$JS_BODY"
    exit 1
fi

echo ""
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Theme setup complete! ✨${NC}"
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📺 Open your stream page to see the theme:${NC}"
echo -e "   ${OWNCAST_URL}"
echo ""
echo -e "${YELLOW}💡 Tip: To update the theme, edit files in theme/ and run this script again${NC}"
echo ""
