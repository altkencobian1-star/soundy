# yt-dlp Integration Setup Guide

This guide walks you through setting up yt-dlp for full song downloads in your SOUNDY app.

## What You Get

✅ Full MP3 downloads from YouTube  
✅ Real-time download progress (0-100%)  
✅ Visual progress bars in Downloads page  
✅ Automatic fallback to 30-second preview if download fails  
✅ Offline playback of downloaded songs  

## Step 1: Install yt-dlp

### Option A: Download Executable (Easiest - Windows)

1. Go to: https://github.com/yt-dlp/yt-dlp/releases
2. Download `yt-dlp.exe` (Windows) or `yt-dlp` (Mac/Linux)
3. **Windows users**: Save to `C:\Users\YOUR_USERNAME\yt-dlp.exe`
4. **Mac/Linux users**: Save to `~/yt-dlp` and run `chmod +x ~/yt-dlp`

### Option B: Using Python pip

```bash
pip install yt-dlp
```

### Option C: Using Package Managers

**Windows (Winget):**
```bash
winget install yt-dlp
```

**Windows (Chocolatey):**
```bash
choco install yt-dlp
```

**Mac (Homebrew):**
```bash
brew install yt-dlp
```

## Step 2: Verify Installation

Open a **NEW** terminal window and run:

```bash
yt-dlp --version
```

You should see something like: `2024.04.09`

If you get "command not found", the installation didn't work. Try Option A (direct download) instead.

## Step 3: Test yt-dlp

Run this test command:

```bash
yt-dlp -f "bestaudio[ext=m4a]" --no-playlist "https://www.youtube.com/watch?v=dQw4w9WgXcQ" -o "test.%(ext)s"
```

This should download an audio file. If it works, yt-dlp is ready!

## Step 4: Restart Your Backend

**Important!** The backend needs to detect yt-dlp on startup.

```bash
cd C:\Users\ken\OneDrive\Documents\SOUNDY\backend
npm start
```

You should see a message checking for yt-dlp during startup.

## Step 5: Test Full Downloads

1. Open the app at `http://localhost:5173`
2. Go to **Search** page
3. Search for any song
4. Click the **Download** button on a song
5. Go to **Downloads** page
6. You should see:
   - A progress bar showing download %
   - Download speed (e.g., "2.5 MiB/s")
   - File size information

## How Downloads Work

### Normal Flow (Full Song Available)
```
1. You click Download
2. Backend searches YouTube using yt-dlp
3. Finds full video (3-5 minutes)
4. Downloads audio in real-time
5. Shows progress: 0% → 25% → 50% → 75% → 100%
6. Saves encrypted file locally
7. Shows "FULL" badge in Downloads
```

### Fallback Flow (Full Song Not Available)
```
1. You click Download
2. Backend searches YouTube
3. No suitable video found
4. Falls back to 30-second preview from iTunes
5. Shows "30s" badge in Downloads
6. Still works offline!
```

## Features in the Downloads Page

### Active Downloads Section
- Shows songs currently being downloaded
- Real-time progress bars
- Download speed and file size
- Estimated time remaining

### Downloaded Songs List
- **FULL** badge = Full song from YouTube
- **JAMENDO** badge = Free song from Jamendo
- **30s** badge = 30-second preview (fallback)
- File size shown for each song

## Troubleshooting

### "yt-dlp not found" Error

**Solution 1**: Check location
```bash
# Windows - should show the file
ls $env:USERPROFILE\yt-dlp.exe

# Mac/Linux
ls ~/yt-dlp
```

**Solution 2**: Update backend `.env` file
Create `backend/.env` with custom path:
```
YTDLP_PATH=C:\custom\path\yt-dlp.exe
```

### Downloads Stuck at 0%

1. Check YouTube is accessible in your browser
2. Try updating yt-dlp:
   ```bash
   yt-dlp -U
   ```
3. Check backend console for error messages

### "Download Failed" Errors

Common causes:
- **Age-restricted video**: Try a different song
- **Copyright claim**: Some songs can't be downloaded
- **Network blocked**: Check if YouTube is accessible
- **Rate limited**: Wait a few minutes and retry

The app automatically falls back to 30-second previews for failed downloads.

### Progress Bar Not Showing

Make sure:
1. Backend is running (port 5000)
2. You've added the download route to `server.js`
3. Frontend is polling the `/api/download/progress/:trackId` endpoint

## API Endpoints Added

- `GET /api/download/progress/:trackId` - Get download progress
- `GET /api/download/progress` - Get all user downloads
- `DELETE /api/download/cancel/:trackId` - Cancel active download
- `POST /api/offline/download` - Start download (existing, now with progress)

## Files Modified

### Backend
- `services/downloadService.js` - Real-time progress tracking
- `services/downloadProgress.js` - Progress state management (NEW)
- `routes/download.js` - Progress API endpoints (NEW)
- `routes/offline.js` - Fallback to preview logic
- `server.js` - Added download routes
- `scripts/check-ytdlp.js` - Installation checker (NEW)

### Frontend
- `contexts/OfflineContext.jsx` - Progress polling
- `components/Downloads.jsx` - Progress UI

## Tips

1. **First download takes longer** - yt-dlp needs to cache YouTube info
2. **Downloads are encrypted** - Files are stored securely on your device
3. **Storage location**: `C:\Users\YOUR_USERNAME\SoundyDownloads\`
4. **Clear downloads**: Use the Downloads page to manage offline library
5. **Offline mode**: App automatically detects when you're offline

## Next Steps

- Download 5-10 songs to test offline playback
- Try downloading while offline (should fall back to previews)
- Check storage usage in Downloads page
- Enjoy your music! 🎵
