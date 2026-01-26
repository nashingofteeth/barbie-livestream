# Setup Checklist

Follow this checklist to get your Barbie Dreamhouse livestream server fully configured!

## Initial Setup

- [ ] **Start the server**
  ```bash
  ./start.sh
  # or
  docker-compose up -d
  ```

- [ ] **Access admin panel**
  - Open: http://localhost:8080/admin
  - Login with: `admin` / `abc123`

- [ ] **Change admin password** (IMPORTANT!)
  - Go to: General > Server Config
  - Scroll to "Admin Password"
  - Set a strong password
  - Save

## Theme Configuration

- [ ] **Add Custom CSS**
  1. Open `theme/custom.css` in a text editor
  2. Copy all contents (Cmd+A, Cmd+C)
  3. In admin panel: General > Appearance
  4. Scroll to "Custom CSS"
  5. Paste the CSS
  6. Click "Save"

- [ ] **Add Custom JavaScript**
  1. Open `theme/custom.js` in a text editor
  2. Copy all contents (Cmd+A, Cmd+C)
  3. In admin panel: General > Appearance
  4. Scroll to "Custom Javascript"
  5. Paste the JavaScript
  6. Click "Save"

- [ ] **Test the theme**
  - Open http://localhost:8080 in a new browser tab
  - You should see pink colors and sparkle effects
  - If not, clear cache (Cmd+Shift+R) and refresh

## Server Configuration

- [ ] **Set stream name**
  - Admin panel: General > Server Config
  - "Server Name": e.g., "Barbie Movie Night Dreamhouse"
  - Save

- [ ] **Set stream description**
  - "Server Summary": e.g., "Join us for 2000s Barbie movie marathons!"
  - Save

- [ ] **Add welcome message**
  - "Server Welcome Message": e.g., "Welcome to the Dreamhouse! Grab some snacks and enjoy the show! ✨"
  - Save

- [ ] **Configure page content** (optional)
  - Admin panel: General > Page Content
  - Add custom HTML/Markdown for your page
  - Example:
    ```markdown
    ## Tonight's Feature
    Barbie as The Princess and the Pauper (2004)
    
    ## Schedule
    - 7:00 PM - Pre-show chat
    - 7:30 PM - Movie starts
    - 9:00 PM - Post-movie discussion
    ```

- [ ] **Upload logo** (optional)
  - Admin panel: General > Server Config
  - "Server Logo": Upload a Barbie-themed logo
  - Recommended size: 200x200px PNG

## Custom Emojis

- [ ] **Prepare emoji images**
  - See `data/emoji/EMOJI-GUIDE.md` for details
  - Create or download 6 emoji PNGs (64x64px):
    - sparkle.png
    - heart.png
    - crown.png
    - star.png
    - wand.png
    - kiss.png

- [ ] **Upload emojis to Owncast**
  - Admin panel: General > Chat
  - Scroll to "Custom Emoji"
  - For each emoji:
    - Click "Add Emoji"
    - Upload image file
    - Name: e.g., "sparkle"
    - Add keywords for autocomplete
    - Save

## Streaming Setup

- [ ] **Get your stream key**
  - Admin panel: Configuration > Stream Keys
  - Copy the stream key (keep it secret!)

- [ ] **Configure OBS Studio**
  - Settings > Stream
  - Service: Custom
  - Server: `rtmp://localhost:1935/live`
  - Stream Key: (paste the key from above)
  - Apply

- [ ] **Add video source to OBS**
  - Add a Media Source or Window Capture
  - Set up your movie player

- [ ] **Test stream**
  - Click "Start Streaming" in OBS
  - Open http://localhost:8080
  - You should see your stream!

## Lobby Page Setup

- [ ] **Customize lobby page**
  - Edit `lobby/index.html`
  - Update movie schedule
  - Update social links (Discord, Twitter, etc.)
  - Update "About" text
  - Update stream URL if hosting remotely

- [ ] **Serve lobby page**
  - Option 1: Open file directly in browser
  - Option 2: Use Python server:
    ```bash
    cd lobby
    python3 -m http.server 3000
    # Access at http://localhost:3000
    ```
  - Option 3: Deploy to GitHub Pages or Netlify

## Optional Configuration

- [ ] **Configure chat settings**
  - Admin panel: General > Chat
  - Set username colors
  - Configure moderation settings
  - Enable/disable features

- [ ] **Add custom images**
  - Place images in `data/public/images/`
  - Reference in custom CSS or page content
  - Example: `![Logo](/public/images/logo.png)`

- [ ] **Set up social features** (optional)
  - Admin panel: General > Social
  - Add Fediverse account
  - Configure social posts

- [ ] **Configure video quality**
  - Admin panel: Configuration > Video
  - Adjust based on your upload speed
  - Default settings usually work well

## Pre-Stream Checklist

Before going live with friends:

- [ ] Server is running
- [ ] Theme looks correct
- [ ] OBS is connected and streaming
- [ ] Stream appears on http://localhost:8080
- [ ] Chat is working
- [ ] Custom emojis are available
- [ ] Movie/content is ready to play
- [ ] Friends have the stream URL
- [ ] You've tested audio levels

## Sharing Your Stream

**For local network (same WiFi):**
- [ ] Find your IP: `ifconfig | grep "inet "`
- [ ] Share: `http://YOUR_IP:8080`

**For internet (requires port forwarding or hosting):**
- [ ] Set up SSL/HTTPS (see Owncast docs)
- [ ] Configure reverse proxy (nginx/Caddy)
- [ ] Get a domain name (optional)
- [ ] See: https://owncast.online/docs/sslproxies/

## Troubleshooting

If something doesn't work:

- [ ] Check Docker is running: `docker ps`
- [ ] View logs: `docker-compose logs -f`
- [ ] Restart server: `docker-compose restart`
- [ ] Clear browser cache: Cmd+Shift+R
- [ ] Check browser console for JavaScript errors (F12)
- [ ] Verify OBS stream key matches Owncast
- [ ] Check ports 8080 and 1935 aren't in use

## Done!

Once everything is checked off, you're ready to host fabulous Barbie movie nights! 

Remember to:
- Backup your `data/` directory regularly
- Keep your admin password secure
- Respect copyright when streaming content
- Have fun! ✨

---

Need help? Check the main README.md or Owncast documentation.
