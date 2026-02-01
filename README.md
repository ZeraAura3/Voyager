# Voyager 🚗

A student ride-sharing platform built with Flutter, designed to connect students who need rides with those offering them.

## Overview

Voyager is a comprehensive ride-sharing application that enables students to:
- Request rides from their community
- Offer rides to fellow students
- Access cab services for convenient transportation
- Manage ride requests and bookings

## Features

- **Authentication System**: Secure user registration and login with Firebase Authentication
- **Ride Management**: Post and request rides with detailed information
- **Cab Services**: Access to cab booking services
- **User Profiles**: Manage personal information and preferences
- **Dark/Light Theme**: Toggle between themes for personalized experience
- **Real-time Updates**: Firebase Firestore integration for live data synchronization

## Tech Stack

- **Framework**: Flutter (SDK 3.0.0+)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Platforms Supported**: Android, iOS, Web, Windows, Linux, macOS

## Project Structure

```
lib/
├── main.dart                      # Application entry point
├── models/
│   └── user_model.dart           # User data model
├── screens/
│   ├── login_screen.dart         # User authentication
│   ├── signup_screen.dart        # User registration
│   ├── home_screen.dart          # Main dashboard
│   ├── post_ride_screen.dart     # Create ride offers
│   ├── requests_screen.dart      # View ride requests
│   └── cab_services_screen.dart  # Cab booking interface
└── theme/
    ├── app_theme.dart            # Theme definitions
    └── theme_provider.dart       # Theme state management
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Firebase account
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd voyager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your app to the Firebase project (Android/iOS/Web)
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Enable Authentication and Firestore in Firebase Console

4. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

**Windows:**
```bash
flutter build windows --release
```

## Dependencies

- `firebase_core: ^4.4.0` - Firebase core functionality
- `firebase_auth: ^6.1.4` - User authentication
- `cloud_firestore: ^6.1.2` - Real-time database
- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Local data persistence
- `cupertino_icons: ^1.0.8` - iOS style icons

## Configuration

The app uses Firebase for backend services. Ensure you have:
1. Valid `google-services.json` in the Android app directory
2. Valid `GoogleService-Info.plist` in the iOS Runner directory
3. Firebase Authentication enabled
4. Cloud Firestore database created

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is private and not published to pub.dev.

## Support

For support, please open an issue in the repository or contact the development team.

---

Built with ❤️ using Flutter
