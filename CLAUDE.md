# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (`tmdb_movie_viewer`, Flutter 3.35.3 / Dart ^3.9.2) that lists TMDB popular movies, supports debounced search, and shows a detail screen. Built for the Snag frontend challenge; `submission/` holds the release APK and demo GIF.

## Commands

Generated `*.mapper.dart` files are **gitignored**, so code generation must run before anything compiles on a fresh checkout:

```shell
dart run build_runner build -d          # one-off (use `watch` while editing @MappableClass types)
```

The TMDB key is read at compile time via `String.fromEnvironment('TMDB_API_KEY')`, so it must be passed with `--dart-define` (a gitignored `.env` with `TMDB_API_KEY=...` exists locally and can be passed with `--dart-define-from-file=.env`):

```shell
flutter run --dart-define=TMDB_API_KEY=$KEY
flutter build apk --dart-define=TMDB_API_KEY=$KEY
flutter analyze
dart format .                            # page_width is 120 (analysis_options.yaml)
flutter test                             # unit/widget tests in test/
```

Integration tests use Patrol (requires the `patrol` CLI, see https://patrol.leancode.co/documentation). They hit the real TMDB API and a real device/emulator:

```shell
patrol test -t integration_test/scenarios_test.dart --dart-define=TMDB_API_KEY=$KEY   # all scenarios
patrol test -t integration_test/scenarios/view_movie_scenario_test.dart --dart-define=TMDB_API_KEY=$KEY   # single scenario
```

`integration_test/scenarios_test.dart` is just an aggregator that calls each scenario's `main()`. Patrol's native automation (airplane-mode toggling, permission dialogs) is only exercised on Android (`tester.isAndroid`). Patrol config (app name, package/bundle ids) lives in `pubspec.yaml` under `patrol:`.

Note: `test/widget_test.dart` is the stale template smoke test and pumps `MovieViewerApp` without a `ProviderScope`.

## Architecture

Single feature (`lib/src/features/movie_viewer/`) split into `domain/` → `data/` → `presentation/`, plus `lib/src/shared/` for cross-cutting code and `lib/src/app/` for wiring. Every directory exposes a barrel file (`shared.dart`, `domain.dart`, `presentation.dart`, `widgets.dart`, …); import through barrels and use **relative imports** (`prefer_relative_imports` lint is on).

**Data flow for a request** (read these together to understand a fetch end to end):

1. `shared/network/client.dart` — `DioNetworkClient` wraps Dio and returns `FutureExceptionOr<Response>` (= `Future<Either<Exception, T>>` from `either_dart`). Non-200 responses and `DioException`s are converted into `Left(Exception(message))`, surfacing TMDB's `status_message` when present. `processData()` then decodes the body **in an isolate via `compute`** and maps `TypeError`/`MapperException` to user-facing `Left`s.
2. `features/.../data/remote_movies_repository.dart` — implements `MoviesRepository` (declared in `domain/repository/`). Builds query params from a `*QueryParamsDto.toMap()`, appends `api_key`, strips nulls. Endpoints are in `shared/network/api_config.dart`.
3. `features/.../presentation/application/<feature>/vm.dart` + `state.dart` — Riverpod `Notifier`s (`popularMoviesVm`, `searchMoviesVm`, both `autoDispose`). State objects are `@MappableClass` so `copyWith` is generated. VMs `fold` the `Either` into `UiState`.
4. Screens in `presentation/screens/` watch the VM and render via `UiState.whenData`.

**`UiState<T>`** (`shared/ui_state.dart`) is the sealed loading/success/failure/uninitialised type used everywhere instead of `AsyncValue`. `Loading` and `Failure` can carry the previous data so lists stay visible during pagination/refresh; use the `loading()` / `success()` / `error()` extension methods on an existing state to preserve that data. `displayError()` shows a SnackBar through the global navigator key in `MovieViewerRouter`.

**DTOs** use `dart_mappable` (`@MappableClass`, often `caseStyle: CaseStyle.snakeCase` to match TMDB JSON). Adding/changing fields requires rerunning build_runner. `MovieResponseDto` is passed directly as a route argument to the detail screen (no separate domain entity).

**Routing** is plain `MaterialApp` named routes in `app/router.dart` (`MovieViewerRoutes` constants + `MovieViewerRouter` singleton with `onGenerateRoute`). Detail route asserts its argument is a `MovieResponseDto`.

**Search** uses Material `SearchAnchor` whose `suggestionsBuilder` calls the VM's `search` through `shared/debouncer.dart` (500 ms). A `null` return from the debounced call means "cancelled, keep last results".

**Pagination** is driven by `ScrollControllerX.isAtEndOfList` (`shared/extensions.dart`); `PopularMoviesViewModel.fetchNextMovies` guards on `page >= maxPages` and on an in-flight `Loading` state.

**Connectivity** — `ConnectivityService` (singleton, `connectivity_plus` + DNS lookup of `example.com`) is initialised in `MovieViewerApp`; `ConnectivityOverlay` wraps the `MaterialApp` and shows a full-screen "No Internet" overlay keyed by `noConnectionWidgetKey`, which the Patrol test asserts on.

## Integration test conventions

- Tests pump `ProviderScope(child: MovieViewerApp())` directly and are written Given/When/Then style.
- `integration_test/common.dart` adds `PatrolFinder.safeExists()` (bool instead of throwing on timeout) and `PatrolTester.progressAnimationSafely()` to work around `pumpAndSettle` timing out on the skeleton shimmer.
- List items are keyed `Key('movie$index')`; tests pick a random index to tap.

## Gherkin / Marionette tooling

The `gherkin` skill (`.agents/skills/gherkin/`) records manual flows as Gherkin features, replays them through Marionette, and generates Patrol tests. Project facts live in `gherkin/config.yaml` (environment `local`, define file `.env`, default device = iPhone simulator ID, MCP host Claude Code via `.mcp.json`).

- `gherkin/features/*.feature` are authoritative; generated `integration_test/<feature>_test.dart` files are committed derived artifacts (`check-generated` verifies they are in sync). `integration_test/analysis_options.yaml` relaxes `prefer_const_constructors` because the generator emits non-const finders.
- `lib/main.dart` calls `initializeGherkinBinding()` first (claims `MarionetteBinding` only for `--dart-define=INTEGRATION_TEST=true` non-release runs) and wraps the root in `GherkinRecordingHarness` only when `GHERKIN_RECORD=true`. `createApp()` in `lib/src/app/app.dart` is the binding-free root used by `main()` and by `gherkin/support/patrol_bootstrap.dart`; Patrol tests must pump that, never call `main()`.
- Helper CLI runs from the skill's `scripts/` dir: `dart run bin/gherkin.dart <doctor|validate|launch|run-cli|generate-patrol|check-generated> --root <project-root>`. `gherkin/evidence/` (screenshots, launch logs) is gitignored; launch logs include the app's own Dio request logging, which prints the TMDB `api_key` query parameter.
