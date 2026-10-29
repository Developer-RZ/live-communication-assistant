# Live Communication Assistant

An accessible, privacy-centric, real-time speech-to-text communication application designed specifically for individuals who can speak normally but are deaf or hard-of-hearing.

## Core Purpose
The application bridges the communication gap during:
1. **Face-to-Face Conversations:** Captures ambient microphone audio and renders spoken dialogue into high-contrast, large-format, incremental live text without requiring other participants to install any app.
2. **Telephone Conversations:** Structured architecture evaluating platform-permitted audio paths (cellular restrictions vs. VoIP/WebRTC integration) for bidirectional transcription.

## Key Architectural Principles
- **Clean Architecture & Feature-First Structure:** Separation of Presentation, Domain, Application, and Data layers.
- **Replaceable Speech Recognition Engine:** Pluggable `SpeechRecognitionService` supporting Android SpeechRecognizer, mock testing harnesses, and Whisper-based offline backends (`whisper.cpp` / local models).
- **Accessibility by Default:** Material 3 high-contrast mode, dynamic font sizing (16sp - 36sp), auto-scroll controls with manual freeze, visual status indicators (no reliance on sound feedback), and screen-reader semantics.
- **Privacy First & Local Storage:** Transcripts persisted locally in SQLite; zero cloud dependencies for core face-to-face operation; raw audio capture disabled by default.
- **Cross-Platform Readiness:** Primary mobile target on Android, with desktop runner architecture for Windows.

## Project Structure
```
lib/
├── app/                  # Main App configuration, themes, routing
├── core/                 # Shared utilities, failure types, permissions
└── features/
    ├── accessibility/    # Dynamic text sizing & contrast models
    ├── conversations/    # SQLite persistence, transcript repository, history UI
    ├── home/             # Accessible launcher screen
    ├── live_transcription/ # Real-time conversation screen, controls, auto-scroll
    ├── settings/         # Engine settings, language preference, privacy retention
    └── speech_recognition/ # Abstract recognition engine, Android integration, Whisper adapters
```

## Documentation
- [Architecture & Design Decisions](docs/ARCHITECTURE.md)
- [Development Plan & Phases](docs/DEVELOPMENT_PLAN.md)
- [Testing Strategy & Test Suites](docs/TESTING.md)
- [Platform & OS Limitations (Android & Windows)](docs/PLATFORM_LIMITATIONS.md)
