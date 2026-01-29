#!/bin/bash

echo "✨ Starting Barbie Dreamhouse Livestream Server ✨"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running."
    echo "Please start Docker Desktop and try again."
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found. Creating from template..."
    cp .env.example .env
    echo "✓ Created .env file. Please update OWNCAST_ADMIN_PASSWORD if needed."
    echo ""
fi

# Start the containers
echo "🚀 Starting Owncast container..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Server is starting!"
    echo ""
    
    # Automatically apply configuration, theme, and logo
    echo "🎨 Applying Barbie configuration, theme, and logo..."
    echo ""
    
    # Apply server configuration first
    ./scripts/setup-config.sh
    CONFIG_SUCCESS=$?
    
    echo ""
    
    # Apply theme
    ./scripts/setup-theme.sh
    THEME_SUCCESS=$?
    
    echo ""
    
    # Apply logo
    ./scripts/setup-logo.sh
    LOGO_SUCCESS=$?
    
    echo ""
    
    # Upload custom emoji
    ./scripts/setup-emoji.sh
    EMOJI_SUCCESS=$?
    
    if [ $CONFIG_SUCCESS -eq 0 ] && [ $THEME_SUCCESS -eq 0 ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✨ Barbie Dreamhouse Server is Ready! ✨"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📺 Stream page: http://localhost:2001"
        echo "   (Theme and configuration already applied!)"
        echo ""
        echo "🔧 Admin panel: http://localhost:2001/admin"
        echo "   Credentials: admin / abc123 (CHANGE THIS!)"
        echo ""
        echo "🎬 Stream URL for OBS:"
        echo "   Server: rtmp://localhost:1935/live"
        echo "   Key: (get from admin panel)"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Change admin password in admin panel"
        echo "   2. Update .env with your new password"
        echo ""
        echo "💡 Tips:"
        echo "   • Edit config/server-settings.json to change server settings"
        echo "   • Edit theme/ files to customize appearance"
        echo "   • Add theme/logo.png to set a custom logo"
        echo "   • Add custom emoji: place PNG/GIF files in theme/emoji/"
        echo "   • Run ./scripts/setup-config.sh to apply config changes"
        echo "   • Run ./scripts/setup-theme.sh to apply theme changes"
        echo "   • Run ./scripts/setup-logo.sh to upload logo"
        echo "   • Run ./scripts/setup-emoji.sh to upload emoji"
        echo "   • View logs: docker-compose logs -f"
        echo "   • Stop server: docker-compose stop"
        echo ""
    else
        echo ""
        echo "⚠️  Theme setup failed. You can apply it manually later with:"
        echo "   ./scripts/setup-theme.sh"
        echo ""
        echo "📺 Stream page: http://localhost:2001"
        echo "🔧 Admin panel: http://localhost:2001/admin"
        echo ""
    fi
else
    echo "❌ Failed to start server. Check Docker logs for details."
    exit 1
fi
