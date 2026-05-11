# hst_scribe

Flutter client for HST Scribe — an AI scribe for ASC (Ambulatory Surgery Center) nurses. Captures clinical conversation, surfaces AI-extracted chart events in real time, lets nurses edit/confirm them, and signs them off into HST eChart.

Read in this order before contributing:

1. `../CLAUDE.md` — project-wide rules
2. `../contract/CONTRACT.md` — wire protocol (single source of truth)
3. `PRD.md` — what we're building
4. `CONVENTIONS.md` — folder layout, naming, testing
5. `AGENTS.md` — senior-eng rules. Hard requirements.

## Getting started

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run --dart-define=API_BASE_URL=https://api.dev.hst-scribe.example --dart-define=WSS_BASE_URL=wss://api.dev.hst-scribe.example --dart-define=ENVIRONMENT=dev
```

## Layout

See `CONVENTIONS.md`. Feature-first under `lib/features/`, shared infrastructure under `lib/core/`, design-system atoms under `lib/widgets/`.
