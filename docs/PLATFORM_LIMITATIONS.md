# Platform Limitations & Security Constraints Analysis

## 1. Android Audio & Cellular Call Limitations
A primary objective of this project is to assist deaf users during telephone conversations. However, operating system security boundaries impose strict architectural constraints that must be clearly addressed.

### A. Cellular Call Capture on Android 10+ (API 29+)
- **Historical Context:** In legacy Android versions (Android 9 and earlier), applications with `RECORD_AUDIO` could sometimes tap into `AudioSource.VOICE_CALL` or `AudioSource.VOICE_COMMUNICATION`.
- **Current Security Model:** Starting with Android 10 (API 29) and further tightened in Android 11, 12, 13, and 14:
  - The Android Framework restricts `VOICE_CALL` audio capture strictly to pre-installed system apps holding `android.permission.CAPTURE_AUDIO_OUTPUT`, signed with the platform platform-key or configured as the default system dialer / telecom framework.
  - Third-party apps requesting `AudioSource.VOICE_CALL` receive silence (zeroed PCM buffers) or throw `SecurityException`.
  - Android accessibility services (`AccessibilityService`) cannot be misused to capture downlink call audio streams; Google Play actively bans and disables apps attempting call recording workarounds.
- **Microphone Exclusivity:** When a cellular call is active, the telephony stack holds exclusive or highest-priority lock on the hardware microphone. A concurrent app attempting `AudioRecord` or `SpeechRecognizer` will either fail to initialize or capture only uplink audio through acoustic leakage if speakerphone is engaged.

### B. Technically Feasible Approaches for Call Accessibility
Given these real-world constraints, the application implements and evaluates three distinct paths:
1. **Acoustic Speakerphone Mode (Immediate Physical Workaround):**
   - The user places the telephone call on speakerphone.
   - The Live Communication Assistant listens via ambient microphone, transcribing both the user's voice and the caller's audio emerging from the loudspeaker.
   - **Trade-offs:** Requires quiet room; fidelity is affected by speakerphone distortion and echo cancellation.
2. **Dedicated VoIP / In-App Calling (Full Digital Fidelity):**
   - Both participants communicate through an integrated WebRTC / VoIP audio channel inside the application or via a zero-install Web companion link.
   - In this mode, digital audio buffers from the remote participant are available directly in software before playback, enabling 100% clean digital input to the speech recognition pipeline without ambient noise.
3. **Android Telecom ConnectionService / Companion Dialing:**
   - Utilizing Android's `InCallService` if registered as the user's default assistant or companion app, providing call state triggers and speakerphone auto-activation.

---

## 2. Windows Desktop Audio Capture
On Windows:
- Windows allows capturing default render endpoints using WASAPI Loopback (`AUDCLNT_STREAMFLAGS_LOOPBACK`), allowing PC-based calls (Zoom, Teams, Skype) to be transcribed with high fidelity.
- Traditional cellular phone calls routed via Microsoft Phone Link / Link to Windows run over Bluetooth HFP (Hands-Free Profile) and are treated as separate audio endpoints.

---

## 3. Speech Recognition Engine Trade-offs

| Attribute | Android SpeechRecognizer | Local Whisper (whisper.cpp) | Cloud Speech API |
| :--- | :--- | :--- | :--- |
| **Network Requirement** | Requires online connection on most budget devices; offline package available on Pixel/Samsung flagships | Strictly offline (100% local) | Requires continuous internet connection |
| **Latency** | Extremely low (partial results in < 150ms) | Higher (0.8s - 2.5s on mobile CPU/NPU) | Moderate (200ms - 500ms depending on RTT) |
| **Tamil Language Support** | High (Google speech models for `ta-IN`) | Good (`whisper-small` or fine-tuned `whisper-tamil`) | High |
| **Code-Switching (Tanglish)** | Moderate (tends to bias towards either pure Tamil or English script) | Variable without fine-tuning | High |
| **Resource Footprint** | Negligible (handled by OS service) | Heavy (200MB - 1GB RAM; high CPU usage) | Zero local CPU/GPU load |
| **Recurring Cost** | Zero | Zero | Recurring API cost ($0.016-$0.024/min) |
