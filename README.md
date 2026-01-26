# Barbie Dreamhouse Livestream Server

A fabulous Barbie-themed Owncast livestream server for hosting 2000s CG Barbie movie watch parties with friends!

## Features

- **Classic Pink Dreamhouse Aesthetic**: Hot pink gradients, sparkles, and glamour fonts
- **Themed Lobby Page**: Beautiful landing page with floating sparkle animations
- **Custom Owncast Theme**: Complete pink makeover of the streaming interface
- **Sparkle Effects**: Floating particles and magical cursor effects
- **Custom Emojis**: Barbie-themed chat emojis (heart, crown, sparkle, etc.)
- **Mobile Responsive**: Works great on all devices

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Ports 8080 and 1935 available

### Installation

1. **Clone or navigate to this repository**
   ```bash
   cd barbie-livestream
   ```

2. **Start the Owncast server**
   ```bash
   docker-compose up -d
   ```

3. **Access the admin panel**
   - Open: `http://localhost:8080/admin`
   - Default credentials:
     - Username: `admin`
     - Password: `abc123`
   - **IMPORTANT**: Change the password immediately!

4. **Configure the theme**

   a. **Add Custom CSS**:
   - In admin panel, go to **General** > **Appearance**
   - Scroll to **Custom CSS** section
   - Copy the contents of `theme/custom.css` and paste it
   - Click **Save**

   b. **Add Custom JavaScript**:
   - In admin panel, go to **General** > **Appearance**
   - Scroll to **Custom Javascript** section
   - Copy the contents of `theme/custom.js` and paste it
   - Click **Save**

   c. **Customize Server Info**:
   - In admin panel, go to **General** > **Server Config**
   - Set your stream name (e.g., "Barbie Movie Night")
   - Set description and welcome message
   - Upload a logo if desired

5. **Add custom emojis** (optional)
   - Follow the guide in `data/emoji/EMOJI-GUIDE.md`
   - In admin panel, go to **General** > **Chat**
   - Upload emoji images from `data/emoji/` directory

6. **Open the lobby page**
   ```bash
   open lobby/index.html
   ```
   Or serve it with any web server

7. **Access the stream**
   - Direct link: `http://localhost:8080`
   - Or click "Enter the Dreamhouse" from the lobby page

## Streaming to Your Server

### Using OBS Studio

1. **Open OBS Studio**

2. **Configure Stream Settings**:
   - Go to **Settings** > **Stream**
   - Service: `Custom`
   - Server: `rtmp://localhost:1935/live`
   - Stream Key: Get this from Owncast admin at **Configuration** > **Stream Key**

3. **Add Sources**:
   - Video source for your movie playback
   - Optional: Webcam, overlays, etc.

4. **Start Streaming**:
   - Click **Start Streaming**
   - Your stream will appear on `http://localhost:8080`

### Other Broadcasting Software

Check Owncast docs for configuration with other software:
- https://owncast.online/docs/broadcasting/

## Project Structure

```
barbie-livestream/
├── docker-compose.yml          # Owncast container configuration
├── lobby/
│   └── index.html              # Themed lobby/landing page
├── theme/
│   ├── custom.css              # Barbie theme CSS for Owncast
│   └── custom.js               # Sparkle effects JavaScript
├── data/
│   ├── public/
│   │   └── images/             # Custom images (logos, backgrounds)
│   └── emoji/                  # Custom Barbie emojis
└── README.md                   # This file
```

## Customization

### Colors

The theme uses these Barbie colors (defined in `theme/custom.css`):
- Hot Pink: `#FF69B4`
- Deep Pink: `#FF1493`
- Light Pink: `#FFB6C1`
- Gold: `#FFD700`
- Lavender Blush: `#FFF0F5`
- Medium Violet Red: `#C71585`

### Fonts

- Display/Headers: `Pacifico` (cursive)
- Headings: `Playfair Display` (serif)
- Body Text: `Poppins` (sans-serif)

### Lobby Page

Edit `lobby/index.html` to customize:
- Movie schedule
- Social links
- About text
- Stream URL (change `http://localhost:8080` if hosting remotely)

### Public Assets

Place custom images in `data/public/images/`:
- Logo: `logo.png`
- Background: `background.jpg`
- Offline banner: `offline-banner.jpg`

Access them at: `http://localhost:8080/public/images/filename.ext`

## Port Configuration

Default ports:
- **8080**: Web interface (stream page, admin, API)
- **1935**: RTMP streaming port

To change ports, edit `docker-compose.yml`:
```yaml
ports:
  - "8080:8080"   # Change left number for different external port
  - "1935:1935"   # Change left number for different external port
```

## Remote Access

To access from other devices on your network:

1. Find your local IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet "
   ```

2. Share this URL with friends:
   ```
   http://YOUR_IP:8080
   ```

3. For streaming from OBS remotely:
   ```
   rtmp://YOUR_IP:1935/live
   ```

### SSL/HTTPS (Production)

For internet hosting with SSL, see:
- https://owncast.online/docs/sslproxies/

## Movie Schedule Examples

Popular 2000s Barbie Movies:
1. Barbie in the Nutcracker (2001)
2. Barbie as Rapunzel (2002)
3. Barbie of Swan Lake (2003)
4. Barbie as The Princess and the Pauper (2004)
5. Barbie: Fairytopia (2005)
6. Barbie and the Magic of Pegasus (2005)
7. Barbie: Mermaidia (2006)
8. The Barbie Diaries (2006)
9. Barbie Fairytopia: Magic of the Rainbow (2007)
10. Barbie as The Island Princess (2007)

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Restart container
docker-compose restart
```

### Can't access admin panel
- Default credentials: `admin` / `abc123`
- Make sure port 8080 is not in use by another service

### Stream not appearing
1. Check that OBS is connected
2. Verify stream key matches in OBS and Owncast admin
3. Check Owncast logs: `docker-compose logs -f`

### Styles not applying
1. Make sure you saved the custom CSS/JS in admin panel
2. Clear browser cache (Cmd+Shift+R on macOS)
3. Check browser console for errors

### Sparkles not appearing
1. Check browser console for JavaScript errors
2. Ensure custom.js was pasted correctly in admin panel
3. Try a different browser (some ad blockers may interfere)

## Stopping the Server

```bash
# Stop but keep data
docker-compose stop

# Stop and remove container (data persists in ./data)
docker-compose down

# Stop and remove everything including data
docker-compose down -v
```

## Backing Up

Your stream data is in the `./data` directory. Back it up regularly:
```bash
# Create backup
tar -czf barbie-owncast-backup-$(date +%Y%m%d).tar.gz data/

# Restore backup
tar -xzf barbie-owncast-backup-YYYYMMDD.tar.gz
```

## Resources

- **Owncast Documentation**: https://owncast.online/docs/
- **OBS Studio**: https://obsproject.com/
- **Barbie Movie Info**: https://en.wikipedia.org/wiki/List_of_Barbie_films

## Legal Notice

This is a fan project for personal use. Barbie and related trademarks are owned by Mattel, Inc. This project is not affiliated with or endorsed by Mattel. Please respect copyright laws when streaming content.

## Support

For Owncast-specific issues:
- GitHub: https://github.com/owncast/owncast
- Chat: https://owncast.rocket.chat

For theme issues, check the JavaScript console and CSS in your browser's developer tools.

---

Made with love and sparkles! Enjoy your Barbie movie nights!
