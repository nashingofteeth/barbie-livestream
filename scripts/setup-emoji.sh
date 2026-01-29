#!/bin/bash

# Barbie Dreamhouse Emoji Setup
# Uploads custom emoji images to Owncast via the admin API

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PINK}✨ Barbie Dreamhouse Emoji Setup ✨${NC}"
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
OWNCAST_URL=${OWNCAST_URL:-http://localhost:2001}
OWNCAST_ADMIN_USER=${OWNCAST_ADMIN_USER:-admin}

# Emoji directory
EMOJI_DIR="theme/emoji"

# Check if emoji directory exists
if [ ! -d "$EMOJI_DIR" ]; then
    echo -e "${YELLOW}⚠️  Emoji directory not found: $EMOJI_DIR${NC}"
    echo -e "${YELLOW}Skipping emoji setup.${NC}"
    echo -e "${BLUE}💡 To add custom emoji, create $EMOJI_DIR and add PNG/GIF files${NC}"
    exit 0
fi

# Check if there are any emoji files
EMOJI_COUNT=$(find "$EMOJI_DIR" -type f \( -name "*.png" -o -name "*.gif" \) | wc -l | tr -d ' ')

if [ "$EMOJI_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No emoji files found in $EMOJI_DIR${NC}"
    echo -e "${YELLOW}Skipping emoji setup.${NC}"
    echo -e "${BLUE}💡 Add PNG or GIF files to $EMOJI_DIR to use custom emoji${NC}"
    exit 0
fi

echo -e "${BLUE}📁 Found $EMOJI_COUNT emoji file(s) in $EMOJI_DIR${NC}"
echo ""

# Function to upload emoji
upload_emoji() {
    local file_path="$1"
    local emoji_name=$(basename "$file_path" | sed 's/\.[^.]*$//')
    
    # Validate file is an image
    MIME_TYPE=$(file -b --mime-type "$file_path")
    if [[ ! "$MIME_TYPE" =~ ^image/(png|gif)$ ]]; then
        echo -e "${YELLOW}⚠️  Skipping $emoji_name (not PNG/GIF)${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📤 Uploading emoji: $emoji_name${NC}"
    
    # Convert to base64
    BASE64_DATA=$(base64 -i "$file_path" | tr -d '\n')
    DATA_URI="data:${MIME_TYPE};base64,${BASE64_DATA}"
    
    # JSON escape function
    json_escape() {
        local string="$1"
        string="${string//\\/\\\\}"
        string="${string//\"/\\\"}"
        echo "$string"
    }
    
    ESCAPED_URI=$(json_escape "$DATA_URI")
    
    # Make API call
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -u "$OWNCAST_ADMIN_USER:$OWNCAST_ADMIN_PASSWORD" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$emoji_name\",\"data\":\"$ESCAPED_URI\"}" \
        "$OWNCAST_URL/api/admin/emoji")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ Uploaded emoji: :$emoji_name:${NC}"
        return 0
    else
        echo -e "${RED}❌ Error uploading $emoji_name (HTTP $HTTP_CODE)${NC}"
        echo "$BODY"
        return 1
    fi
}

# Upload all emoji files
SUCCESS_COUNT=0
FAIL_COUNT=0

while IFS= read -r emoji_file; do
    if upload_emoji "$emoji_file"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done < <(find "$EMOJI_DIR" -type f \( -name "*.png" -o -name "*.gif" \))

echo ""
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Emoji setup complete! ✨${NC}"
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📊 Results:${NC}"
echo -e "   ${GREEN}✓ Uploaded: $SUCCESS_COUNT${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "   ${RED}✗ Failed: $FAIL_COUNT${NC}"
fi
echo ""
echo -e "${YELLOW}💡 Tip: Use emoji in chat with :emoji_name:${NC}"
echo ""
