# Mobile codegen on Windows hosts: the `objective_c` / native-assets trap

If you came here because `dart run build_runner build` (or
`flutter pub run build_runner build`) failed on a Windows dev box with
either of these messages, this doc is for you.

```
Package(s) objective_c require the native assets feature to be enabled.
Enable native assets with `--enable-experiment=native-assets`.
```

…or, when the experiment flag is added:

```
FormatException: Unexpected end of input (at character 1)
  at PackageGraph.fromPubDepsJsonString
```

## The problem

The Flutter SDK we target (3.41.x) ships with a `path_provider_foundation`
release line that pulls **`objective_c >= 9.0.0`**. `objective_c 9.x`
declares the `native-assets` Dart experiment as a requirement. That has
two cascading effects in our toolchain:

1. `build_runner` refuses to start without `--enable-experiment=native-assets`,
   because at least one package in the graph (`objective_c`) requires it.
2. With the experiment flag enabled, `build_runner`'s
   `NativeAssetsBuildPlanner` shells out to `pub deps --json` and on
   Windows the captured output is occasionally empty / partial — the
   planner then crashes parsing it (`FormatException: Unexpected end of
   input`). This is an upstream `dart-lang/build` issue with how the
   subprocess output is buffered on Windows.

The chain that pulls `objective_c` into a Windows app build (where it is
otherwise irrelevant — `objective_c` is iOS/macOS plumbing) is:

```
flutter_secure_storage_windows
  └── path_provider                          (^2.1.5)
        └── path_provider_foundation         (^2.3.2, resolves to 2.6.0)
              └── objective_c                (^9.2.1)
                    └── code_assets / hooks / native_toolchain_c (native-assets)
```

So even with `local_auth` and `sentry_flutter` commented out, the
transitive remained — the workaround the Wave 1 pubspec attempted (commenting
those two packages out) did not actually solve the problem.

## What we tried (chronological)

### Option A — `dependency_overrides: objective_c: ^8.0.0`

Tried first because it's the package that declares the native-assets
requirement. **Failed** at solver time: `path_provider_foundation 2.5.0`
and `2.6.0` declare `objective_c: ^9.1.0` / `^9.2.1`. Forcing `objective_c`
back to 8.x makes the constraints unsolvable without also pinning
`path_provider_foundation`. So this is equivalent in cost to Option B
but more invasive.

### Option B — `dependency_overrides: path_provider_foundation: 2.5.1` (chosen)

`path_provider_foundation`'s version history on pub.dev, filtered by
which versions declare an `objective_c` dependency:

| Version | Declares `objective_c`? |
|---------|-------------------------|
| 2.1.0 – 2.4.4 | no |
| **2.5.0** | yes (`^9.1.0`) |
| **2.5.1** | **no** (re-published without it) |
| **2.6.0** | yes (`^9.2.1`) — current latest |

`2.5.1` is the most recent foundation release that does **not** pull
`objective_c`, and it satisfies the upstream `path_provider 2.1.5 ->
path_provider_foundation: ^2.3.2` constraint, so no other override is
needed. We pin it exactly (no caret) so a future `2.5.2` re-introducing
the dep won't sneak back in.

After the pin:

* `flutter pub get` resolves cleanly. `objective_c`, `code_assets`,
  `hooks`, `native_toolchain_c`, and `record_use` all drop out of the
  package graph.
* `flutter pub run build_runner build --delete-conflicting-outputs`
  succeeds on Windows without `--enable-experiment=native-assets`.
* `local_auth` and `sentry_flutter` are restored to the regular
  `dependencies` block; neither pulls `path_provider_foundation`
  themselves (sentry's `package_info_plus` chain is independent), so
  the pin is sufficient.

### Option C — pin `sentry_flutter` / `local_auth` to versions that don't pull `path_provider_foundation`

Not relevant — see chain above. Neither of those two packages is in
the offending transitive path. They were originally commented out as
a guess; removing them did **not** remove `objective_c` from the graph.

### Option D — bump Flutter SDK floor + ship the native-assets runbook

Not needed once Option B worked. Documented here in case Option B
regresses:

* Set `flutter: ">=3.41.9"` (or whatever stable has the upstream
  build_runner fix) in `pubspec.yaml`'s `environment:` block.
* Tell Windows-host devs to run codegen with
  `flutter pub run build_runner build --delete-conflicting-outputs --enable-experiment=native-assets`,
  and pre-warm `pub deps --json > /tmp/deps.json` if the parser still
  crashes (the second-call workaround).
* Track <https://github.com/dart-lang/build> for the
  `NativeAssetsBuildPlanner.fromPubDepsJsonString` fix.

## The fix that worked

```yaml
# pubspec.yaml
dependency_overrides:
  analyzer_plugin: ^0.13.4       # (pre-existing; unrelated)
  path_provider_foundation: 2.5.1
```

`local_auth: ^2.3.0` and `sentry_flutter: ^8.14.2` are back in the
regular `dependencies` block.

## Cross-platform notes

* **macOS / iOS dev hosts**: `path_provider_foundation 2.5.1` provides
  the same Foundation-backed `path_provider` implementation as 2.6.0.
  The only thing it lacks is the `objective_c` FFI bridge that was
  added in 2.5.0 / 2.6.0 — `path_provider` itself doesn't call into
  that bridge yet (it's wiring for future direct-FFI replacements of
  the platform channel). So macOS and iOS builds resolve identically;
  paths still work, `getApplicationDocumentsDirectory` etc. still
  return the same values. Verified by checking the 2.5.1 plugin
  source: same `PathProviderPlugin.m`, no behavioural change vs 2.4.4
  / 2.6.0.
* **Linux dev hosts**: not affected — `path_provider_foundation`
  is iOS/macOS-only at the plugin layer, but pub still pulls the
  Dart bits into the graph. The pin is a no-op for the runtime
  behaviour and just keeps `objective_c` out of the solver. Linux
  codegen was not the problem path; the build_runner JSON crash was
  observed on Windows only.
* **CI**: GitHub Actions runners reproduce both the Windows crash
  and the Linux/macOS clean run. Pin holds on all three.

## "If this breaks again" runbook

Future maintainer, in priority order:

1. **First sanity check.** `flutter pub deps --json | jq '.packages[] | select(.name=="objective_c")'`.
   If `objective_c` is back, find its new parent:
   `flutter pub deps --json | jq -r '.packages[] | select(.dependencies | contains(["objective_c"])) | .name'`.

2. **`path_provider_foundation` regression.** If the parent is back
   to `path_provider_foundation`, check pub.dev for newer releases
   that have dropped the `objective_c` dep again (history shows the
   maintainers have flipped this dep on and off — 2.5.0 had it, 2.5.1
   removed it, 2.6.0 brought it back). Bump the override accordingly.

3. **New parent.** If a different package pulled `objective_c` in
   (sentry → package_info_plus, mobile_scanner, record, etc.), check
   that package's release notes; the same fix pattern applies — pin
   one notch below the version that added the dep.

4. **build_runner side.** If `objective_c` is genuinely required (it
   shouldn't be on Windows for any of our deps), the alternative is to
   wait for `build_runner` to ship a release that handles the
   native-assets package graph cleanly. Track <https://pub.dev/packages/build_runner/versions>
   and look for a release that fixes
   `NativeAssetsBuildPlanner.fromPubDepsJsonString`. Test by removing
   the override and running:

   ```
   flutter pub upgrade
   flutter pub run build_runner build --delete-conflicting-outputs --enable-experiment=native-assets
   ```

5. **Last resort — Option D.** Bump Flutter SDK floor in `pubspec.yaml`
   `environment:` block and document the `--enable-experiment=native-assets`
   incantation in this file's "What you need to run codegen" section. Be
   loud about it in the PR — Windows-host devs need to know.

## What you need to run codegen (current state)

```powershell
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
```

No experiment flags. No special env vars. If that stops working, you're
back at step 1 above.

## Related files

* `mobile/pubspec.yaml` — the override lives here.
* `mobile/pubspec.lock` — regenerate after any override change.
* `mobile/AGENTS.md` — dependency baseline; keep the list in this doc
  in sync.
