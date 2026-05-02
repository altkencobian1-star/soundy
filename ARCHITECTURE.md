# SOUNDY PRO - Music Streaming Architecture

## Overview
A legal music streaming platform that aggregates metadata from multiple sources and resolves to playable full-track streams using authorized APIs.

## Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                     FRONTEND (React)                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Search  │  │  Player  │  │ Library  │  │  Queue   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │ API Calls
┌────────────────────▼────────────────────────────────────────┐
│                    BACKEND (Node.js/Express)                 │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐  │
│  │              API Gateway Layer                         │  │
│  │  • Rate limiting • Auth middleware • Request routing │  │
│  └────────────────────┬───────────────────────────────────┘  │
│                       │                                     │
│  ┌────────────────────▼───────────────────────────────────┐  │
│  │           Search Aggregation Service                    │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │  │
│  │  │  Spotify │  │  iTunes  │  │  Discogs │           │  │
│  │  │  API     │  │  API     │  │  API     │           │  │
│  │  └──────────┘  └──────────┘  └──────────┘           │  │
│  └────────────────────┬───────────────────────────────────┘  │
│                       │ Metadata Results                      │
│  ┌────────────────────▼───────────────────────────────────┐  │
│  │         Stream Source Resolver Service                  │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │  │
│  │  │ YouTube  │  │Jamendo   │  │ User     │           │  │
│  │  │  API     │  │ (Free)   │  │ Uploads  │           │  │
│  │  └──────────┘  └──────────┘  └──────────┘           │  │
│  └────────────────────┬───────────────────────────────────┘  │
│                       │ Full Track URLs                         │
│  ┌────────────────────▼───────────────────────────────────┐  │
│  │         Core Services                                   │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │  │
│  │  │  User    │  │ Playlist │  │  Stream  │           │  │
│  │  │ Service  │  │ Service  │  │  Proxy   │           │  │
│  │  └──────────┘  └──────────┘  └──────────┘           │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                      DATABASE (SQLite/PostgreSQL)           │
├─────────────────────────────────────────────────────────────┤
│  • users  • playlists  • tracks  • user_tracks  • favorites │
└─────────────────────────────────────────────────────────────┘
```

## Legal Streaming Sources

### 1. YouTube (via YouTube Data API + iframe Player)
- **Legality**: YouTube ToS allows embedding via iframe API
- **Implementation**: YouTube iframe Player API for full tracks
- **Limitations**: No direct download, ads may play

### 2. Jamendo (Free Music API)
- **Legality**: Creative Commons licensed tracks
- **Implementation**: REST API for search + direct MP3 streaming
- **Limitations**: Only CC-licensed indie music

### 3. SoundCloud (SoundCloud Widget API)
- **Legality**: Widget API for embedding streams
- **Implementation**: iframe embed widget
- **Limitations**: Only streamable tracks, no direct URL

### 4. User Uploads (Local Files)
- **Legality**: User's own music
- **Implementation**: Direct file storage + streaming
- **Limitations**: Only user-provided content

## Data Flow

```
1. User searches "Bohemian Rhapsody Queen"
   ↓
2. Search Service queries:
   - Spotify API → Track metadata (ID, title, artist, album, artwork)
   - iTunes API → Preview URL, additional metadata
   - Discogs API → Extended info, release data
   ↓
3. Aggregated results returned to frontend
   ↓
4. User clicks to play
   ↓
5. Stream Resolver attempts (in order):
   a) YouTube API → Search for official video → Return embed URL
   b) Jamendo → Search for CC version → Return stream URL
   c) Fallback → 30-sec iTunes preview
   ↓
6. Frontend loads appropriate player:
   - YouTube video → iframe Player API
   - Jamendo MP3 → HTML5 Audio
   - User upload → HTML5 Audio
```

## API Integrations

### Required API Keys
1. **YouTube Data API v3** (for search + video info)
2. **Spotify Web API** (for metadata)
3. **Jamendo API** (for free CC music)
4. **Discogs API** (for extended metadata - optional)

### API Rate Limits
- YouTube: 10,000 units/day (search = 100 units)
- Spotify: No explicit limit for metadata
- Jamendo: 500 requests/day (free tier)

## Database Schema

```sql
-- Users
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Master track catalog (from aggregated sources)
CREATE TABLE tracks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  album TEXT,
  duration INTEGER, -- in seconds
  cover_url TEXT,
  spotify_id TEXT,
  youtube_id TEXT,
  jamendo_id TEXT,
  source_type TEXT, -- 'youtube' | 'jamendo' | 'upload' | 'preview'
  stream_url TEXT, -- resolved playable URL
  metadata JSON, -- flexible metadata storage
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- User's library (saved tracks)
CREATE TABLE user_library (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  track_id INTEGER REFERENCES tracks(id),
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, track_id)
);

-- Playlists
CREATE TABLE playlists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  name TEXT NOT NULL,
  description TEXT,
  cover_url TEXT,
  is_public BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Playlist tracks
CREATE TABLE playlist_tracks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  playlist_id INTEGER REFERENCES playlists(id),
  track_id INTEGER REFERENCES tracks(id),
  position INTEGER,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Favorites (liked tracks)
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  track_id INTEGER REFERENCES tracks(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, track_id)
);

-- Play history
CREATE TABLE play_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  track_id INTEGER REFERENCES tracks(id),
  played_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  completed BOOLEAN DEFAULT 0,
  progress_seconds INTEGER
);

-- User uploads (local files)
CREATE TABLE user_uploads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(id),
  track_id INTEGER REFERENCES tracks(id),
  file_path TEXT NOT NULL,
  file_size INTEGER,
  format TEXT, -- 'mp3' | 'flac' | etc
  uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## Frontend Components

### Search Page
```typescript
// Search flow
interface SearchResult {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number;
  coverUrl: string;
  sources: {
    spotify?: SpotifyMetadata;
    youtube?: YouTubeVideo;
    jamendo?: JamendoTrack;
  };
  playableSource?: {
    type: 'youtube' | 'jamendo' | 'upload' | 'preview';
    url: string;
    embedHtml?: string;
  };
}

// Features:
// - Search bar with debounced input
// - Filter by source (YouTube, Jamendo, Local)
// - Sort by relevance, popularity, duration
// - Preview track info before playing
```

### Player Component
```typescript
// Unified player that switches based on source
interface PlayerState {
  currentTrack: Track | null;
  isPlaying: boolean;
  progress: number;
  duration: number;
  volume: number;
  queue: Track[];
  history: Track[];
  repeatMode: 'off' | 'all' | 'one';
  shuffle: boolean;
}

// Player types:
// 1. YouTubePlayer - iframe embed API
// 2. AudioPlayer - HTML5 audio for MP3/FLAC
// 3. SoundCloudPlayer - widget iframe
```

### Library/Playlist Manager
```typescript
// Features:
// - Create/edit/delete playlists
// - Add/remove tracks from playlists
// - Drag-and-drop reordering
// - Import/export playlists (M3U, JSON)
// - Smart playlists (auto-generated based on filters)
```

## Backend Services

### 1. Search Aggregation Service
```javascript
class SearchAggregationService {
  async search(query, options = {}) {
    const sources = options.sources || ['spotify', 'itunes'];
    const results = await Promise.allSettled(
      sources.map(source => this.searchSource(source, query))
    );
    return this.mergeAndRankResults(results);
  }

  async searchSource(source, query) {
    switch(source) {
      case 'spotify': return this.spotifySearch(query);
      case 'itunes': return this.iTunesSearch(query);
      case 'jamendo': return this.jamendoSearch(query);
    }
  }

  mergeAndRankResults(results) {
    // Deduplicate by ISRC or fuzzy title/artist match
    // Rank by popularity, relevance, source quality
    // Return unified format
  }
}
```

### 2. Stream Resolution Service
```javascript
class StreamResolutionService {
  async resolveStream(trackMetadata) {
    // Try sources in order of quality
    const sources = [
      () => this.resolveYouTube(trackMetadata),
      () => this.resolveJamendo(trackMetadata),
      () => this.resolveUserUpload(trackMetadata),
      () => this.resolvePreview(trackMetadata) // last resort
    ];

    for (const resolver of sources) {
      try {
        const stream = await resolver();
        if (stream) return stream;
      } catch (err) {
        console.log('Resolver failed:', err.message);
      }
    }
    return null;
  }

  async resolveYouTube(metadata) {
    // Search YouTube for official video
    // Use YouTube Data API to find best match
    // Return { type: 'youtube', videoId: '...', embedUrl: '...' }
  }

  async resolveJamendo(metadata) {
    // Search Jamendo for CC-licensed version
    // Return { type: 'jamendo', streamUrl: '...' }
  }
}
```

### 3. Stream Proxy (Optional)
```javascript
// For sources that allow direct streaming
// Acts as a proxy to avoid CORS issues
// Can add caching, transcoding, etc.
app.get('/api/stream/:trackId', async (req, res) => {
  const track = await db.getTrack(req.params.trackId);
  const resolved = await streamResolver.resolve(track);
  
  if (resolved.type === 'redirect') {
    return res.redirect(resolved.url);
  }
  
  if (resolved.type === 'proxy') {
    const stream = await fetch(resolved.url);
    res.setHeader('Content-Type', 'audio/mpeg');
    stream.body.pipe(res);
  }
});
```

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Database schema and migrations
- [ ] User authentication system
- [ ] Basic Express API structure
- [ ] Frontend React setup with routing

### Phase 2: Search & Metadata (Week 2)
- [ ] Integrate Spotify API for metadata
- [ ] Integrate iTunes API for metadata + previews
- [ ] Search aggregation service
- [ ] Frontend search page

### Phase 3: Full Playback (Week 3)
- [ ] YouTube Data API integration
- [ ] YouTube iframe Player component
- [ ] Stream resolution service
- [ ] Unified player component

### Phase 4: User Features (Week 4)
- [ ] User library (save/remove tracks)
- [ ] Playlist CRUD operations
- [ ] Favorites system
- [ ] Play history

### Phase 5: Enhanced Features (Week 5)
- [ ] Jamendo integration (free CC music)
- [ ] User uploads (local files)
- [ ] Queue management
- [ ] Advanced search filters

### Phase 6: Polish (Week 6)
- [ ] Offline support for downloads
- [ ] Mobile responsive design
- [ ] Performance optimization
- [ ] Testing & bug fixes

## Security Considerations

1. **API Key Management**
   - Store keys in environment variables
   - Rotate keys regularly
   - Monitor usage for abuse

2. **Rate Limiting**
   - Per-user rate limits on API endpoints
   - Per-IP limits for unauthenticated users
   - Cache search results to reduce API calls

3. **Content Filtering**
   - Block explicit content (YouTube contentRating)
   - Region-based availability checks
   - Copyright compliance

4. **User Data Privacy**
   - Encrypt sensitive data at rest
   - Hash passwords with bcrypt
   - Allow data export/deletion (GDPR compliance)

## Scalability Plan

### Phase 1: Single Server (Current)
- SQLite database
- Single Node.js process
- In-memory caching
- Good for: 1-100 users

### Phase 2: Multi-Process (Scale Up)
- PostgreSQL database
- PM2 cluster mode
- Redis for caching
- Good for: 100-10,000 users

### Phase 3: Distributed (Scale Out)
- Microservices architecture
- Kubernetes orchestration
- CDN for static assets
- Load balancer for API
- Good for: 10,000+ users

## Cost Estimates (Monthly)

### Development Phase
- Hosting (Heroku/Render free tier): $0
- YouTube API: $0 (10k units/day free)
- Spotify API: $0 (no cost for metadata)
- Jamendo API: $0 (free tier)
- Total: **$0**

### Production Phase (10k users)
- VPS (DigitalOcean/Linode): $40
- PostgreSQL (Managed): $15
- YouTube API (exceeds free): $20
- CDN (CloudFlare): $0
- Total: **$75/month**

## Next Steps

1. Review and approve architecture
2. Set up API keys for YouTube, Spotify, Jamendo
3. Initialize database
4. Build search aggregation service
5. Implement stream resolution
6. Create unified player

---

**This architecture provides a solid foundation for a legal, scalable music streaming platform with full-track playback from authorized sources.**
