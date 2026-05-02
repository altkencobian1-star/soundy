# SOUNDY PRO - Setup Guide

## ✅ Architecture Implemented

### Backend Services
1. **Search Aggregation Service** (`services/searchService.js`)
   - Searches: Spotify, iTunes, Jamendo
   - Merges & deduplicates results
   - Returns unified track format

2. **Stream Resolution Service** (`services/streamService.js`)
   - Resolves tracks to playable sources:
     - Jamendo (full MP3, direct URL)
     - YouTube (iframe embed, full video)
     - User uploads (direct file)
     - iTunes preview (30-sec fallback)

3. **New API Routes** (`routes/music.js`)
   - `POST /api/music/search` - Multi-source search
   - `POST /api/music/resolve` - Get playable stream URL
   - `GET /api/music/library` - User's saved tracks
   - `POST /api/music/save` - Save to library
   - `GET /api/music/favorites` - Favorites
   - `GET /api/music/history` - Play history

4. **Updated Database Schema**
   - `tracks` - Master catalog with source IDs
   - `user_library` - User's saved tracks
   - `play_history` - Playback tracking
   - `favorites` - Liked tracks

### Frontend Context
- **MusicContext** - Full-featured music player
- Handles: YouTube iframe, Jamendo MP3, User uploads
- Queue, history, shuffle, repeat

## 🚀 To Start Using

### 1. Restart Backend Server
```powershell
cd C:\Users\ken\OneDrive\Documents\SOUNDY\backend
node server.js
```

### 2. Restart Frontend (if needed)
```powershell
cd C:\Users\ken\OneDrive\Documents\SOUNDY\frontend
npm run dev
```

### 3. Access App
- **Frontend:** http://localhost:5173
- **Backend:** http://localhost:5000

## 📊 Test the New System

### Test 1: Search with Full-Track Sources
1. Go to **Search** page
2. Type "test" and search
3. Look for tracks with:
   - **Jamendo** source (green badge) - Full MP3 ready to play
   - **Spotify/iTunes** source - Will resolve to YouTube for full playback

### Test 2: Play Full Song
1. Click any **Jamendo** track (these have direct MP3 URLs)
2. Should play **full song** (not 30-sec preview)
3. Check console for: `Stream resolved: jamendo`

### Test 3: YouTube Resolution
1. Search for a popular song (e.g., "Bohemian Rhapsody Queen")
2. Click a **Spotify/iTunes** result
3. Backend will:
   - Search YouTube for the full video
   - Return YouTube embed URL
   - Play full song via YouTube iframe

## 🔧 API Keys (Optional - for better results)

Create `.env` file in `backend/` folder:

```env
# Spotify (for better metadata)
SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret

# Jamendo (for CC music)
JAMENDO_CLIENT_ID=your_client_id

# YouTube (as fallback)
YOUTUBE_API_KEY=your_api_key
```

Get keys from:
- Spotify: https://developer.spotify.com/dashboard
- Jamendo: https://developer.jamendo.com/v3.0
- YouTube: https://console.cloud.google.com/apis/credentials

## 📁 File Structure

```
SOUNDY/
├── ARCHITECTURE.md          # Full architecture docs
├── SETUP.md                 # This file
├── backend/
│   ├── server.js            # Updated with music routes
│   ├── services/
│   │   ├── searchService.js # Multi-source search
│   │   └── streamService.js # Stream resolution
│   ├── routes/
│   │   └── music.js         # New music API
│   └── db/init.js           # Updated schema
└── frontend/
    └── src/
        └── contexts/
            └── MusicContext.jsx  # New music player
```

## 🎯 Next Steps (If Needed)

1. **Update Search.jsx** - Use `searchMusic` from MusicContext
2. **Update Player.jsx** - Use new `playTrack`, `togglePlay`, etc.
3. **Update Library.jsx** - Use `getLibrary`, `saveToLibrary`
4. **Create NowPlaying.jsx** - Full-screen player view
5. **Add Download Feature** - Use yt-dlp to save songs offline

## 🔍 Troubleshooting

### If YouTube search fails:
- Check yt-dlp is installed: `yt-dlp --version`
- Should show: `2026.03.17` or similar

### If no full songs play:
- Look for **Jamendo** results (free CC music with direct MP3)
- Popular songs may need YouTube API key (quota limits)

### If database errors:
- Delete `database/soundy.db` to reset
- Restart backend to recreate with new schema

---

**The architecture is ready! Try searching and playing a Jamendo track first (these always work with full playback).**
