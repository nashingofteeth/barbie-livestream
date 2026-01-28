#!/bin/bash

# Barbie Dreamhouse Logo Setup
# Uploads a logo image to Owncast via the admin API

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PINK}✨ Barbie Dreamhouse Logo Setup ✨${NC}"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}❌ Error: .env file not found${NC}"
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

# Use provided argument or default to theme/logo.png
LOGO_FILE="${1:-theme/logo.png}"

# Check if logo file exists
if [ ! -f "$LOGO_FILE" ]; then
    echo -e "${YELLOW}⚠️  Logo file not found: $LOGO_FILE${NC}"
    echo -e "${YELLOW}Skipping logo setup.${NC}"
    exit 0
fi

echo -e "${BLUE}📁 Logo file: $LOGO_FILE${NC}"

# Detect MIME type
MIME_TYPE=$(file -b --mime-type "$LOGO_FILE")
echo -e "${BLUE}📋 MIME type: $MIME_TYPE${NC}"

# Validate it's an image
if [[ ! "$MIME_TYPE" =~ ^image/ ]]; then
    echo -e "${RED}❌ Error: File is not an image (MIME: $MIME_TYPE)${NC}"
    exit 1
fi

# Convert to base64 data URI
echo -e "${BLUE}🔄 Converting to base64...${NC}"
BASE64_DATA=$(base64 -i "$LOGO_FILE" | tr -d '\n')
DATA_URI="data:${MIME_TYPE};base64,${BASE64_DATA}"

echo -e "${BLUE}📏 Data URI length: ${#DATA_URI} bytes${NC}"

# JSON escape function (for the data URI)
json_escape() {
    local string="$1"
    string="${string//\\/\\\\}"
    string="${string//\"/\\\"}"
    echo "$string"
}

ESCAPED_URI=$(json_escape "$DATA_URI")

echo -e "${BLUE}📤 Uploading logo to Owncast...${NC}"

# Make API call
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -u "$OWNCAST_ADMIN_USER:$OWNCAST_ADMIN_PASSWORD" \
    -H "Content-Type: application/json" \
    -d "{\"value\":\"$ESCAPED_URI\"}" \
    "$OWNCAST_URL/api/admin/config/logo")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Logo uploaded successfully!${NC}"
    echo -e "${BLUE}💡 View your logo at: $OWNCAST_URL${NC}"
else
    echo -e "${RED}❌ Error uploading logo (HTTP $HTTP_CODE)${NC}"
    echo "$BODY"
    exit 1
fi

echo ""
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Logo setup complete! ✨${NC}"
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
