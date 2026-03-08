# Businexa Flutter Migration - Complete Implementation Guide

## Project Overview
This document provides a comprehensive guide for the Flutter migration of Businexa PWA to a cross-platform mobile app (Android, iOS, Web) with Firestore backend.

## Architecture Overview

### Technology Stack
- **Frontend**: Flutter 3.0+
- **State Management**: Riverpod 2.5+
- **Routing**: go_router 14.0+
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Functions)
- **QR Codes**: qr_flutter 10.2+
- **Image Handling**: image_picker, cached_network_image
- **Payments**: Razorpay Flutter
- **OTP**: Custom SMS service with rate limiting

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
│
├── core/
│   ├── config/              # Configuration files
│   │   ├── firebase_config.dart
│   │   └── env.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── services/
│   │   ├── firebase_service.dart
│   │   └── otp_service.dart
│   └── utils/
│       └── validators.dart
│
├── features/
│   ├── auth/                # Authentication feature
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   └── auth_provider.dart
│   │
│   ├── shops/               # Shop management
│   │   ├── models/
│   │   │   └── shop_model.dart
│   │   ├── screens/
│   │   │   ├── business_details_screen.dart
│   │   │   └── dashboard_screen.dart
│   │   ├── services/
│   │   │   └── shop_service.dart
│   │   └── repositories/
│   │       └── shop_repository.dart
│   │
│   ├── products/            # Product management
│   │   ├── models/
│   │   │   └── product_model.dart
│   │   ├── screens/
│   │   │   ├── add_product_screen.dart
│   │   │   ├── edit_product_screen.dart
│   │   │   ├── product_details_screen.dart
│   │   │   └── public_shop_screen.dart
│   │   ├── services/
│   │   │   └── product_service.dart
│   │   └── repositories/
│   │       └── product_repository.dart
│   │
│   ├── subscriptions/       # Subscription management
│   │   ├── models/
│   │   │   └── subscription_model.dart
│   │   ├── screens/
│   │   │   └── subscription_screen.dart
│   │   ├── services/
│   │   │   └── subscription_service.dart
│   │   └── repositories/
│   │       └── subscription_repository.dart
│   │
│   ├── qr/                  # QR Code features
│   │   ├── screens/
│   │   │   └── qr_screen.dart
│   │   ├── services/
│   │   │   └── qr_service.dart
│   │   └── widgets/
│   │       └── qr_code_widget.dart
│   │
│   └── settings/            # Settings & Account
│       ├── screens/
│       │   ├── settings_screen.dart
│       │   └── account_screen.dart
│       └── services/
│           └── settings_service.dart
│
├── providers/
│   └── app_providers.dart    # Global Riverpod providers
│
├── routes/
│   └── app_router.dart      # go_router configuration
│
└── shared/
    ├── widgets/             # Reusable UI widgets
    │   ├── app_bar_widget.dart
    │   ├── bottom_nav_widget.dart
    │   ├── card_widget.dart
    │   └── button_widget.dart
    └── theme/
        └── app_theme.dart
```

## Database Schema - Firestore Collections

### users
```
users/{userId}
├── mobile_number: string (unique)
├── email: string
├── display_name: string
├── created_at: timestamp
├── updated_at: timestamp
└── is_verified: boolean
```

### shops
```
shops/{shopId}
├── owner_id: string (reference to users)
├── shop_name: string
├── category: string (electronics, fashion, food, etc.)
├── address: string
├── whatsapp_number: string
├── email: string
├── slug: string (unique, URL-friendly)
├── created_at: timestamp
├── updated_at: timestamp
└── is_active: boolean
```

### products
```
products/{productId}
├── shop_id: string (reference to shops)
├── name: string
├── description: string
├── price: number
├── category: string
├── image_url: string
├── created_at: timestamp
├── updated_at: timestamp
└── is_active: boolean
```

### subscriptions
```
subscriptions/{subscriptionId}
├── shop_id: string (reference to shops)
├── plan_id: string (monthly/quarterly/half_yearly/yearly)
├── status: string (active/inactive/expired)
├── price: number
├── start_date: timestamp
├── expiry_date: timestamp
├── created_at: timestamp
├── razorpay_subscription_id: string
└── razorpay_payment_id: string
```

### scans
```
scans/{scanId}
├── product_id: string (reference to products)
├── shop_id: string (reference to shops)
├── user_device_id: string
├── timestamp: timestamp
├── latitude: number (optional)
├── longitude: number (optional)
└── user_agent: string
```

### otp_verifications
```
otp_verifications/{otpId}
├── mobile_number: string
├── otp_hash: string (bcrypt-hashed)
├── expires_at: timestamp
├── verified: boolean
├── created_at: timestamp
└── deleted_at: timestamp (soft delete)
```

## Authentication Flow

### OTP-based Authentication
1. User enters mobile number
2. System checks rate limiting (max 3 OTPs in 30 mins)
3. OTP sent via SMS (via cloud function)
4. User verifies OTP
5. Firebase Auth account created with deterministic email/password
6. User profile created in Firestore

### Session Management
- Firebase Auth handles token management
- Tokens auto-refresh
- AuthProvider watches auth state changes
- Redirect based on auth status

## Key Features Implementation

### 1. OTP Authentication
- Rate limiting: 3 OTPs per 30 minutes
- OTP validity: 10 minutes
- SMS via Twilio or AWS SNS
- Backup email verification

### 2. Shop Management
- Create shop with business details
- Unique URL slug generation
- WhatsApp integration for customer contact
- Shop categories

### 3. Product Management
- Add/Edit/Delete products
- Image upload to Firebase Storage
- Product categories
- Export/Import products (JSON/CSV)
- Pagination support

### 4. QR Code System
- Generate QR code linking to `/shop/{shopId}`
- Download QR as PNG
- Share via WhatsApp
- Copy link to clipboard

### 5. Subscription System
- Multiple plans: Monthly (₹99), Quarterly (₹279), Half-Yearly (₹499), Yearly (₹899)
- Razorpay integration
- Active subscription required for public product display
- Subscription status tracking

### 6. Public Shop Page
- Display shop info and products
- Infinite scroll pagination
- Product filtering by category
- WhatsApp CTA button
- QR scan tracking

### 7. Scan Tracking
- Track QR code scans
- Store device info, timestamp, location (if permitted)
- Analytics dashboard

## Supabase to Firebase Mapping

| Supabase | Firebase | Implementation |
|----------|----------|-----------------|
| Supabase Auth | Firebase Auth | `FirebaseAuth.instance` |
| Postgres DB | Firestore | `FirebaseFirestore.instance` |
| Storage | Cloud Storage | `FirebaseStorage.instance` |
| Realtime | Firestore Listeners | `.snapshots()` streams |
| Edge Functions | Cloud Functions | HTTP callable functions |

## API Integration Points

### Firebase Auth
```dart
// Login with custom auth
await FirebaseAuth.instance.signInWithPassword(email, password);

// Create account
await FirebaseAuth.instance.createUserWithEmailAndPassword(email, password);

// Sign out
await FirebaseAuth.instance.signOut();
```

### Firestore CRUD
```dart
// Create
await FirebaseFirestore.instance.collection('collection').add(data);

// Read
FirebaseFirestore.instance.collection('collection').doc(id).get();
FirebaseFirestore.instance.collection('collection').snapshots();

// Update
await FirebaseFirestore.instance.collection('collection').doc(id).update(data);

// Delete
await FirebaseFirestore.instance.collection('collection').doc(id).delete();
```

### Cloud Storage
```dart
// Upload
await FirebaseStorage.instance.ref('path/to/file').putFile(file);

// Download URL
final url = await FirebaseStorage.instance.ref('path/to/file').getDownloadURL();

// Delete
await FirebaseStorage.instance.ref('path/to/file').delete();
```

## State Management with Riverpod

### Provider Patterns

1. **FutureProvider** - One-time async operations
```dart
final userProvider = FutureProvider<UserModel?>((ref) async {
  return await userService.getCurrentUser();
});
```

2. **StreamProvider** - Real-time data streams
```dart
final userStreamProvider = StreamProvider<UserModel?>((ref) {
  return FirebaseAuth.instance.authStateChanges()
      .map((user) => user != null ? UserModel.fromFirebase(user) : null);
});
```

3. **StateNotifierProvider** - Mutable state
```dart
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
```

## Responsive Design Strategy

### Breakpoints
- **Mobile**: < 600dp
- **Tablet**: 600-1000dp
- **Desktop**: > 1000dp

### Layout Patterns
- Use `MediaQuery.of(context).size.width`
- Implement `LayoutBuilder` for responsive layouts
- Use `SingleChildScrollView` for overflow handling
- Adaptive navigation (bottom nav for mobile, drawer for tablet+)

## Testing Strategy

### Unit Tests
```dart
// Test business logic, models, utilities
test('UserModel.toFirestore', () {
  // ...
});
```

### Widget Tests
```dart
// Test UI components
testWidgets('Button renders correctly', (WidgetTester tester) {
  // ...
});
```

### Integration Tests
```dart
// Test complete user flows
testWidgets('Complete signup flow', (WidgetTester tester) {
  // ...
});
```

## Error Handling

### AppException
```dart
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});
}
```

### Error Mapping
```dart
String _getErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return _mapFirebaseAuthError(error.code);
  }
  return 'Unexpected error occurred';
}
```

## Build & Deployment

### Android
1. Update `android/app/build.gradle`
2. Configure signing keys
3. Build APK: `flutter build apk --release`
4. Build AAB: `flutter build appbundle --release`

### iOS
1. Update `ios/Runner.xcodeproj`
2. Configure provisioning profiles
3. Build IPA: `flutter build ios --release`

### Web
1. Configure Firebase hosting rules
2. Build web: `flutter build web --release`
3. Deploy: `firebase deploy`

## Environment Configuration

### .env.dev
```
FIREBASE_API_KEY=xxx
FIREBASE_AUTH_DOMAIN=xxx
FIREBASE_PROJECT_ID=xxx
FIREBASE_STORAGE_BUCKET=xxx
FIREBASE_MESSAGING_SENDER_ID=xxx
FIREBASE_APP_ID=xxx
```

### .env.prod
```
(same as dev with production values)
```

## Security Considerations

1. **Firestore Rules**: Restrict data access to authenticated users
2. **Storage Rules**: Validate file types and sizes
3. **API Keys**: Use separate keys for Android/iOS/Web
4. **Rate Limiting**: Implement in Cloud Functions
5. **OTP Security**: Hash OTPs, implement rate limiting
6. **Data Encryption**: Enable Firestore encryption at rest

## Performance Optimization

1. **Image Optimization**
   - Compress before upload
   - Use cached_network_image
   - Lazy load images

2. **Firestore Optimization**
   - Use pagination for lists
   - Limit document reads with `.where()` and `.orderBy()`
   - Use subcollections for large datasets

3. **Flutter Optimization**
   - Use `const` constructors
   - Implement `shouldRebuild()` in providers
   - Use `RepaintBoundary` for expensive widgets
   - Profile with DevTools

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Hot reload fails | Firebase init issue | Full app restart required |
| Firestore rules deny access | RLS not configured | Update rules in Firebase console |
| Image upload fails | Storage rules not set | Configure CORS and bucket rules |
| Payment fails | Razorpay keys wrong | Verify key/secret in console |
| Deep links not working | Route not configured | Add route in go_router |

## Next Steps

1. Configure Firebase project
2. Set up Firestore collections
3. Deploy security rules
4. Configure Cloud Functions for OTP/payments
5. Test complete authentication flow
6. Implement remaining screens
7. Set up CI/CD pipeline
8. Create app store listings
9. Launch beta testing
10. Production deployment

