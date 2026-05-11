# Flutter — Senior Engineering Rules

Read these BEFORE writing code: `CLAUDE.md` (root) → `mobile/PRD.md` → `mobile/CONVENTIONS.md` → this file.

Goal: code a senior Flutter engineer would merge without asking for a rewrite. Not tutorial Flutter. Production Flutter.

---

## Hard rules

### State
- **Riverpod with code generation** (`@riverpod`). No `Provider`, no `Bloc`, no `ChangeNotifier`.
- `setState` is allowed ONLY for purely-local widget UI state (expanded/collapsed, focus). Anything that survives a rebuild → Riverpod.
- **`AsyncValue<T>`** for every async result. UI handles `.loading`, `.error`, `.data` explicitly. No `data!`, no `?.value!`.
- Controllers (notifiers) hold state; widgets render it. Never the other way round.

### Models
- **`freezed`** for every data class. No mutable POJOs.
- **`json_serializable`** with `@JsonKey(name: 'snake_case')` to match the wire (contract/).
- Domain models ≠ wire models. Wire models live in `core/contract/`; domain models in `features/<x>/domain/`. Map at the data layer.
- Codegen runs in `build_runner` — committed `*.g.dart` / `*.freezed.dart` files (or regenerated in CI, pick one and commit).

### Async safety
- After every `await`, check `if (!mounted) return;` before touching `BuildContext`. Non-negotiable.
- No `setState` in async callbacks without a mounted check.
- Cancel `Timer`s, `StreamSubscription`s, `AnimationController`s in `dispose()` or on provider disposal (`ref.onDispose`).

### Navigation
- `go_router` with type-safe routes. No `Navigator.push` with string paths from feature code.
- Route definitions live in `app/router.dart`. Feature code calls `context.goNamed(Routes.x)`.
- Deep links handled by router config, never by widgets.

### Error handling
- At the data layer, map exceptions to typed `Failure`s. UI consumes `AsyncValue` and switches on the failure type.
- Never silently catch. Either rethrow with context (`Error.throwWithStackTrace`) or convert to a typed failure.
- Don't catch `Exception` (too broad). Catch specific types or use `AsyncValue.guard`.

### PHI safety — clinical-grade
- Never `print`, `debugPrint`, or log raw model fields. Use `core/obs/logger.dart` which scrubs known PHI keys.
- Never store PHI in `SharedPreferences`. `flutter_secure_storage` only, cleared on session end.
- Never include PHI in Sentry breadcrumbs or crash payloads. Configure the scrubber BEFORE `Sentry.init`.
- Screenshot prevention on PHI screens — `FLAG_SECURE` on Android, snapshot-blur on iOS background.
- Adding a new patient field? Update the log scrubber in the same commit.

### Performance
- `const` constructors everywhere they apply. The analyzer should fail the build if missing.
- `ListView.builder` for any list >20 items. Never `.map().toList()` into a `Column`.
- Scope rebuilds: `Consumer` / `ref.watch(p.select((x) => x.y))` — never watch a whole big provider just to read one field.
- `Image.network` with `cacheWidth` set; never load unbounded full-size images.
- Avoid `setState` in animation frames — use `AnimationController` + `AnimatedBuilder`.

### Accessibility
- `Semantics` labels on every interactive widget. Test with TalkBack and VoiceOver.
- Touch targets ≥ 44pt. Nurses wear gloves.
- Color contrast ≥ 4.5:1 for normal text.
- Support 200% text scale. Don't lock font size.

### Internationalization
- `l10n` from day one, even if only `en_US` ships. Never hardcode user-visible strings.
- Numbers and dates go through `intl`. No `toString()` for clinical values.

### Testing
- **Widget tests** for every screen — at least the happy path and one failure mode.
- **Unit tests** for domain logic (pure Dart, no Flutter imports).
- **Golden tests** for the patient banner and event card. Re-bless deliberately, not reflexively.
- **Integration test** for the start-session → capture → confirm → sign flow against `dev/mock-backend`.
- Test behavior, not implementation. No `expect(find.byType(_SomePrivateWidget))`.

---

## Project layout reminder (see CONVENTIONS.md for full tree)

Feature-first. Each feature has `data/`, `domain/`, `presentation/`. `core/` is shared infra. `widgets/` is design-system atoms only.

---

## What "done" means

1. `flutter analyze` → 0 issues.
2. `dart format` applied.
3. Tests added — or an explicit one-line reason in the PR if not.
4. PHI audit: grep your diff for patient fields, confirm scrubbed in logs.
5. Verified on iPad portrait + landscape AND on a 6" phone (functional minimum).
6. If the wire changed: `contract/` updated in the same commit, Dart models regenerated.

---

## Anti-patterns — instant reject

- `BuildContext` used across an `await` without `mounted` check.
- Business logic inside `build()`.
- A widget >200 lines without a structural reason.
- A `StatefulWidget` where a `ConsumerWidget` + Riverpod would suffice.
- `dart:io` imports in widgets — platform code belongs in `core/`.
- Hardcoded user-visible strings.
- `TODO` without a tracking comment naming what's missing.
- `Future.delayed` / `sleep` as a synchronization mechanism.
- Catching `Exception` broadly.
- A god-provider that holds half the app's state.

---

## Pitfalls specific to HST Scribe

- **WSS reconnection** — on `onError` / `onDone`, schedule reconnect with exponential backoff and resume from `last_seq`. Never tight-loop reconnect. Local audio buffer (last 30s) replays on reconnect.
- **Audio capture** — use a real PCM streaming plugin (`record` with stream mode, or `flutter_sound`). Don't write to file and read back — latency kills the product.
- **Patient banner** — ALWAYS visible during a session. If you build a session screen without it, you've made a mistake.
- **Patient context lock** — capture is impossible until the patient context is confirmed by the nurse. Don't bypass for "dev convenience."
- **Sign workflow** — biometric happens on-device (`local_auth`), not via a server round-trip.
- **Confidence states** — green ≥0.9, yellow 0.7–0.9, red <0.7. Don't show raw percentages to nurses; show the badge.

---

## Dependency baseline (pin in `pubspec.yaml`)

| Package | Why |
|---|---|
| `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | state |
| `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation` | models |
| `build_runner` | codegen |
| `go_router` | typed routing |
| `web_socket_channel` | WSS |
| `record` or `flutter_sound` | streaming PCM capture |
| `flutter_secure_storage` | tokens + active session PHI |
| `local_auth` | biometric sign-off |
| `intl` | i18n, formatting |
| `dio` (or `http`) | REST; one only |
| `sentry_flutter` | crash reporting with scrubbing |
| `mobile_scanner` | wristband QR scanning |
| `logger` or custom `core/obs` | structured logging |

No package outside this list without a written justification in the PR.

---

## Reading order for any task

1. `contract/CONTRACT.md` — what's on the wire?
2. `mobile/PRD.md` — what's the user trying to do?
3. This file + `CONVENTIONS.md` — how do we build it?
4. The closest existing feature folder — what does precedent look like?

Then write code.
