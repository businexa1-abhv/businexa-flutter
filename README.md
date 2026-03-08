# Businexa Flutter Application

Businexa is a comprehensive multi-platform QR-based advertisement platform built with Flutter.

## ✅ What's Completed

- **Models**: User, Advertisement, Shop, ScanEvent
- **Firebase Services**: Auth, Ad, Shop, Storage, Scan Tracking, User services
- **State Management**: Riverpod providers for all features
- **Routing**: GoRouter configuration with 15+ routes
- **Theme System**: Material Design 3 with dark mode support
- **Constants & Validators**: Form validation utilities
- **Documentation**: Comprehensive guides and implementation roadmap

## 🚀 Technology Stack

- Flutter 3.19+
- Firebase (Auth, Firestore, Storage)
- Riverpod 2.4+ (State Management)
- GoRouter (Navigation)
- qr_flutter (QR Code Generation)
- Razorpay (Payments)

## 📁 Project Structure

```
lib/
├── main.dart
├── models/                    # Data models
├── core/services/            # Firebase services
├── core/utils/               # Utilities & theme
├── config/router/            # GoRouter configuration
├── providers/                # Riverpod state management
└── features/                 # Feature modules (to be created)
```

## 🔧 Getting Started

1. **Install dependencies**: `flutter pub get`
2. **Configure Firebase**: Update `lib/firebase_options.dart`
3. **Run app**: `flutter run`

## 📚 Documentation

- **FLUTTER_IMPLEMENTATION_GUIDE.md**: Complete implementation roadmap
- **MIGRATION_QUICK_REFERENCE.md**: PWA to Flutter mapping
- **MIGRATION_CHECKLIST.md**: Detailed feature checklist

## 🎯 Key Features

✅ OTP-based authentication  
✅ Advertisement management  
✅ Image upload to Firebase Storage  
✅ QR code generation  
✅ Scan tracking  
✅ Subscription management  
✅ Dark mode support  
✅ WhatsApp integration  
✅ Public ad pages  

## 📱 Supported Platforms

- Android (via Flutter)
- iOS (via Flutter)
- Web (via Flutter Web)

## 🔐 Firebase Setup

Required services:
1. Authentication (Email/Password)
2. Cloud Firestore
3. Cloud Storage
4. Cloud Functions (for OTP SMS)

See Firebase Security Rules in documentation.

## 📊 Database Collections

- **users**: User profiles and subscription data
- **shops**: Business information
- **ads**: Advertisement listings
- **scans**: Scan events and tracking
- **otp_verifications**: OTP management
- **subscriptions**: Subscription records

## 🛠️ Development

### Run Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
dart format lib/
```

## 📈 Next Steps

1. Create UI screens (Login, Register, Dashboard, etc.)
2. Implement image picking and upload UI
3. Build QR code generation screen
4. Create public ad page
5. Implement subscription payment flow
6. Add analytics dashboard
7. Deploy to Firebase Hosting
8. Publish to App Stores

## 📝 PWA Feature Parity

All PWA features have been mapped to Flutter equivalents. See MIGRATION_CHECKLIST.md for detailed mapping.

**PWA → Flutter Mapping:**
- Supabase Auth → Firebase Auth
- Supabase DB → Cloud Firestore
- Supabase Storage → Firebase Storage
- Supabase Realtime → Firestore listeners
- React Components → Flutter Widgets

## 🚀 Build Commands

```bash
# Development
flutter run

# Android Release
flutter build apk --release

# iOS Release
flutter build ios --release

# Web Release
flutter build web --release
```

## ⚙️ Configuration Files

- **pubspec.yaml**: Dependencies
- **firebase_options.dart**: Firebase configuration
- **lib/core/utils/constants.dart**: App constants
- **lib/config/router/app_router.dart**: Route definitions
- **lib/core/utils/theme.dart**: Theme configuration

## 🔗 Important Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## 📞 Support

For questions or issues, refer to FLUTTER_IMPLEMENTATION_GUIDE.md or the PWA codebase for reference implementation.

---

**Status**: 🟢 Foundation Complete (Screens In Progress)  
**Last Updated**: March 2026
