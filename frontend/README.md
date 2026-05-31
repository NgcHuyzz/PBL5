# PBL5 Fruit Sorter App

Flutter frontend for the PBL5 fruit sorting/classification system.

## Run

```sh
flutter pub get
flutter run -d chrome
```

The default API base URL is the deployed backend:

```text
https://pbl5-backend-t23i.onrender.com/api
```

Override it for local development with `--dart-define`:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Verify

```sh
flutter analyze
flutter test
```
