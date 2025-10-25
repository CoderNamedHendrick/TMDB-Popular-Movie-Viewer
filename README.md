# 🏗️ Snag Frontend Interview Task

> [!NOTE]
> Project runs on flutter version 3.35.3

### 📚 Description

Snag frontend development challenge. Fetching popular movies using TMDB's most popular movies
API.

### 🚧 Run/build application

To run this application, a TMDB_API_KEY to the flutter environment via dart-define. The following
command runs the application.

```shell
flutter run --dart-define=TMDB_API_KEY=#apiKey
```

### 🚧 Run test

Like running the application, running integration tests works with the following command

```shell
flutter test --dart-define=TMDB_API_KEY=#apiKey integration_test/scenarios_test.dart
```