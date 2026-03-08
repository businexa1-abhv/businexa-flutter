# Businexa Flutter - Firebase Setup & Deployment Guide

## Table of Contents
1. [Firebase Project Setup](#firebase-project-setup)
2. [Firestore Configuration](#firestore-configuration)
3. [Authentication Setup](#authentication-setup)
4. [Storage Configuration](#storage-configuration)
5. [Flutter Project Configuration](#flutter-project-configuration)
6. [Local Development Setup](#local-development-setup)
7. [Android Build & Deployment](#android-build--deployment)
8. [iOS Build & Deployment](#ios-build--deployment)
9. [Web Deployment](#web-deployment)
10. [Troubleshooting](#troubleshooting)

## Firebase Project Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project" or "Add project"
3. Enter project name: `businexa`
4. Accept terms and create project
5. Wait for project creation to complete

### Step 2: Register Apps

#### Register iOS App
1. Go to Project Settings → iOS apps
2. Click "Add app" → Select "iOS"
3. Enter Bundle ID: `com.businexa.businexa`
4. Enter App Store ID: (leave blank for now)
5. Download **GoogleService-Info.plist**
6. Place in `ios/Runner/GoogleService-Info.plist`

#### Register Android App
1. Go to Project Settings → Android apps
2. Click "Add app" → Select "Android"
3. Enter Package name: `com.businexa.businexa`
4. Enter SHA-1 fingerprint:
   - Run: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
   - Copy SHA-1 value
5. Download **google-services.json**
6. Place in `android/app/google-services.json`

#### Register Web App
1. Go to Project Settings → Web apps
2. Click "Add app" → Select "Web"
3. Enter app nickname: `Businexa Web`
4. Copy the Firebase config and update in Flutter

### Step 3: Enable Required Services

1. **Authentication**
   - Go to Build → Authentication
   - Click "Get started"
   - Enable "Phone" sign-in method
   - Add test phone numbers (for development)

2. **Firestore Database**
   - Go to Build → Firestore Database
   - Click "Create database"
   - Select location (us-east1 or closest to you)
   - Start in Test mode (update rules later)

3. **Cloud Storage**
   - Go to Build → Storage
   - Click "Get started"
   - Use default bucket location
   - Update security rules

## Firestore Configuration

### Create Collections

Use Firebase Console to create these collections:

1. **users** (Document ID: auto)
   - Fields: mobile_number, email, display_name, created_at, updated_at, is_verified

2. **shops** (Document ID: auto)
   - Fields: owner_id, shop_name, category, address, whatsapp_number, email, slug, created_at, updated_at, is_active

3. **products** (Document ID: auto)
   - Fields: shop_id, name, description, price, category, image_url, created_at, updated_at, is_active

4. **subscriptions** (Document ID: auto)
   - Fields: shop_id, plan_id, status, amount, currency, razorpay_payment_id, razorpay_order_id, razorpay_signature, starts_at, expires_at, created_at

5. **scans** (Document ID: auto)
   - Fields: product_id, shop_id, device_id, timestamp, latitude, longitude, user_agent

6. **otp_verifications** (Document ID: auto)
   - Fields: mobile_number, otp_hash, expires_at, verified, created_at

### Create Indexes

1. Go to Firestore → Indexes
2. Create composite index for products:
   - Collection: products
   - Fields: shop_id (Asc), category (Asc)

3. Create index for scans:
   - Collection: scans
   - Fields: shop_id (Asc), timestamp (Desc)

## Authentication Setup

### Phone Authentication

1. **For Production**:
   - Go to Authentication → Phone
   - Click "Setup phone numbers for testing" to add real numbers
   - Or keep test mode disabled for production

2. **For Testing**:
   - Go to Authentication → Phone
   - Click default settings
   - Click "Add testing phone numbers"
   - Add: +91 9876543210 and set OTP: 123456
   - Add: +91 9123456789 and set OTP: 654321

3. **Enable Restrict to whitelisted countries**:
   - Go to Phone authentication settings
   - Add countries to whitelist (India, etc.)
   - This improves security

### Custom Claims (Optional)

For admin functionality:
```javascript
// Cloud Function to set custom claims
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.setAdminClaim = functions.https.onCall((data, context) => {
  const userId = data.uid;
  return admin.auth().setCustomUserClaims(userId, {isAdmin: true})
    .then(() => ({success: true}));
});
```

## Storage Configuration

### Create Storage Buckets

1. **For Product Images**:
   - Bucket path: `/products/{userId}/{imageId}`
   - Access: Public (read), Authenticated users (write own)

2. **For QR Codes**:
   - Bucket path: `/qr-codes/{shopId}/{qrId}`
   - Access: Public (read), Authenticated users (write own)

### Storage Security Rules

Place this in Cloud Storage rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Products: can write, anyone can read
    match /products/{userId}/{allPaths=**} {
      allow write: if request.auth.uid == userId;
      allow read: if true;
      allow delete: if request.auth.uid == userId;
    }

    // QR Codes: can write, anyone can read
    match /qr-codes/{shopId}/{allPaths=**} {
      allow read: if true;
      allow write, delete: if request.auth != null;
    }
  }
}
```

## Flutter Project Configuration

### Update Firebase Config Files

1. **Copy GoogleService-Info.plist** (iOS)
   ```
   cp path/to/GoogleService-Info.plist ios/Runner/
   ```

2. **Copy google-services.json** (Android)
   ```
   cp path/to/google-services.json android/app/
   ```

3. **Update firebase_options.dart** (Web)
   - Get config from Firebase Console
   - Update the config values

### Configure Android Build

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.businexa.businexa"
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    // Firebase is auto-configured via google-services.json
}
```

### Configure iOS Build

Update `ios/Podfile`:

```ruby
platform :ios, '11.0'

target 'Runner' do
  flutter_root = File.expand_path(File.join(packages_path, '.symlinks', 'flutter'))
  load File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper')

  flutter_ios_podfile_setup

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_post_install(installer)
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
          '$(inherited)',
          'PERMISSION_CAMERA=1',
          'PERMISSION_PHOTOS=1',
        ]
      end
    end
  end
end
```

### Environment Configuration

Create `.env.dev` and `.env.prod`:

```env
.env.dev:
FIREBASE_API_KEY=xxx_dev
FIREBASE_AUTH_DOMAIN=businexa-dev.firebaseapp.com
FIREBASE_PROJECT_ID=businexa-dev
FIREBASE_STORAGE_BUCKET=businexa-dev.appspot.com
FIREBASE_MESSAGING_SENDER_ID=xxx
FIREBASE_APP_ID=xxx
RAZORPAY_KEY_ID=xxx_dev
RAZORPAY_KEY_SECRET=xxx_dev
APP_BASE_URL=http://localhost:3000

.env.prod:
FIREBASE_API_KEY=xxx_prod
FIREBASE_AUTH_DOMAIN=businexa.firebaseapp.com
FIREBASE_PROJECT_ID=businexa
FIREBASE_STORAGE_BUCKET=businexa.appspot.com
FIREBASE_MESSAGING_SENDER_ID=xxx
FIREBASE_APP_ID=xxx
RAZORPAY_KEY_ID=xxx_prod
RAZORPAY_KEY_SECRET=xxx_prod
APP_BASE_URL=https://businexa.com
```

## Local Development Setup

### Prerequisites

```bash
# Install Flutter
flutter --version

# Install dependencies
flutter pub get

# Verify setups
flutter doctor
```

### Run in Development

```bash
# Android Emulator (or connect physical device)
flutter devices
flutter run -d emulator-5554

# iOS Simulator
open -a Simulator
flutter run -d "iPhone 15 Pro"

# Web (Chrome)
flutter run -d chrome

# Web Debuging
flutter run -d web-server
# Then open: http://localhost:58663
```

### Development Testing

1. **Test Authentication**:
   - Use test phone numbers from Firebase
   - Verify OTP window works
   - Check user creation in Firestore

2. **Test Product Flow**:
   - Create product
   - Upload image
   - Verify in Storage and Firestore

3. **Test Public Shop**:
   - Navigate to `/shop/{slug}`
   - Verify products display
   - Check QR code generation

## Android Build & Deployment

### Local Build

```bash
# Create signing key
keytool -genkey -v -keystore ~/businexa-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias businexa-key

# Create android/key.properties
storeFile=/path/to/businexa-release-key.jks
storePassword=your_password
keyPassword=your_password
keyAlias=businexa-key

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### App Store Submission

1. **Create Google Play Account**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new project: "Businexa"
   - Pay registration fee ($25)

2. **Create App**:
   - App name: Businexa
   - Language: English
   - Category: Business
   - Audience: All ages (for QR code feature)

3. **Add Release**:
   - Go to Release → Production
   - Upload `app-release.aab`
   - Add release notes
   - Submit for review (2-3 days approval)

4. **Store Listing**:
   - Add screenshots (5-8 images)
   - Add description
   - Add privacy policy
   - Add terms of service
   - Add contact info

## iOS Build & Deployment

### Local Build

```bash
# Update version
# Edit pubspec.yaml: version: 1.0.0+1

# Build iOS app
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner → Edit Scheme
# 2. Set Build Configuration to Release
# 3. Product → Archive
# 4. Distribute App → App Store Connect
```

### App Store Submission

1. **Create Apple Developer Account**:
   - Go to [Apple Developer](https://developer.apple.com)
   - Create account or sign in
   - Enroll in Developer Program ($99/year)

2. **Create App on App Store Connect**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Click "My Apps" → "+"
   - Create new iOS app
   - Bundle ID: `com.businexa.businexa`
   - SKU: `businexa`

3. **Build & Upload**:
   - Build in Xcode (Product → Archive)
   - Upload to App Store Connect
   - Add app information:
     - Screenshots (5-8 per screen)
     - Description
     - Keywords
     - Category
     - Age rating

4. **Submit for Review**:
   - Complete TestFlight testing (internal testers)
   - Upload to App Store (external testers)
   - Submit for review
   - Wait for approval (5-7 days)

### TestFlight Testing

```bash
# Build for TestFlight
flutter build ios --release

# In Xcode:
# 1. Organizer → Archives
# 2. Select your build
# 3. Validate app
# 4. Distribute app → TestFlight
# 5. Add internal/external testers
```

## Web Deployment

### Build Web Version

```bash
# Build web version
flutter build web --release

# Output in: build/web/

# Create web/index.html if needed (already exists)
```

### Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project root
firebase init

# Select Hosting when prompted
# Choose: build/web as public directory

# Deploy
firebase deploy

# View at: https://businexa.firebaseapp.com
```

### Configure Custom Domain

1. Go to Firebase Console → Hosting
2. Add custom domain: `businexa.com`
3. Verify DNS records
4. Enable automatic SSL/TLS
5. Update A records to point to Firebase

### Web-Specific Considerations

```dart
// In firebase_options.dart for web:
const FirebaseOptions(
  apiKey: 'your-api-key',
  authDomain: 'businexa.firebaseapp.com',
  projectId: 'businexa',
  storageBucket: 'businexa.appspot.com',
  messagingSenderId: 'xxx',
  appId: 'xxx',
  measurementId: 'G-xxx',
);
```

## Monitoring & Analytics

### Firebase Console Monitoring

1. **Authentication Dashboard**:
   - Monitor sign-ups
   - Track auth errors
   - View active sessions

2. **Firestore Dashboard**:
   - Monitor read/write usage
   - Check storage size
   - Review indexing status

3. **Storage Dashboard**:
   - Monitor uploads
   - Track storage usage
   - Review access patterns

### Enable Firebase Analytics

```dart
// Update main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Track events
analytics.logEvent(
  name: 'product_added',
  parameters: {'price': 499},
);
```

## Performance Optimization

### Firebase Optimization

1. **Firestore**:
   - Enable index caching
   - Use pagination (.limit(20))
   - Optimize query filters

2. **Storage**:
   - Enable CDN caching
   - Compress images before upload
   - Use thumbnails for lists

### Flutter Optimization

1. **Reduce app size**:
   ```bash
   flutter build apk --split-per-abi
   flutter build appbundle --release
   ```

2. **Enable ProGuard (Android)**:
   ```gradle
   buildTypes {
     release {
       minifyEnabled true
       shrinkResources true
     }
   }
   ```

3. **Profile before release**:
   ```bash
   flutter run --profile
   # Use DevTools to analyze performance
   ```

## Troubleshooting

### Common Issues

#### Firebase Connection Issues
```
- Check Firebase console → Settings → Service accounts
- Verify google-services.json exists in android/app/
- Verify GoogleService-Info.plist exists in ios/Runner/
- Run: flutter clean && flutter pub get
```

#### Phone Authentication Not Working
```
- Ensure phone auth is enabled in Firebase console
- Check test numbers are added for development
- Verify SMS API quotas on Firebase console
- Check MFA is not required on account
```

#### Image Upload Failing
```
- Verify Storage bucket rules (read all, write authenticated)
- Check image file size is < 25MB
- Verify storage bucket exists
- Check firebase_storage version matches
```

#### Release Build Issues
```
- Run: flutter clean
- Delete: build/ directory
- Run: flutter pub get
- Run: flutter build <android|ios> --release
```

### Debugging Tips

```bash
# View Firebase logs
firebase functions:log --follow

# Test Firestore rules locally
firebase emulators:start

# Check Firebase project status
firebase projects:list

# View analytics
firebase analytics:print_config

# Enable verbose logging
flutter run -v
```

## Maintenance Checklist

- [ ] Daily: Monitor Firebase console for errors
- [ ] Weekly: Check app crash reports
- [ ] Monthly: Review analytics data
- [ ] Monthly: Update Flutter packages
- [ ] Monthly: Review security rules
- [ ] Quarterly: Update app features
- [ ] Quarterly: Submit app updates
- [ ] Yearly: Renew developer accounts

---

**Last Updated**: March 8, 2026
**Status**: Complete
**Support**: Refer to Firebase documentation for latest updates

