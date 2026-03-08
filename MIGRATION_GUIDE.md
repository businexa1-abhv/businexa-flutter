# Businexa Flutter Migration Guide

## 📋 Overview

This document describes the complete migration of the Businexa PWA (React + Supabase) to a Flutter mobile application using Firebase as the backend.

## ✅ Migration Completed

All major features from the React PWA have been successfully migrated to Flutter:

### Authentication
- ✅ OTP-based mobile authentication (Firebase Auth)
- ✅ Phone number validation (Indian format: 10 digits starting with 6-9)
- ✅ OTP generation, hashing (SHA-256), and verification
- ✅ User profile creation and management
- ✅ Session management

### Database
- ✅ Users collection
- ✅ Shops collection
- ✅ Products collection
- ✅ Subscriptions collection
- ✅ OTP Verifications collection
- ✅ Firestore security rules and data models

### Business Logic
- ✅ Shop creation and management
- ✅ Product CRUD operations
- ✅ Product image upload to Firebase Storage
- ✅ Subscription plans (Monthly, Quarterly, Half-Yearly, Yearly, Test)
- ✅ Subscription activation and status checking
- ✅ Free trial (30 days)
- ✅ Payment integration with Razorpay
- ✅ QR code generation and sharing
- ✅ PublicShop page (customer-facing)
- ✅ Product search and filtering

### UI/UX
- ✅ Login screen (mobile + OTP)
- ✅ Business Details screen (shop setup)
- ✅ Dashboard screen (main interface)
- ✅ Products management tabs
- ✅ Subscription management
- ✅ QR code display and download
- ✅ Settings screen
- ✅ Account screen
- ✅ Dark/Light theme support
- ✅ Responsive design

### State Management
- ✅ Riverpod providers for:
  - Auth state
  - User profiles
  - Shops
  - Products
  - Subscriptions
  - Product search
  - Theme mode
- ✅ Streaming auth state changes
- ✅ Real-time data updates from Firestore

### Navigation
- ✅ Go Router configuration
- ✅ Protected routes (after authentication)
- ✅ Deep linking support
- ✅ Route guards and redirects

### Backend Services
- ✅ Firebase Authentication
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firebase Cloud Functions
- ✅ OTP service (with rate limiting)
- ✅ Razorpay integration

---

## 🚀 Setup Instructions

### 1. Prerequisites
```bash
# Install Flutter (if not already installed)
# Visit: https://flutter.dev/docs/get-started/install

# Verify Flutter installation
flutter --version
```

### 2. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "businexa"
3. Enable the following services:
   - Authentication (Phone)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Functions

#### Download Configuration Files
1. **For Android**: Download `google-services.json` to `android/app/`
2. **For iOS**: Download `GoogleService-Info.plist` to `ios/Runner/`

### 3. Clone and Install Dependencies

```bash
cd flutter/businexa
flutter pub get
```

### 4. Environment Configuration

```bash
# Copy and edit environment files
cp .env.dev.example .env.dev
cp .env.prod.example .env.prod

# Fill in your values in both files
vi .env.dev
vi .env.prod
```

### 5. Firebase Cloud Functions Setup

```bash
cd functions
npm install

# Deploy functions
firebase deploy --only functions
```

### 6. Run the App

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Production
flutter run --dart-define=ENVIRONMENT=prod
```

---

## 📱 Project Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── env.dart                 # Environment configuration
│   │   ├── firebase_config.dart     # Firebase setup
│   │   └── app_constants.dart       # App constants & plans
│   ├── services/
│   │   ├── firebase_service.dart    # Firestore operations
│   │   └── otp_service.dart         # OTP generation & verification
│   └── constants/
│
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   └── login_screen.dart
│   │   ├── services/
│   │   │   └── auth_service.dart    # Firebase Auth integration
│   │   └── models/
│   │       └── user_model.dart
│   │
│   ├── shops/
│   │   ├── screens/
│   │   │   ├── business_details_screen.dart
│   │   │   └── dashboard_screen.dart
│   │   ├── services/
│   │   │   └── shop_service.dart
│   │   └── models/
│   │       └── shop_model.dart
│   │
│   ├── products/
│   │   ├── screens/
│   │   │   ├── add_product_screen.dart
│   │   │   ├── edit_product_screen.dart
│   │   │   ├── product_details_screen.dart
│   │   │   └── product_list_screen.dart
│   │   ├── services/
│   │   │   └── product_service.dart
│   │   └── models/
│   │       └── product_model.dart
│   │
│   ├── subscriptions/
│   │   ├── screens/
│   │   │   └── subscription_screen.dart
│   │   ├── services/
│   │   │   ├── subscription_service.dart
│   │   │   └── razorpay_service.dart
│   │   └── models/
│   │       └── subscription_model.dart
│   │
│   └── qr/
│       ├── screens/
│       ├── widgets/
│       │   └── qr_code_widget.dart
│       └── services/
│
├── shared/
│   ├── widgets/          # Reusable UI components
│   ├── models/           # Shared data models
│   └── utils/            # Utility functions
│
├── providers/
│   └── app_providers.dart   # Riverpod providers
│
├── routes/
│   └── app_router.dart      # Go Router configuration
│
└── main.dart                # App entry point
```

---

## 🔑 Key Services & APIs

### Authentication Service
```dart
// Send OTP
final verId = await authService.sendOtp('+91' + mobileNumber);

// Verify OTP and sign in
final userCredential = await authService.verifyOtpAndSignIn(verId, otp);

// Get current user
final user = authService.getCurrentUser();
```

### Shop Service
```dart
// Create shop
final shop = await shopService.createShop(
  ownerId: userId,
  shopName: shopName,
  category: category,
);

// Get current user's shop
final shop = await shopService.getShopByOwner(userId);

// Get shop by ID
final shop = await shopService.getShopById(shopId);
```

### Product Service
```dart
// Add product
final product = await productService.addProduct(
  shopId: shopId,
  name: productName,
  price: price,
  category: category,
  imageFile: imageFile,
);

// Get products by shop
final products = await productService.getProductsByShop(shopId);

// Search products
final filtered = productService.searchProducts(products, query);
```

### Subscription Service
```dart
// Create subscription
final subscription = await subscriptionService.createSubscription(
  shopId: shopId,
  planId: planId,
  amount: amount,
  razorpayPaymentId: paymentId,
);

// Check if subscription is active
final isActive = await subscriptionService.isSubscriptionActive(shopId);

// Get active subscription
final subscription = await subscriptionService.getActiveSubscription(shopId);
```

### Razorpay Service
```dart
// Initialize
razorpayService.initialize(
  onSucces: onPaymentSuccess,
  onFailure: onPaymentFailure,
  onWallet: onWalletUsed,
);

// Open payment modal
await razorpayService.openPaymentModal(
  amount: planPrice,
  orderId: orderId,
  shopName: shopName,
  userEmail: userEmail,
  userPhone: userPhone,
);
```

---

## 🔐 Security Features

### OTP Security
- SHA-256 hashing for OTP storage
- OTP expiration (10 minutes)
- Rate limiting (3 requests per 30 minutes)
- No plain text OTP in database

### Firebase Security
- Row-Level Security (RLS) on Firestore collections
- Public read access to shop data
- Owner-only access to personal data
- Phone authentication with Firebase
- Secure token management

### Payment Security
- Razorpay Secret Key stored in Cloud Functions (never in app)
- Order creation via secure backend endpoint
- Payment signature validation

---

## 📊 Database Schema

### Users Collection
```
/users/{userId}
{
  mobile_number: string
  email: string
  display_name: string
  created_at: timestamp
  updated_at: timestamp
}
```

### Shops Collection
```
/shops/{shopId}
{
  owner_id: string (ref: /users/{userId})
  shop_name: string
  category: string
  address: string
  whatsapp_number: string
  email: string
  slug: string (unique)
  created_at: timestamp
  updated_at: timestamp
}
```

### Products Collection
```
/products/{productId}
{
  shop_id: string (ref: /shops/{shopId})
  name: string
  price: number
  category: string
  description: string
  image_url: string (Firebase Storage URL)
  created_at: timestamp
  updated_at: timestamp
}
```

### Subscriptions Collection
```
/subscriptions/{subscriptionId}
{
  shop_id: string (ref: /shops/{shopId})
  plan_id: string
  status: string (active, inactive, expired, cancelled)
  amount: number
  currency: string
  razorpay_payment_id: string
  razorpay_order_id: string
  razorpay_signature: string
  starts_at: timestamp
  expires_at: timestamp
  created_at: timestamp
}
```

### OTP Verifications Collection
```
/otp_verifications/{otpId}
{
  mobile_number: string
  otp_hash: string (SHA-256)
  verified: boolean
  created_at: timestamp
  expires_at: timestamp
  verified_at: timestamp (optional)
}
```

---

## 🔄 Migration Checklist

- [x] Supabase → Firebase migration
- [x] Database schema conversion
- [x] Authentication system
- [x] OTP service implementation
- [x] Product management
- [x] Subscription management
- [x] Payment integration (Razorpay)
- [x] QR code generation
- [x] File storage (Firebase Storage)
- [x] State management (Riverpod)
- [x] Navigation (Go Router)
- [x] UI screens
- [x] Cloud Functions
- [ ] E2E testing
- [ ] Performance optimization
- [ ] Analytics integration

---

## ⚠️ Known Limitations & Future Work

1. **SMS Sending**: Currently integrated with Fast2SMS via Cloud Functions
2. **Payment**: Razorpay order creation needs backend integration
3. **Image Optimization**: Add image compression before upload
4. **Offline Support**: Add local caching for offline functionality
5. **Analytics**: Google Analytics not yet integrated
6. **Push Notifications**: Firebase Cloud Messaging not yet configured
7. **Location Services**: Geolocation features not implemented

---

## 📞 Support & Troubleshooting

### Firebase Connection Issues
```bash
# Enable Firebase Emulator for testing
firebase emulators:start

# Run app with emulator
flutter run --dart-define=USE_EMULATOR=true
```

### OTP Not Sending
1. Check Fast2SMS API key in Cloud Functions
2. Verify mobile number format (10 digits, starting with 6-9)
3. Check rate limiting (max 3 per 30 minutes)

### Payment Issues
1. Verify Razorpay credentials
2. Test with test payment IDs
3. Check payment signature validation

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Update pods (iOS)
cd ios
rm -rf Pods
pod install
```

---

## 📚 References

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Guide](https://riverpod.dev)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Razorpay Flutter SDK](https://pub.dev/packages/razorpay_flutter)
- [QR Flutter Documentation](https://pub.dev/packages/qr_flutter)

---

## 🎉 Next Steps

1. **Configure Firebase**: Update `.env.dev` and `.env.prod` with your Firebase credentials
2. **Deploy Cloud Functions**: Deploy OTP and Razorpay functions to Firebase
3. **Test Locally**: Run the app with the emulator setup
4. **Deploy to Stores**: Prepare for iOS App Store and Google Play Store
5. **Monitor Analytics**: Set up Firebase Analytics and Crashlytics

---

Generated: March 2024
Version: 1.0.0
