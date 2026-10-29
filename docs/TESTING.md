# Testing Strategy & Quality Assurance

This document details the test strategy, automated test suites, and manual verification protocols for the Live Communication Assistant.

## 1. Automated Test Suites

### A. Unit Tests (`test/unit/`)
- **`live_transcription_state_test.dart`**:
  - Validates the complete state machine lifecycle: `idle` -> `initializing` -> `listening` -> `paused` -> `stopped` -> `error`.
  - Verifies auto-scroll toggle behavior and transcript freeze during manual review.
- **`transcript_deduplication_test.dart`**:
  - Tests stream ingestion of repetitive partial hypothesis updates (`"I"`, `"I need"`, `"I need help"`, `"I need help with business."`).
  - Asserts that partial tokens update a single mutable buffer and do not spawn duplicate historical segments.
  - Tests finalization boundaries when silence or end-of-phrase markers arrive.
- **`conversation_repository_test.dart`**:
  - Tests SQLite database operations: insert conversation, query conversations, update title/notes, delete conversation, and append transcript segments.
  - Tests search query filtering across saved conversations.
- **`speech_recognition_service_test.dart`**:
  - Tests the abstract `SpeechRecognitionService` contract using `MockSpeechRecognitionService`.
  - Validates error propagation (permission denied, network drop, speech timeout).
- **`user_settings_test.dart`**:
  - Tests serialization and validation of accessibility settings (font scale, high contrast, retention days, language selection).

### B. Widget & Accessibility Tests (`test/widget/`)
- **`home_screen_test.dart`**:
  - Checks that high-contrast buttons, status indicators, and screen reader semantic labels are present.
  - Verifies navigation taps to Live Transcription, History, and Settings.
- **`live_conversation_screen_test.dart`**:
  - Simulates incoming partial and final results and asserts UI rendering.
  - Verifies that pause, resume, clear, and save buttons function as expected.
  - Verifies that visual listening indicator pulses/updates state without audio cues.
- **`settings_screen_test.dart`**:
  - Tests font scale slider changes, theme toggles, and language pickers.

## 2. Accessibility Verification Checklist (WCAG 2.2 AAA Target)
- [x] Text contrast ratio >= 7:1 for normal text and >= 4.5:1 for large text.
- [x] All interactive touch targets are at least 48x48dp.
- [x] No auditory cues are used without a corresponding high-visibility visual cue.
- [x] Text size can be scaled up to 36sp without clipping or layout overflow.
- [x] Every icon and interactive control has a descriptive `Semantics` label.

## 3. Manual Testing Procedure on Physical Android Devices
1. **Microphone Permission Flow:**
   - Launch app on clean install.
   - Tap "Start Conversation".
   - Verify standard Android runtime permission dialog appears.
   - Deny permission: Verify application displays clear, accessible explanation and a direct button to Open App Settings.
   - Grant permission: Verify speech recognition transitions immediately to listening state.
2. **Speech Ingestion & Incremental Streaming:**
   - Speak a complete sentence in English ("Hello, I am testing real-time transcription").
   - Confirm partial words appear within ~200ms.
   - Pause for 1.5 seconds: Confirm the segment finalizes without duplicate words.
   - Speak in Tamil ("வணக்கம், எப்படி இருக்கிறீர்கள்?") with Tamil language selected.
   - Confirm UTF-8 Tamil script renders properly without character corruption.
3. **Audio Interruption & Backgrounding:**
   - While listening, simulate an incoming cellular call or switch to home screen.
   - Confirm app pauses or safely handles microphone interruption without crashing.
