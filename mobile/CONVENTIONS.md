# mobile/ Conventions

## Project layout — feature-first

```
mobile/
├── lib/
│   ├── main.dart
│   ├── app/                       # App-level: router, theme, providers root
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/              # repositories, API clients, secure storage
│   │   │   ├── domain/            # entities, use cases (pure Dart)
│   │   │   ├── presentation/      # widgets, screens, controllers (Riverpod)
│   │   │   └── auth.dart          # barrel
│   │   ├── session/
│   │   ├── capture/               # mic, WSS streaming, transcript
│   │   ├── events/                # event cards, edit, confirm, reject
│   │   ├── sign/
│   │   └── patient/
│   ├── core/
│   │   ├── contract/              # generated Dart models matching contract/ JSON
│   │   ├── wss/                   # WebSocket envelope, seq, reconnection
│   │   ├── audio/                 # capture, PCM framing
│   │   ├── auth/                  # token store, refresh
│   │   ├── obs/                   # logging (scrubbed), Sentry init
│   │   ├── errors/                # AppError, mapping wire codes → UX
│   │   └── config/                # env + MDM managed config
│   └── widgets/                   # shared atoms (Button, Chip, etc.)
├── test/
│   ├── features/<same shape>
│   └── core/<same shape>
├── integration_test/
├── ios/
├── android/
├── analysis_options.yaml
└── pubspec.yaml
```

Feature folders are self-contained. `core/` is shared infrastructure. `widgets/` is design-system atoms only.

## Code style

- `flutter analyze` clean on every commit. Strict mode in `analysis_options.yaml`.
- `dart format` everything (pre-commit hook).
- Riverpod: `@riverpod` annotations + code generation. No `Provider`, `Bloc`, or `ChangeNotifier`.
- Models: `freezed` for immutable data classes. `json_serializable` for wire types.
- Naming: `*Controller` for Riverpod notifiers, `*Repository` for data access, `*Service` for stateless logic, `*Screen` for full-screen widgets, `*Card` for cards.
- Wire JSON: snake_case via `json_serializable` field rename.
- No `print()`. Use `core/obs/logger.dart` with scrubbed payloads.

## State management

- One Riverpod provider per concern. Avoid god-providers.
- `AsyncValue<T>` for anything async. UI handles `loading`, `error`, `data` explicitly.
- Side effects in controllers (notifiers), not widgets.

## Testing

- Widget tests for screens with key user flows (start session, confirm event, sign).
- Unit tests for any pure logic in `core/` and `features/*/domain/`.
- Integration test for the full happy path against `dev/mock-backend`.
- Golden tests for the patient banner and event card (visual regression).

## PHI handling rules

- No PHI in `print`, `log`, `debugPrint`, Sentry payload, analytics event, crash report.
- Logger automatically scrubs known PHI fields (`patient_name`, `mrn`, `dob`, `transcript`, etc.). Adding a new field requires updating the scrubber.
- No PHI in `SharedPreferences`. PHI in active session only, in `flutter_secure_storage`. Cleared on session end and on app lock.

## Audio

- Capture as raw PCM16 mono at 16kHz, framed every 250ms.
- Local rolling buffer of last 30 seconds (in-memory, never persisted).
- On WSS disconnect: keep capturing into buffer; replay on reconnect using `last_seq`.

## Build & release

- iOS: TestFlight for pilot. Provisioning profiles managed via MDM.
- Android: internal track for pilot.
- Version: semantic. Wire version compatibility checked on `session_started`; if server `protocol_version` unsupported, block and prompt update.

## "Done" for a mobile feature

1. `flutter analyze` clean.
2. `dart format` applied.
3. Widget or integration test covers the primary flow.
4. PHI scrubbing audited if the feature touches user-visible patient data.
5. Works on iPad portrait + landscape and on a 6" phone (functional, not pretty).
6. If it touches the wire: `contract/` updated in the same commit, Dart models regenerated.
