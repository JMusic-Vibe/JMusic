# J-Music Project Structure

## Architecture: Feature-First + Clean Architectureflutter pub get
We use a **Feature-First** approach to keep related code together. Each feature module contains its own Data, Domain, and Presentation layers.

## Directory Structure

### `lib/core`
Shared resources across the entire application.
- **config**: Constants, environment variables.
- **services**: Singleton services like `AudioHandler`, `DatabaseService`, `Logger`.
- **theme**: App-wide UI styling.
- **utils**: Formatters, validators.
- **widgets**: Reusable UI components (Buttons, Loading indicators).

### `lib/features`
Functional modules of the app.
- **music_lib**:
  - Scanning local files.
  - Managing the DB entities (Song, Album, Artist).
  - UI for the library listing.
- **player**:
  - The "Now Playing" UI.
  - Logic for playback controls.
- **sync**:
  - WebDAV client implementation.
  - Sync conflict logic.
- **scraper**:
  - MusicBrainz API integration.
  - Metadata parsing (ID3).
- **settings**:
  - User preferences screens.

## Getting Started
1. Run `flutter pub get`
2. Run `dart run build_runner build` (for Isar and Riverpod generation)
