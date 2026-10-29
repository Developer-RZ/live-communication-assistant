# Architecture Specification

## 1. Architectural Philosophy
The Live Communication Assistant adopts a **Clean Architecture with Feature-First packaging**, structured to ensure:
1. **Platform Independence:** Speech recognition and audio capture are completely abstracted from the presentation layer. The UI communicates strictly with domain abstractions (`SpeechRecognitionService`).
2. **Interchangeable Engines:** The app can toggle between:
   - Platform Native SpeechRecognizer (Google Speech Services on Android) for real-time streaming with low latency.
   - Local Whisper (`whisper.cpp` / ONNX runtime) for strictly offline transcription.
   - Mock / Harness Service for automated unit/widget testing and simulated audio testing.
3. **Local-First Data:** All conversation logs and metadata are stored in an encrypted/private SQLite database using `sqflite`.

## 2. Layered Structure

```
                  ┌────────────────────────────────────────┐
                  │           Presentation Layer           │
                  │ (Screens, Reusable Widgets, Riverpod)  │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │              Domain Layer              │
                  │ (Entities, Value Objects, Interfaces)  │
                  │   - SpeechRecognitionService (abstract)│
                  │   - ConversationRepository (abstract)  │
                  └───────────────────▲────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │               Data Layer               │
                  │ (SQLite AppDatabase, Concrete Repos,   │
                  │  AndroidSpeechService, WhisperAdapter) │
                  └────────────────────────────────────────┘
```

## 3. Speech Recognition Engine Abstraction
```dart
abstract class SpeechRecognitionService {
  Future<void> initialize();
  Future<void> startListening({
    required SupportedLanguage language,
    required Function(SpeechRecognitionResult result) onResult,
    required Function(RecognitionStatus status) onStatusChanged,
    required Function(String error) onError,
  });
  Future<void> pauseListening();
  Future<void> resumeListening();
  Future<void> stopListening();
  Future<void> dispose();
  RecognitionStatus get currentStatus;
  List<SupportedLanguage> get supportedLanguages;
}
```

## 4. Transcript Deduplication & Incremental Assembly
One of the most critical challenges in real-time speech recognition is the distinction between **interim (partial)** results and **finalized** segments:
- Android SpeechRecognizer emits frequent partial hypothesis strings as words are spoken.
- The `LiveTranscriptionNotifier` maintains an active in-flight segment (`activePartialText`).
- When the speech engine signals completion of a speech phrase (or VAD silence threshold is reached), the segment is finalized, assigned a persistent timestamp and unique ID, appended to the immutable transcript list, and committed to SQLite.
- This prevents duplicate text insertion and flickering while keeping rendering latency under 150ms.

## 5. Speaker Attribution Policy
In face-to-face mode, ambient microphone capture receives audio from both the user and conversation partners.
Without multi-microphone beamforming or speaker diarization models (which require heavy GPU resources), speaker labels like "CLIENT" and "YOU" are fundamentally unreliable.
- **Standard Policy:** Segments are displayed chronologically without fabricated speaker labels.
- **Future Diarization Pipeline:** Voice Activity Detection (VAD) coupled with local voiceprint embeddings will only activate speaker labels when confidence exceeds 90%.

## 6. Accessibility Architecture
- High-contrast color palette conforming to WCAG AAA standards (7:1 contrast ratio).
- Scalable typography with dynamic bounds (16sp - 36sp).
- Touch target sizing minimum 48x48dp.
- Direct visual status feedback (animated pulsing waveform & unambiguous state badges).
- Dynamic auto-scroll latching: user manual scroll disengages auto-follow; "Resume Auto-Scroll" floating pill re-engages it.
