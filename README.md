# Infinite Image Gallery

A production-style Flutter image gallery that consumes the [Pixabay API](https://pixabay.com/api/docs/), supports infinite scrolling, an image detail view, downloads to the device gallery and locally persisted favourites.

Built with **Clean Architecture** and **Cubit (flutter_bloc)** for the *Gnxtace Technologies – Flutter Developer Assessment*.

---

## 1. Features

### Core requirements

| Requirement | Implementation |
| --- | --- |
| Gallery home screen – responsive grid | `GalleryScreen` with a responsive **masonry** grid (2/3/4/5 columns by width) |
| Infinite scroll / pagination | `NotificationListener` triggers `GalleryCubit.loadMore()` near the bottom; duplicates are de-duplicated by id |
| Loading states | Shimmer skeleton grid on first load, footer spinner while loading more |
| Error handling | Typed `Failure`s → dedicated error views with retry (initial) and inline "Load more" retry |
| Image detail screen | `ImageDetailScreen` with large image, tags, stats and actions |
| Description requirement | Tags surfaced as the image description (chips + sentence) plus view/like/download/comment stats and photographer |
| Download image | Dio download with `onReceiveProgress` → saved to the device photo gallery via `gal` |
| Favourites | Optimistic toggle, persisted in `SharedPreferences` (full payload → works offline) |
| Favourites screen | Dedicated tab, masonry grid + empty state |
| Image performance | `cached_network_image` (memory + disk cache), responsive image URLs, `context.select` for granular rebuilds, `const` widgets |

### Bonus features

- Search (debounced, 400 ms)
- Pull-to-refresh
- Category filters (Pixabay categories)
- Masonry grid
- Hero animations (grid → detail)
- Light & dark themes (`ThemeMode.system`)
- Sharing (URL + attribution via `share_plus`)
- Download progress UI + retry
- Unit + widget tests (41 tests)

---

## 2. add api key  

create .env file in global and add below line
PIXABAY_API_KEY=57909322-5628e5872ee70938e1394e4e6

---

## 3. Tech stack

- **Flutter** 3.44.x / **Dart** 3.12
- **flutter_bloc** + **equatable** – state management
- **dio** – HTTP client (timeouts, download progress, error mapping)
- **get_it** – dependency injection
- **shared_preferences** – local favourites persistence
- **cached_network_image** – image loading/caching
- **flutter_staggered_grid_view** – masonry grid
- **shimmer** – skeletons
- **gal** – save images to the device photo gallery (handles platform permissions)
- **share_plus** – sharing
- **path_provider** – temp download directory

---

## 4. Architecture

The app follows **Clean Architecture** with a one-way dependency rule
(`presentation → domain ← data`). The domain layer has no knowledge of Flutter, Dio or plugins.

```
lib/
├── main.dart                     # bootstraps DI then runs App
├── app.dart                      # MaterialApp, themes, HomeShell
├── core/                         # cross-cutting concerns
│   ├── config/                   # AppEnv (API key), AppConstants, categories
│   ├── di/                       # get_it service locator
│   ├── error/                    # Failure, AppException, Result<T>
│   ├── theme/                    # Material 3 light/dark themes
│   ├── usecase/                  # UseCase base contract
│   └── utils/                    # Debouncer, Formatters
├── domain/                       # business rules (pure Dart)
│   ├── entities/                 # GalleryImage, PagedImages
│   ├── repositories/             # abstract contracts
│   └── usecases/                 # GetImages, GetFavorites, ToggleFavorite, DownloadImage
├── data/                         # implementations of domain contracts
│   ├── datasources/
│   │   ├── remote/               # PixabayApiService (Dio)
│   │   └── local/                # FavoritesLocalDataSource, ImageDownloadDataSource
│   ├── models/                   # PixabayImageModel, PixabayResponseModel
│   └── repositories/             # *RepositoryImpl (Exception → Failure mapping)
└── presentation/                 # Flutter UI
    ├── bloc/                     # GalleryCubit, FavoritesCubit, ImageDetailCubit
    ├── screens/                  # HomeShell, Gallery, Favorites, Detail
    └── widgets/                  # Tile, ShimmerGrid, ErrorRetryView, EmptyView
```

### State management

Three focused cubits (`presentation/bloc`), each with an `Equatable` state:

- **`GalleryCubit`** – owns the paged list. Emits `loading → loaded`, `loadingMore`, `failedInitial`, and keeps a `loadMoreError` without dropping already loaded images. Search is debounced internally; `Debouncer` is disposed on `close()`.
- **`FavoritesCubit`** – the **single source of truth** for favourites. Shared between the gallery grid, the favourites tab and the detail screen so a heart toggled anywhere updates everywhere. Updates are optimistic and reverted on persistence failure.
- **`ImageDetailCubit`** – owns the download state machine (`idle → downloading(progress) → success/failure`).

Widgets read only what they need (`context.select`) to minimise rebuilds.

### Error strategy

- Data sources throw typed `AppException`s (`RemoteException`, `CacheException`, `PermissionException`, `DownloadException`).
- Repositories translate them into a sealed `Failure` hierarchy wrapped in `Result<T>` (`Success` / `FailureResult`) — no exception ever reaches the UI.
- Cubits pattern-match the `Result` and expose a presentation-safe message.

---

## 5. API key configuration

The Pixabay API key is **never committed**. It is injected at build/run time through `--dart-define`:

```bash
flutter run --dart-define=PIXABAY_API_KEY=YOUR_KEY_HERE
```

or 

create .env file in global and add below line
PIXABAY_API_KEY=57909322-5628e5872ee70938e1394e4e6


Build a release APK the same way:

```bash
flutter build apk --release --dart-define=PIXABAY_API_KEY=YOUR_KEY_HERE
```

Get a free key at <https://pixabay.com/api/docs/> (an account is required).

> If the key is missing or empty the repository returns a friendly
> `MissingApiKeyFailure` and the gallery shows "Missing Pixabay API key…".
> The base URL can also be overridden with `--dart-define=PIXABAY_BASE_URL=...`.

**VS Code** – `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "image_gallery",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=PIXABAY_API_KEY=YOUR_KEY_HERE"]
    }
  ]
}
```

**Android Studio / IntelliJ** – add `--dart-define=PIXABAY_API_KEY=YOUR_KEY_HERE` to the run configuration's *Additional run args*.

---

## 6. Setup & run

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on a connected device / emulator (mobile only)
flutter run --dart-define=PIXABAY_API_KEY=YOUR_KEY_HERE

# 3. Release APK
flutter build apk --release --dart-define=PIXABAY_API_KEY=YOUR_KEY_HERE
```

Requires Flutter `>= 3.44` and Dart `>= 3.12`.

### Platform permissions

- **Android** – `INTERNET` plus `WRITE_EXTERNAL_STORAGE` (`maxSdkVersion=28`) for saving on Android 9 and below. Android 10+ uses scoped storage, no permission required.
- **iOS** – `NSPhotoLibraryAddUsageDescription` / `NSPhotoLibraryUsageDescription` (already added to `Info.plist`).

---

## 7. Testing

```bash
flutter analyze          # 0 issues
flutter test             # 41 tests
```

Coverage includes:

- **Data** – model parsing/round-trip, repository success and `Failure` mapping (server / network / permission / missing key), favourites persistence and ordering.
- **Presentation (bloc)** – gallery initial load, pagination + de-duplication, debounced search, load-more failure, concurrency guard; favourites optimistic add/remove/revert; download progress/success/failure/concurrency.
- **Widget** – shimmer loading, initial error + retry, error view, and a full app-boot smoke test using mocked use cases (`get_it` + `mocktail`).

---

## 8. Assumptions & limitations

- **Description** – Pixabay does not expose a free-form description field; the image `tags` are used as the human-readable description (a documented, provider-compliant interpretation).
- Favourites are stored as a JSON payload in `SharedPreferences` (sufficient for this scale). For very large collections a database (`hive`/`sqflite`/`drift`) would be a better fit.
- Only `photo` results are requested (`image_type=photo`) with `safesearch=true`; Pixabay returns max 500 pages, after which `hasMore` naturally becomes false.
- Downloads save the `largeImageURL` (falls back to `webformatURL`) to the default gallery album.
- Sharing sends the image page URL + attribution rather than the binary (no local file dependency).
- The bundled `web/`, `windows/`, `macos/` and `linux/` folders are left in place but the app is **only configured/supported for Android and iOS**.

### Not done / possible next steps

- Retry/back-off for transient network errors, and an offline cache of the last successful gallery page.
- them is set for device theme only . no internal app theme is done 

---