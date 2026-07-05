# Plexus

A storefront demo app built with Flutter on top of [fakestoreapi.com](https://fakestoreapi.com). It covers login, a dashboard, a product catalog with search/filter/sort, product details, favorites, and an offline cache, with light and dark themes.

## Features

- Login against the real `POST /auth/login` endpoint, token kept in secure storage (Keychain / encrypted prefs)
- Session restore on app start, logout with confirmation
- Dashboard with profile greeting, store stats, category shortcuts and a top rated carousel
- Product grid with debounced search, category filter chips, sorting and pull-to-refresh
- Infinite scroll pagination (client-side, see assumptions below)
- Product details with hero image transition and a two-pane layout on wide screens
- Favorites persisted locally, usable fully offline
- Offline cache for the catalog: the last good API response is served when the network drops, with a "showing cached data" notice and an offline banner
- Shimmer loading placeholders, empty states and error states with retry
- Hero transition into product details, staggered entrance animations on grids and the dashboard
- Material 3 theming with system/light/dark mode, persisted across restarts
- Localization via ARB files: English, Bengali and Arabic shipped, with an in-app language picker (persisted). Arabic flips the whole layout RTL automatically
- Unit and widget tests for the auth flow and the caching repository
- GitHub Actions workflow: format check, analyze, tests, debug APK artifact

## Getting started

Prerequisites: Flutter stable (3.41+) with Dart 3.11+.

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Generated files (`*.freezed.dart`, `*.g.dart`, `lib/l10n/app_localizations*.dart`) are not committed, so the two generate steps are required after a fresh clone. If the IDE shows red before they run, that's why.

### Demo credentials

fakestoreapi only accepts its seeded users:

```
username: mor_2314
password: 83r5^_
```

There is a "Use demo account" button on the login screen that fills these in.

## Architecture

Layered, repository-pattern setup with Riverpod for state:

```
lib/
  core/           constants, theme, router, Dio client, errors, small utils
  domain/         entities (freezed) + repository interfaces, no Flutter imports
  data/           DTO models (freezed + json_serializable), remote APIs (Dio),
                  local stores (Hive, secure storage), repository implementations
  presentation/   screens, widgets, Riverpod providers/notifiers
```

Flow for any feature: a widget watches a provider, the notifier calls a repository interface from `domain/`, the implementation in `data/` talks to the API/cache and maps DTOs to entities. UI code never sees Dio, Hive or JSON.

A few decisions worth explaining:

- There are no use-case classes. Notifiers call repositories directly, since with one data source per feature the extra layer would be indirection for its own sake. The repository interfaces already keep the domain testable.
- Errors are typed. Everything thrown by the data layer is an `AppException` (network / unauthorized / api / unexpected), mapped in one place in the Dio wrapper. The UI translates them to localized messages.
- The offline strategy is remote first: always try the network, save the response to Hive, fall back to the cache on failure with a `fromCache` flag the UI surfaces. Favorites store full product snapshots so that tab works with no network at all.
- Auth state drives routing. go_router redirects based on the session provider: splash while restoring, login when signed out, the shell otherwise. The login screen never navigates manually.

## Assumptions and API quirks

- fakestoreapi has no offset pagination, no search and no server-side filtering. The catalog (20 items) is fetched once and search/filter/sort/pagination run client-side. The infinite scroll is real UI over chunked local data; with a real backend only the repository/notifier would change.
- The login token is a JWT whose `sub` claim is the user id. There is no "me" endpoint, so the profile shown on the dashboard is fetched from `/users/{id}` on a best-effort basis and the app works fine when that fails.
- Unknown product ids return `200` with an empty body, which the API layer converts to a 404-style error.
- The token is attached as a `Bearer` header to all requests. fakestoreapi ignores it, but the flow matches what a real backend would need.

## Tests

```bash
flutter test
```

Covered: session restore/login/logout state transitions (mocked repository), product repository cache fallback behaviour (mocked API + in-memory cache), and login form validation/submission/error rendering (widget test with a mocked repository).

## Languages

English, Bengali (`app_bn.arb`) and Arabic (`app_ar.arb`) ship out of the box. The picker lives in the dashboard app bar next to the theme menu, and the choice is stored in Hive; "System default" follows the device language. Arabic renders the whole app right-to-left through Flutter's built-in directionality.

To add another language: copy `lib/l10n/app_en.arb` to `app_<locale>.arb`, translate the values, run `flutter gen-l10n`, and add the language to the picker in `dashboard_page.dart`. The locale shows up automatically in `supportedLocales`.

## CI

`.github/workflows/ci.yml` runs on pushes to `main` and on PRs: pub get, codegen, `dart format` check, `flutter analyze`, `flutter test`, then builds and uploads a debug APK.
# plexus
