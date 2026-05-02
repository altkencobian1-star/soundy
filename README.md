# Soundy - Spotify-like Music App MVP

A music player application with search, playlists, favorites, and offline downloads.

## Tech Stack
- **Frontend**: React + Vite + TailwindCSS + Lucide Icons
- **Backend**: Node.js + Express
- **Database**: SQLite (via better-sqlite3)
- **Auth**: JWT + bcrypt

## Getting Started

### 1. Install Backend Dependencies
```bash
cd backend
npm install
```

### 2. Install Frontend Dependencies
```bash
cd frontend
npm install
```

### 3. Start Backend (port 5000)
```bash
cd backend
npm run dev
```

### 4. Start Frontend (port 5173)
```bash
cd frontend
npm run dev
```

### 5. Open in Browser
Go to http://localhost:5173

## Features
- User registration & login
- Upload and play music (MP3, WAV, OGG, FLAC, M4A)
- Search songs by title, artist, or album
- Create and manage playlists
- Favorite songs
- Download tracking for offline access
- Spotify-inspired dark UI

## Project Structure
```
SOUNDY/
├── backend/
│   ├── server.js          # Express server entry
│   ├── db/init.js         # SQLite database setup
│   ├── middleware/auth.js  # JWT auth middleware
│   └── routes/
│       ├── auth.js        # Login/Register APIs
│       ├── songs.js       # Song CRUD + favorites + downloads
│       └── playlists.js   # Playlist management APIs
├── frontend/
│   ├── src/
│   │   ├── main.jsx       # App entry point
│   │   ├── App.jsx        # Main app with routing
│   │   ├── index.css      # TailwindCSS styles
│   │   ├── contexts/
│   │   │   ├── AuthContext.jsx   # Auth state
│   │   │   └── PlayerContext.jsx # Audio player state
│   │   └── components/
│   │       ├── AuthPage.jsx   # Login/Register
│   │       ├── Sidebar.jsx    # Navigation sidebar
│   │       ├── Player.jsx     # Bottom music player
│   │       ├── Home.jsx       # Home with upload
│   │       ├── Search.jsx     # Search songs
│   │       ├── Playlists.jsx  # Playlist management
│   │       ├── Favorites.jsx  # Liked songs
│   │       └── Downloads.jsx # Offline downloads
│   └── public/
├── database/              # SQLite DB (auto-created)
└── audio-storage/         # Uploaded audio files (auto-created)
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Register new user |
| POST | /api/auth/login | Login |
| GET | /api/auth/me | Get current user |
| GET | /api/songs | List all songs |
| POST | /api/songs/upload | Upload audio file |
| GET | /api/songs/search/:query | Search songs |
| POST | /api/songs/:id/favorite | Toggle favorite |
| GET | /api/songs/favorites/list | Get favorites |
| POST | /api/songs/:id/download | Track download |
| GET | /api/songs/downloads/list | Get downloads |
| GET | /api/playlists | Get user playlists |
| POST | /api/playlists | Create playlist |
| GET | /api/playlists/:id | Get playlist + songs |
| POST | /api/playlists/:id/songs | Add song to playlist |
| DELETE | /api/playlists/:id/songs/:songId | Remove song |
| DELETE | /api/playlists/:id | Delete playlist |
