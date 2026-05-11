# PRD: HST Scribe Mobile App (Flutter)

## Overview

Mobile/tablet client for ASC nurses to capture clinical conversation, view AI-extracted chart events in real time, edit and confirm them, and sign off into HST eChart.

## Goals

- Capture clinical audio with minimal friction during pre-op and PACU (intra-op later)
- Display extracted chart events within 2s of utterance
- Single-tap confirmation of high-confidence events
- Full nurse control: edit, reject, strike, re-record
- Operate reliably on intermittent wifi

## Non-goals (MVP)

- Always-on ambient capture (push-to-talk only in v1)
- Bluetooth wearable mic support (v2)
- Intra-op OR workflow (v3)
- Full offline mode beyond short local buffering

## Users

- **Primary:** ASC nurses (pre-op, PACU)
- **Secondary:** nurse managers (config and review)

## Key flows

### F1 — Start session
Nurse signs in via SSO → scans patient wristband QR → app fetches patient context (procedure, allergies, current meds) from HST API → confirms *"Documenting for [initials, last4, procedure]"*. Session is now locked to that patient.

### F2 — Capture and review
Nurse taps push-to-talk → app streams audio chunks (250ms, 16kHz PCM16) over WSS → partial transcripts appear in transcript pane → extracted events appear as cards: field, value, time, confidence badge, source utterance.

- **Confirm** (auto-styled green for high confidence): single tap.
- **Edit**: tap card → inline field edit → save.
- **Reject**: swipe left.
- **Voice commands**: "confirm last," "strike that," "pause," "resume."

Confirmed events POST to backend as draft chart entries.

### F3 — Close and sign
Nurse taps End Session → sees summary → resolves any pending events → signs via biometric or PIN. All confirmed events are promoted to final eChart entries.

## Functional requirements

- **FR1** Audio capture at 16kHz mono PCM16, chunked 200–500ms
- **FR2** WebSocket with auto-reconnect and ≤30s local chunk replay buffer
- **FR3** Patient context lock — no capture without confirmed patient ID
- **FR4** Real-time transcript display, p50 < 800ms, p95 < 1.5s latency
- **FR5** Event card UI with confidence states (green ≥0.9, yellow 0.7–0.9, red <0.7)
- **FR6** Edit interactions per field type (numeric keypad, dropdown, free text)
- **FR7** Voice commands: "confirm last," "strike that," "pause," "resume"
- **FR8** Session timeout: auto-end after 30 min idle with warning at 25 min
- **FR9** Sign workflow with biometric (Face/Touch ID) or 6-digit PIN
- **FR10** Session detail screen showing every nurse action in the audit log

## Technical requirements

| Concern | Choice |
|---|---|
| Framework | Flutter, iOS 15+ / Android 10+ |
| Form factor | Optimized for 10–12" tablets; functional on 6" phones |
| Audio | `record` or `flutter_sound`, raw PCM streaming (not file-based) |
| Networking | `web_socket_channel`, mTLS to backend |
| State | Riverpod |
| Local storage | Encrypted secure storage for active session only; no persistent PHI on device |
| Auth | OAuth2 + PKCE against HST IdP; tokens in Keychain / Keystore only |
| MDM | Managed app config support (Intune, Jamf) for tenant config and feature flags |
| Crash reporting | Sentry with scrubbed payloads — no transcript, no PHI ever |

## UX requirements

- Tablet-first layout: transcript pane left 60%, event cards right 40%.
- Phone fallback: stacked layout, transcript collapsible.
- Touch targets ≥ 44pt — nurses wear gloves.
- High-contrast mode for clinical lighting.
- Subtle chime on event captured.
- Patient identification banner pinned to top throughout session: *"J.D. · MRN ••••4821 · Right knee arthroscopy"*. Tap to confirm correct patient.

## Compliance

- No PHI in logs, analytics, or crash payloads. ID references only.
- All persisted data encrypted (Keychain / Keystore).
- App locks after 5 min foreground inactivity → requires biometric/PIN to resume.
- Screenshot prevention on PHI screens.
- BAA-required cloud services only.

## MVP scope (Phase 0)

- F1, F2, F3
- Push-to-talk only
- PACU fields: vitals (BP, HR, SpO2, RR, temp, pain), meds administered, dispo
- Single ASC pilot, iPad only
- iOS-first build (Android parity tracked but lower priority)

See `mobile/CONVENTIONS.md` for code-style rules and folder structure.

## Open questions

- Wristband QR vs RFID — depends on each pilot ASC's existing identification system. MVP supports QR; RFID via plugin abstraction.
- iPad-only MVP or Android tablet parity from day one? — Default iPad-only for Phase 0.
- Voice biometric for sign-off vs PIN — clinical preference unknown. Default biometric, PIN fallback.
