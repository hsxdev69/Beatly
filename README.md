# Echo Music — Flutter Clone

A pixel-accurate Flutter-based Android music streaming application inspired by and functionally equivalent to the open-source [Echo Music](https://github.com/EchoMusicApp/Echo-Music) Android application.

---

## Architecture

This project follows **Clean Architecture** with a feature-based folder structure:

```
lib/
├── main.dart                          # Application entry point & local storage init
├── app/
│   ├── app.dart                       # MultiProvider & Shell setup
│   └── theme/
│       ├── colors.dart                # Theme color tokens matching screenshots
│       ├── typography.dart            # Typography hierarchy
│       └── app_theme.dart             # Light & Dark Material3 themes
├── core/
│   ├── constants/
│   │   └── api_constants.dart         # Configurable networking for Emulator, LAN & Web
│   ├── database/
│   │   └── local_storage.dart         # Preferences, favorites, and history cache
│   ├── network/
│   │   └── music_repository.dart      # InnerTube / iTunes API & LRCLIB lyrics client
│   └── services/
│       └── audio_player_service.dart  # Centralized player state & playback engine
├── features/
│   ├── home/presentation/             # Home Screen (Home.png)
│   ├── search/presentation/           # Search & Explore (search page.png)
│   ├── library/presentation/          # Library & Playlists (library.png)
│   ├── player/presentation/           # Apple Full Player & Floating Mini Player
│   ├── queue/presentation/            # Now Playing Queue Sheet
│   └── lyrics/presentation/           # Real-time Synchronized Lyrics (lyrics.png)
└── shared/
    └── models/
        └── song.dart                  # Strongly typed Song, LyricLine & Playlist models
```

---

## Features & UI Reproduction

* **Home Screen (`Home.png`)**:
  * Top bar with exact `Echo Music` header and history, stats, group, and profile icons.
  * Mood & activity pills (`Feel good`, `Romance`, `Relax`, `Party`, `Energize`).
  * Carousel hero banner for **Khalasi | Coke Studio Bharat** with side peek preview cards.
  * **FORGOTTEN FAVORITES** list (*Vaaroon Forever*, *Bairan*, *Ghar More Pardesiya*, *Sahiba*) with "Play all".
  * **STATION / LISTEN TOGETHER** section.

* **Search & Explore (`search page.png`)**:
  * Input bar with *"Search YouTube Music..."* placeholder and globe icon.
  * Live instant search querying real streaming tracks.
  * **Apple Music Top 100** chart (*Patient Zero*, *Cleveland!*, *Pink Clouding*, *Babylon*, *Choosin' Texas*).
  * Ranked badges and pagination pill (`< 1 of 6 >`).
  * Trending Artists horizontal cards.

* **Library Screen (`library.png`)**:
  * Filter chips (`Playlists`, `Songs`, `Albums`, `Artists`, `Local`).
  * Sort pill (`Date added` with arrow).
  * 2-Column action grid (*Liked*, *Downloaded*, *Exported*, *Cached*, *My top 50*, *My bottom 50*, *Local*).
  * Playlists view with add button.

* **Floating Mini-Player & Liquid Glass Dock (`Liquid Glass Apple Inspired.png`)**:
  * Floating frosted glass mini-player pill above the bottom dock.
  * Apple-inspired frosted glass dock with active Home capsule, mic, library note, and search circle.

* **Full Player & Synchronized Lyrics (`Apple inspired music page.png` & `lyrics.png`)**:
  * Full-bleed background album art with gradient scrim.
  * Big white Apple-style playback buttons (`|<<`, `▶`/`❚❚`, `>>|`).
  * iOS rounded scrubber bar with elapsed/total times.
  * Live synchronized lyrics powered by LRCLIB, highlighting the active singing line.

---

## Local Development & Running

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Localhost / Web Preview
```bash
# Build web assets
flutter build web

# Start local server with search & lyrics proxy
python3 server.py
```
Open **`http://localhost:8080`** in your browser.

### 3. Run on Android Device / Emulator
```bash
flutter run
```

---

## Building the Android APK

Build the release APK locally:
```bash
flutter build apk --release
```
The output file is located at:
`build/app/outputs/flutter-apk/app-release.apk`

Or push to GitHub to trigger the automated CI workflow in `.github/workflows/build_apk.yml`!
