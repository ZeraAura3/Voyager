# Voyager

Voyager is a Flutter app for student communities to coordinate travel, ride sharing, and ticket exchanges.

## Key features

- **Rides**: Post rides, browse availability, and book seats.
- **Requests & bookings**: Track ride requests and current bookings.
- **Trades (tickets)**: Create and browse trade posts (swap, buy, sell) with optional images.
- **Cab services**: Browse driver and cab listings.

## Tech stack

- **Flutter / Dart** (Dart SDK: `>=3.0.0 <4.0.0`)
- **Firebase**: Authentication + Firestore (profiles, role data)
- **Supabase**: Postgres + Storage (rides, trades, history, images)
- **State management**: `provider`
- **Localization**: Flutter gen-l10n (`lib/l10n`) + `intl`
- **Networking**: `http` (location search)

## Project structure (high level)

```
lib/
  main.dart
  config/
    supabase_config.dart
  l10n/
  models/
  screens/
    home_screen.dart
    login_screen.dart
    signup_screen.dart
    driver_home_screen.dart
  services/
  theme/
  utils/
  widgets/
```

## Getting started

### Prerequisites

- Flutter SDK installed
- A **Firebase project** (Auth + Firestore)
- A **Supabase project** (Database + Storage)

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Firebase setup

1. Create a Firebase project in the Firebase Console.
2. Enable **Email/Password** authentication.
3. Create or enable **Cloud Firestore**.
4. Add platform config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
5. Update Firebase options if needed:
   - `lib/firebase_options.dart` contains the `FirebaseOptions` used on app startup.
   - For Web, ensure the `web` config has a real `appId`.

### 3) Supabase setup

1. Create a Supabase project.
2. Run the SQL migration:
   - Open `supabase_migration.sql` (repo root)
   - Paste into Supabase Dashboard -> SQL Editor -> New query -> Run
3. Configure Supabase client keys:
   - Update `lib/config/supabase_config.dart` with your **Project URL** and **Anon key**.
4. Create a Storage bucket for ticket images:
   - Bucket name: `ticket-images`

> Note: The Supabase anon key is intended for client apps. Protect your data with RLS and policies.

### 4) Run the app

```bash
flutter run
```

## Testing and analysis

```bash
flutter test
flutter analyze
```

## Build targets

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

## APK output

```bash
flutter build apk --release
```

Output path:

- `build/app/outputs/flutter-apk/app-release.apk`

For distribution, prefer GitHub Releases instead of committing build artifacts.

## Localization

- ARB files live in `lib/l10n/`.
- Generated localization code is enabled via `flutter: generate: true` in `pubspec.yaml`.
- Supported locales are declared in `lib/main.dart`.

## Location search

Voyager uses the Nominatim (OpenStreetMap) API for location suggestions.

## Troubleshooting

- **"User data not found" after login**: the app expects a profile document in Firestore under `students/<uid>` or `drivers/<uid>`.
- **No rides or trades showing / errors on first load**: confirm you ran `supabase_migration.sql` and updated `lib/config/supabase_config.dart`.
- **Image upload fails**: create the `ticket-images` bucket and ensure Storage policies allow the intended access.

## Contributing

PRs are welcome. If you change data models, update both:

- `supabase_migration.sql`
- the corresponding Dart model/service code

## License

This project is not published to pub.dev.
