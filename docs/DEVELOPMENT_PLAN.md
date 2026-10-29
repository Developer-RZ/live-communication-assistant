# Development Plan & Phase Milestones

This document outlines the phased roadmap for the Live Communication Assistant.

## Phase 0: Inspection & Architectural Scaffolding
- [x] Environment audit (Flutter, Android SDK, Java, system runtime)
- [x] Project architecture and documentation creation
- [x] Abstract interface definitions for speech recognition and persistence
- [x] Dependency management and analysis setup

## Phase 1: Android Face-to-Face Live Transcription MVP
- [x] Define domain models: `Conversation`, `TranscriptSegment`, `RecognitionStatus`, `SupportedLanguage`
- [x] Implement local SQLite persistence with repository pattern
- [x] Implement pluggable `SpeechRecognitionService` (Android SpeechRecognizer integration with headless mock service for verification)
- [x] Implement reactive state management (`LiveTranscriptionNotifier`) with incremental partial updates and deduplication
- [x] Construct Material 3 accessible UI:
  - Home Screen: Status banner, permission state, quick start, navigation
  - Live Conversation Screen: Visual pulsing listening indicator, real-time transcript streaming, pause/resume/stop, auto-scroll freeze/resume
  - Conversation History Screen: Saved sessions, search query filtering, detail view, rename dialog, delete confirmation, text file export
  - Settings Screen: Language selection (Tamil `ta_IN`, English `en_US`, Tamil-English code-switching guidelines), font size slider, high-contrast toggle, retention rules
- [x] Unit and widget test suite covering deduplication, state transitions, repository CRUD, and UI rendering

## Phase 2: Speech Quality & Multilingual Handling
- [ ] Evaluate Tamil & English acoustic recognition models
- [ ] Benchmark Word Error Rate (WER) and Character Error Rate (CER) on representative Tamil audio
- [ ] Analyze Tamil-English code-switching challenges (e.g. "Meeting-ku late aayiduchu")
- [ ] Implement VAD (Voice Activity Detection) tuning to optimize segment finalization latency

## Phase 3: Offline Whisper Integration
- [ ] Architecture adapter for local `whisper.cpp` / ONNX runtime
- [ ] Measure CPU, RAM, and battery thermal profile during continuous transcription
- [ ] Quantized model selection (Whisper tiny vs base vs small for mobile vs desktop)

## Phase 4: Windows Desktop Implementation
- [ ] Flutter desktop runner support
- [ ] Platform audio adapter for Windows WASAPI / DirectShow audio capture
- [ ] Split-pane master-detail view optimized for desktop monitors

## Phase 5: Telephone Communication Investigation & Resolution
- [ ] In-depth legal, privacy, and technical analysis of Android `VOICE_CALL` and `VOICE_COMMUNICATION` permissions
- [ ] Evaluation of cellular call audio capture restrictions across Android 10+
- [ ] Evaluation of VoIP / In-App calling via WebRTC as the supported path for bidirectional transcription

## Phase 6: Two-Way Remote Transcription & Synchronization
- [ ] Secure signaling channel (WebSocket / WebRTC DataChannel)
- [ ] Bidirectional real-time text sync between caller and deaf user
- [ ] Web-based guest companion portal for participants without the mobile app installed

## Phase 7: Verification, Hardening & Accessibility Audit
- [ ] Automated regression testing
- [ ] WCAG 2.2 AAA accessibility compliance audit
- [ ] Memory leak and battery consumption profiling during 1-hour sustained transcription
