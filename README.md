# VideoFactory

A local video player built with SwiftUI and mpv, featuring **100% local AI** subtitle transcription and translation. No cloud APIs required - all processing runs on your Mac.

![macOS](https://img.shields.io/badge/macOS-14+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![No Cloud](https://img.shields.io/badge/%E2%9C%93-100%25%20Local%20AI-success.svg)

## Features

- **Hardware-accelerated video playback** via mpv with OpenGL rendering
- **100% local AI subtitle transcription** - whisper-engine runs entirely offline
- **100% local AI subtitle translation** - translation models run locally, no API calls
- **Subtitle management** - supports embedded, external, transcribed, and translated subtitles
- **Fast audio extraction** - FFmpeg-based audio extraction for transcription
- **Customizable playback controls** - including volume, playback speed (0.5x-2.0x), and seek
- **Persistent database storage** - SwiftData for video and subtitle metadata
- **Private by design** - your videos never leave your computer

## Requirements

- macOS 14+ (Sonoma)
- Xcode 15.2+
- Swift 5.9+
- Metal-capable Mac (for OpenGL rendering)

## Project Structure

```
VideoFactory/
├── VideoFactory/                 # Main application target
│   ├── Views/
│   │   ├── OpenGL/              # OpenGL video rendering with mpv
│   │   │   ├── OpenGLVideoLayer.swift          # Core video layer with mpv context
│   │   │   ├── OpenGLVideoLayer+MpvCommand.swift   # MPV command extensions
│   │   │   ├── OpenGLVideoLayer+MpvEvent.swift     # Event handling
│   │   │   ├── OpenGLVideoLayer+MpvNode.swift      # MPV node utilities
│   │   │   ├── OpenGLVideoView.swift               # NSView wrapper
│   │   │   └── OpenGLVideoViewRepresentable.swift  # SwiftUI wrapper
│   │   ├── PlayerControlsView.swift    # Main playback controls
│   │   ├── ResizableWindow.swift       # Window resize handling
│   │   ├── VideoView.swift             # Full-screen container view
│   │   ├── MpvController.swift         # Player control logic
│   │   ├── MpvProperty.swift           # MPV property enum
│   │   ├── AsyncIDs.swift              # Async operation IDs
│   │   └── SubtitlesViewModel.swift    # Subtitle state management
│   ├── Subtitle/
│   │   ├── SubtitleEngine.swift    # AI transcription/translation engine
│   │   ├── SubtitleStore.swift     # Subtitle database access
│   │   ├── VideoStore.swift        # Video library database
│   │   └── Transcribe.swift        # Whisper engine paths
│   ├── AudioFactoryApp.swift        # Main app entry point
│   └── Item.swift                   # Sample SwiftData model
├── Common/                          # Shared framework
│   ├── Models/
│   │   ├── VideoModel.swift        # Video entity for SwiftData
│   │   └── SubtitleModel.swift     # Subtitle entity for SwiftData
│   ├── Utils/
│   │   └── md5.swift               # File hash utility
│   └── Common.h                     # Framework header
├── Engine/                          # Native audio processing
│   ├── AudioProcessorBridge.h      # Objective-C bridge header
│   ├── AudioProcessorBridge.mm     # FFmpeg audio extraction
│   ├── Engine.swift                # Swift API wrapper
│   └── audio-processor/            # C++ audio processing library
│       ├── ffmpeg_processor_impl.cpp
│       └── include/msd/
├── UI/                              # UI components framework
│   ├── Components/
│   │   ├── ControlButton.swift     # Reusable button with hover effect
│   │   └── CustomSlider.swift      # Custom volume/progress sliders
│   ├── Popups/
│   │   ├── SubtitleSelectingView.swift   # Subtitle selection modal
│   │   ├── SubtitleTranscribe.swift      # Transcribe popup
│   │   └── SubtitleTranslate.swift       # Translate popup
│   └── UI.h                         # Framework header
├── ExternalTools/                   # Third-party binaries
│   ├── whis-engine/                 # Whisper AI engine
│   │   └── _internal/              # Python dependencies bundle
│   └── model/                       # Whisper model files
│       ├── base/
│       │   ├── model.bin
│       │   ├── config.json
│       │   ├── tokenizer.json
│       │   └── vocabulary.txt
└── VideoFactory.xcodeproj/          # Xcode project
```

## Architecture

### Video Rendering Pipeline

```
VideoFile → mpv → OpenGL Rendering → CAOpenGLLayer → NSView → SwiftUI
```

The player uses mpv's OpenGL callback rendering (`vo=opengl-cb`) for hardware-accelerated video playback on macOS. The `VideoLayer` class extends `CAOpenGLLayer` and handles:
- MPV context initialization and configuration
- OpenGL FBO rendering
- Display link synchronization
- Event loop processing

### Subtitle System

```
Subtitles
├── Embedded (from video file)
├── External (SRT/ASS files)
├── Transcribed (AI-generated via whisper-engine)
└── Translated (AI-translated from transcribed)

Database: SwiftData (SQLite backend)
```

### Data Persistence

- **VideoStore**: Manages video library with SwiftData
  - Tracks video filepath, hash, duration, play history
  - Supports legacy filepath migration
- **SubtitleStore**: Manages subtitle metadata
  - Organized by video ID
  - Tracks origin (embeded/external/transcribe/translate)
  - **All data stored locally in SQLite database**

## Building and Running

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd VideoFactory
   ```

2. **Open in Xcode**
   ```bash
   open VideoFactory.xcodeproj
   ```

3. **Build and run**
   - Select the VideoFactory target
   - Press Cmd+R to build and run

### Required Build Setup

The project depends on:
- **mpv library** - linked via Xcode project
- **FFmpeg** - for audio extraction
- **Whisper AI** - for transcription/translation (bundled locally in `ExternalTools/`)

## Usage

### Opening Videos
- Use `Cmd+O` to open the file picker
- Select a video file (MP4, MOV, MKV, etc.)

### Subtitle Operations
1. Click the subtitle icon in controls to open the subtitle selector
2. The selector shows four tabs:
   - **Embedded Subtitles**: Detected from video file
   - **External Subtitles**: Loaded from SRT/ASS files
   - **Transcribed**: Generate AI subtitles using local whisper-engine (no internet required)
   - **Translate**: Translate transcribed subtitles using local models (no internet required)

### Controls
- **Volume**: Leftmost control, click to check current volume
- **Playback**: Play/Pause, Fast Forward, Rewind
- **Settings**: Image, Audio Track, Subtitle settings buttons
- **Timeline**: Click and drag to seek
- **Speed**: 0.5x, 1.0x, 1.5x, 2.0x

## Key Components

### VideoLayer (`VideoFactory/Views/OpenGL/OpenGLVideoLayer.swift`)
Core video rendering class that:
- Initializes mpv context with OpenGL rendering backend
- Manages display link for vsync synchronization
- Processes mpv events (file loaded, shutdown, property changes)
- Handles OpenGL FBO rendering with Core Animation

### MpvController (`VideoFactory/Views/MpvController.swift`)
Player control interface providing:
- Play/Pause/Toggle
- Volume control
- Playback speed adjustment
- Track information querying

### SubtitleEngine (`VideoFactory/Subtitle/SubtitleEngine.swift`)
**100% local AI subtitle processing**:
- `transcribe()`: Convert audio to text using local whisper-engine (no API calls)
- `translate()`: Translate transcribed subtitles using local models (no API calls)
- All processing runs locally on your Mac
- Runs as async tasks with cancellation support

### AudioProcessorBridge (`Engine/AudioProcessorBridge.mm`)
**FFmpeg-based local audio extraction**:
- Extracts audio tracks from video files
- Converts to WAV format for whisper-engine processing
- No cloud services involved

## Dependencies

| Component | Purpose | Location | Cloud Required |
|-----------|---------|----------|----------------|
| mpv | Video playback engine | System/Bundled | No |
| FFmpeg | Audio extraction | C++ library | No |
| Whisper AI | Speech recognition (local) | ExternalTools/whis-engine | No |
| SwiftData | Local database | Built-in | No |

| Architecture | Video rendering pipeline | mpv → OpenGL → NSView → SwiftUI |
| Privacy | Subtitle system | 4 types: embedded, external, transcribed, translated |
| Storage | Data persistence | SwiftData (SQLite backend, 100% local) |
| AI | Transcription | Whisper engine, 100% local, no cloud API |
| AI | Translation | Local models, no external API calls |
| Build | Dependencies | mpv, FFmpeg, Whisper AI (all bundled) |
| Controls | Playback features | Volume, speed (0.5x-2.0x), seek |
| Database | Video Library | SwiftData with filepath & hash tracking |

### Changing Window Size
Modify `defaultSize` in `VideoFactoryApp.swift`:
```swift
.windowStyle(.hiddenTitleBar)
.defaultSize(width: 1280, height: 720)
```

### Adjusting Playback Speed Range
Update speed selection in `PlayerControlsView.swift`.

## Development Notes

### Whisper AI Setup (Local, No Internet)
The transcription engine requires:
1. `whis-engine` binary in `ExternalTools/whis-engine/`
2. Model files in `ExternalTools/model/base/`

The paths are configured in `Transcribe.swift`:
```swift
func getWhisEngineExecutable() -> String?
func getWhisModelPath() -> String?
```

### Privacy & Security
- **No internet connection required** for any AI features
- **All video data stays on your Mac**
- **No telemetry or analytics**
- **Whisper models run locally** via Python bundled runtime

### OpenGL Rendering
The player uses macOS OpenGL framework. Ensure your Mac supports OpenGL 3.2+ core profile for optimal rendering.

### Thread Safety
- All UI updates on main thread
- MPV events processed on serial queue `io.mpv.callbackQueue`
- SwiftData operations use `@MainActor` context

## License

MIT License - see LICENSE file for details.

## Author

Created by Jie Chen.
