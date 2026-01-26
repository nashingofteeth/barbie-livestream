#!/bin/bash

echo "✨ Starting Barbie Dreamhouse Livestream Server ✨"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running."
    echo "Please start Docker Desktop and try again."
    exit 1
fi

# Start the containers
echo "🚀 Starting Owncast container..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Server is starting!"
    echo ""
    echo "📺 Stream page: http://localhost:8080"
    echo "🔧 Admin panel: http://localhost:8080/admin"
    echo "   Default credentials: admin / abc123"
    echo ""
    echo "🎬 Stream URL for OBS:"
    echo "   Server: rtmp://localhost:1935/live"
    echo "   Key: (get from admin panel)"
    echo ""
    echo "🏠 Lobby page: ./lobby/index.html"
    echo "   Open in browser or serve with a web server"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Change admin password in admin panel"
    echo "   2. Copy theme/custom.css to admin > Appearance > Custom CSS"
    echo "   3. Copy theme/custom.js to admin > Appearance > Custom Javascript"
    echo "   4. Configure your stream name and settings"
    echo "   5. Add custom emojis (see data/emoji/EMOJI-GUIDE.md)"
    echo ""
    echo "To stop: docker-compose stop"
    echo "To view logs: docker-compose logs -f"
    echo ""
else
    echo "❌ Failed to start server. Check Docker logs for details."
    exit 1
fi
