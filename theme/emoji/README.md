# Custom Emoji Guide

This directory is where you place custom emoji images for your Owncast chat.

## How to Add Custom Emoji

1. Add PNG or GIF files to this directory
2. Name the file what you want the emoji code to be (e.g., `barbie.png` → `:barbie:`)
3. Run `./scripts/setup-emoji.sh` to upload them to Owncast

## File Requirements

- **Supported formats:** PNG, GIF
- **Recommended size:** 64x64 or 128x128 pixels
- **File naming:** Use lowercase letters, numbers, hyphens, or underscores
- **Examples:**
  - `sparkle.png` → `:sparkle:`
  - `heart-pink.gif` → `:heart-pink:`
  - `barbie_doll.png` → `:barbie_doll:`

## Using Emoji in Chat

Once uploaded, users can use emoji in chat with the syntax `:emoji_name:`

Example: `:barbie:` `:sparkle:` `:heart-pink:`

## Re-uploading Emoji

If you update an emoji image:
1. Replace the file in this directory
2. Run `./scripts/setup-emoji.sh` again
3. The emoji will be updated on the server

## Automatic Upload

When you run `./start.sh`, emoji are automatically uploaded from this directory.

## Tips

- Keep emoji file sizes small (under 100KB) for faster loading
- Use transparent backgrounds for PNG files
- Animated GIFs work great for reaction emoji
- Consider a consistent style that matches your Barbie theme
