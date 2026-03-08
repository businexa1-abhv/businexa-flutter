# Businexa PWA → Flutter Migration Guide

## Executive Summary

This document provides a complete migration path from the Businexa PWA (React + Supabase) to a cross-platform Flutter application (Web, Android, iOS) with Firebase backend.

**Status**: Foundation Complete | Implementation In Progress

### Key Migration Points

| Component | PWA Stack | Flutter Stack |
|-----------|-----------|---------------|
| Frontend Framework | React 19 | Flutter 3.0+ |
| Routing | React Router v6 | go_router 14.0+ |
| State Management | Context API | Riverpod 2.5+ |
| Backend | Supabase PostgreSQL | Firebase Firestore |
| Authentication | Supabase Auth + OTP | Firebase Auth + Phone |
| Storage | Supabase Storage | Firebase Cloud Storage |
| Realtime | Supabase Realtime | Firestore Snapshots |
| QR Generation | qrcode.react | qr_flutter |

## Project Structure Comparison

### PWA Structure
```
src/
├── pages/          # Page components
├── components/     # Reusable components
├── services/       # API/business logic
├── data/repository/# Data layer
├── app/            # Context & providers
└── utils/          # Utilities
```

### Flutter Structure (New)
```
lib/
├── features/       # Feature modules (auth, shops, products, etc)
├── core/           # Core services, config, constants
├── providers/      # Riverpod state management
├── shared/         # Reusable widgets, theme
├── routes/         # Navigation configuration
└── main.dart       # App entry point
```

## Migration Mapping

### Pages → Screens

| PWA Page | PWA Route | Flutter Screen | Route |
|----------|-----------|-----------------|-------|
| Home | `/` | HomeScreen | `/` |
| Login | `/login` | LoginScreen | `/login` |
| Signup | `/signup` | SignupScreen | `/signup` |
| Business Details | `/business-details` | BusinessDetailsScreen | `/business-details` |
| Dashboard | `/dashboard` | DashboardScreen | `/dashboard` |
| Add Product | `/product/add` | AddProductScreen | `/product/add` |
| Edit Product | `/product/edit/:id` | EditProductScreen | `/product/edit/:id` |
| Product Details | `/product/:id` | ProductDetailsScreen | `/product/:id` |
| Public Shop | `/shop/:shopId` | PublicShopScreen | `/shop/:shopId` |
| Settings | `/settings` | SettingsScreen | `/settings` |
| Account | `/account` | AccountScreen | `/account` |

### Components → Widgets

| PWA Component | Location | Flutter Widget | Location |
|--------------|----------|----------------|----------|
| Header | `components/layout/` | AppBarWidget | `shared/widgets/` |
| BottomNav | `components/layout/` | BottomNavWidget | `shared/widgets/` |
| ProductCard | `components/` | ProductCard | `shared/widgets/` |
| QRCodeBox | `components/` | QrCodeDisplayWidget | `features/qr/widgets/` |
| Button | `components/ui/` | Modified ElevatedButton | Flutter standard |
| Card | `components/ui/` | Card widget | Flutter standard |
| Input | `components/ui/` | TextField | Flutter standard |

### Services → Dart Services

| PWA Service | File | Flutter Service | File |
|-----------|------|-----------------|------|
| auth.service | `services/` | AuthService | `features/auth/services/` |
| product.service | `services/` | ProductService | `features/products/services/` |
| shop.service | `services/` | ShopService | `features/shops/services/` |
| subscription.service | `services/` | SubscriptionService | `features/subscriptions/services/` |
| qr.service | `services/` | QrService | `features/qr/services/` |
| otp.service | `services/` | OtpService | `core/services/` |
| razorpay.service | `services/` | RazorpayService | `features/subscriptions/services/` |
| supabase.js | `services/` | firebase_service.dart | `core/services/` |

### Context/State → Providers

| PWA Context | File | Flutter Provider | File |
|-----------|------|------------------|------|
| AuthContext | `app/` | authStateProvider | `providers/app_providers.dart` |
| SearchContext | `app/` | productSearchQueryProvider | `providers/app_providers.dart` |
| ThemeContext | `app/` | themeModeProvider | `providers/theme_provider.dart` |
| (Custom Hooks) | Various | (Riverpod Providers) | `providers/app_providers.dart` |

## Step-by-Step Implementation Plan

### Phase 1: Foundation ✅ Complete

**Status**: Ready for development

1. ✅ Create Flutter project structure
2. ✅ Configure Firebase services
3. ✅ Setup pubspec.yaml with dependencies
4. ✅ Create data models (User, Shop, Product, Subscription, Scan)
5. ✅ Setup go_router configuration
6. ✅ Create app_providers (Riverpod state management)
7. ✅ Configure theme and constants

**Deliverables**:
- Flutter project with proper structure
- Firebase configuration
- Go_router routing system
- Riverpod providers setup
- All data models with Firestore serialization

### Phase 2: Authentication 🔄 In Progress

**Next Steps**:

1. Implement LoginScreen
   - Phone number input
   - OTP request button
   - OTP verification input
   - Error handling
   - Loading states

2. Implement SignupScreen
   - Similar to LoginScreen
   - Additional fields if needed

3. Create phone auth flow
   - Firebase Phone Authentication
   - Custom OTP verification
   - Session management
   - Token refresh logic

4. Implement ProtectedRoute logic
   - Redirect unauthenticated users to login
   - Handle auth state changes

**Files to Create/Update**:
- `features/auth/screens/login_screen.dart`
- `features/auth/screens/signup_screen.dart`
- Auth guard in `routes/app_router.dart`

### Phase 3: Business Details Setup 🔄 To Do

**Tasks**:

1. Implement BusinessDetailsScreen
   - Shop name input
   - Category dropdown
   - Address, WhatsApp, email fields
   - Submit and create shop

2. Implement ShopService
   - Create shop with unique slug
   - Update shop details
   - Get shop by various criteria

3. Setup error handling
   - Validation errors
   - Firebase write errors
   - User feedback

**Files to Create/Update**:
- `features/shops/screens/business_details_screen.dart`
- `features/shops/services/shop_service.dart` (complete)
- `features/shops/repositories/shop_repository.dart`

### Phase 4: Dashboard & Products 🔄 To Do

**Tasks**:

1. Implement DashboardScreen
   - Display shop overview
   - Show subscription status
   - List user's products
   - Quick actions (Add product, Settings, etc)

2. Implement AddProductScreen
   - Image upload
   - Product details form
   - Category selection
   - Submit and save to Firestore

3. Implement ProductListScreen
   - Fetch products from Firestore
   - Display in grid/list
   - Pagination or infinite scroll
   - Search and filter

4. Implement ProductDetailsScreen
   - Single product view
   - Edit/Delete options
   - Image gallery

5. Complete ProductService
   - CRUD operations
   - Image upload to Firebase Storage
   - Search functionality

**Files to Create/Update**:
- `features/shops/screens/dashboard_screen.dart`
- `features/products/screens/add_product_screen.dart`
- `features/products/screens/product_list_screen.dart` (new)
- `features/products/screens/product_details_screen.dart`
- `features/products/services/product_service.dart` (complete)

### Phase 5: QR Codes & Public Shop 📋 To Do

**Tasks**:

1. Create QrService
   - Generate QR code for shop URL
   - Download QR as image
   - Share via WhatsApp
   - Copy URL to clipboard

2. Implement QrCodeDisplayWidget
   - Display QR code
   - Download button
   - Share button
   - Copy link button

3. Implement PublicShopScreen
   - Fetch shop data by slug
   - Display shop info
   - Check subscription status
   - List products with filtering
   - WhatsApp CTA button
   - Track QR scans

4. Implement scan tracking
   - Log scan events to Firestore
   - Store device info, timestamp
   - Optional: geolocation

**Files to Create/Update**:
- `features/qr/services/qr_service.dart`
- `features/qr/widgets/qr_code_display_widget.dart`
- `features/products/screens/public_shop_screen.dart`
- `features/products/services/scan_tracking_service.dart` (new)

### Phase 6: Subscriptions & Payments 📋 To Do

**Tasks**:

1. Implement SubscriptionScreen
   - Display subscription plans
   - Pricing information
   - Purchase button for each plan

2. Integrate Razorpay
   - Setup payment method
   - Create payment orders
   - Verify payment
   - Update subscription status

3. Create SubscriptionService methods
   - Get active subscription
   - Check if subscription active
   - Create subscription record
   - Handle subscription expiry

4. Setup subscription checks
   - Verify subscription before showing products
   - Display subscription status on dashboard
   - Show upgrade prompts

**Files to Create/Update**:
- `features/subscriptions/screens/subscription_screen.dart`
- `features/subscriptions/services/subscription_service.dart` (complete)
- `features/subscriptions/services/razorpay_service.dart`

### Phase 7: Settings & Account 📋 To Do

**Tasks**:

1. Implement AccountScreen
   - Display user profile
   - Edit profile
   - View subscription info
   - View shop QR code

2. Implement SettingsScreen
   - App preferences
   - Theme toggle
   - Logout option
   - About app

3. Create settings service
   - Save user preferences locally
   - Export products data
   - Clear app data

**Files to Create/Update**:
- `features/auth/screens/account_screen.dart`
- `features/settings/screens/settings_screen.dart` (new)
- `features/settings/services/settings_service.dart` (new)

### Phase 8: UI Polish & Shared Components 📋 To Do

**Tasks**:

1. Create reusable widgets
   - AppBarWidget
   - BottomNavigationWidget
   - LoadingWidget
   - ErrorWidget
   - EmptyStateWidget
   - CustomButtonWidget (if needed)

2. Setup responsive design
   - Mobile-first design
   - Tablet layout variations
   - Adaptive navigation

3. Create shared theme
   - Color scheme
   - Typography
   - Spacing constants
   - Component styles

**Files to Create/Update**:
- `shared/widgets/` (various)
- `shared/theme/app_theme.dart`
- `core/constants/app_constants.dart` (finalize)

## Authentication Flow Comparison

### PWA Flow
1. User enters phone number
2. Sends OTP via SMS
3. User verifies OTP
4. Creates/Signs in with Supabase Auth
5. Creates/Updates user profile in DB
6. Stores session token in localStorage
7. Redirects to next page

### Flutter Flow (Same Business Logic)
1. User enters phone number
2. Sends OTP via Firebase Phone Auth
3. User verifies OTP
4. Signs in with Firebase Auth
5. Creates/Updates user profile in Firestore
6. Firebase handles token refresh
7. Redirects using go_router

## Key Differences & Considerations

### 1. Platform-Specific Code

**iOS Entitlements** (needed):
```xml
<key>NSPhoneNumbersUsageDescription</key>
<string>We need access to send verification codes</string>
```

**Android Permissions** (already added):
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 2. Web-Specific Considerations

- Firebase Auth doesn't support phone auth on web
- Use email/password or other auth methods for web
- Update SignUpScreen to handle web differently

### 3. Image Handling

**PWA**: Uses url to Firebase Storage directly
**Flutter**: Uses cached_network_image for better performance

### 4. Navigation

**PWA**: React Router with nested routes
**Flutter**: go_router with proper deep linking support

### 5. State Management

**PWA**: Context API + Custom Hooks
**Flutter**: Riverpod with proper invalidation

## Firebase Firestore Collections Setup

```javascript
// Create these collections and documents in Firebase Console

db.collection('users').doc(userId).set({
  mobile_number: '',
  email: '',
  display_name: '',
  created_at: serverTimestamp(),
  updated_at: serverTimestamp(),
});

db.collection('shops').doc(shopId).set({
  owner_id: userId,
  shop_name: '',
  category: '',
  address: '',
  whatsapp_number: '',
  email: '',
  slug: '',
  created_at: serverTimestamp(),
  updated_at: serverTimestamp(),
});

db.collection('products').doc(productId).set({
  shop_id: shopId,
  name: '',
  description: '',
  price: 0,
  category: '',
  image_url: '',
  created_at: serverTimestamp(),
  updated_at: serverTimestamp(),
});

db.collection('subscriptions').doc(subscriptionId).set({
  shop_id: shopId,
  plan_id: '',
  status: 'active',
  amount: 0,
  currency: 'INR',
  razorpay_payment_id: '',
  razorpay_order_id: '',
  starts_at: serverTimestamp(),
  expires_at: serverTimestamp(),
  created_at: serverTimestamp(),
});

db.collection('scans').doc(scanId).set({
  product_id: productId,
  shop_id: shopId,
  device_id: '',
  timestamp: serverTimestamp(),
  latitude: 0,
  longitude: 0,
  user_agent: '',
});
```

## Testing Checklist

### Unit Tests
- [ ] UserModel serialization
- [ ] ProductModel calculations
- [ ] SubscriptionModel.isActive logic
- [ ] Search and filter functions

### Widget Tests
- [ ] Login screen form validation
- [ ] Product card displays correctly
- [ ] QR code widget renders

### Integration Tests
- [ ] Complete signup flow
- [ ] Product creation and display
- [ ] Public shop page loading
- [ ] Subscription purchase flow

## Performance Optimization Tips

1. **Image Optimization**
   - compress_images before upload
   - Use thumbnails for lists
   - Use cached_network_image

2. **Firestore Optimization**
   - Use pagination (.limit(20))
   - Index frequently queried fields
   - Use collection groups for scans

3. **Provider Optimization**
   - Use .select() to watch specific fields
   - Implement caching with AsyncValue
   - Use .future for one-time loads

4. **Build Optimization**
   - Use `flutter build --profile` for testing
   - Enable BuildVerbosity for analysis
   - Use DevTools to find expensive builds

## Deployment Strategy

### Phase 1: Testing (Week 1-2)
1. Internal testing on devices
2. Fix critical bugs
3. Gather feedback

### Phase 2: Beta (Week 3-4)
1. TestFlight for iOS
2. Internal Testing Track for Android
3. Collect user feedback
4. Refine UI/UX

### Phase 3: Production (Week 5)
1. Google Play Store submission
2. Apple App Store submission
3. Web version on Firebase Hosting
4. Monitor crash reports

## Support & Maintenance

### Critical Issues (24hr response)
- Authentication broken
- Payment processing broken
- Data loss issues

### High Priority (1 week)
- UI bugs
- Performance issues
- Missing features

### Medium Priority (2-4 weeks)
- Polish improvements
- Minor UI tweaks
- Optimization

## Resources & Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Riverpod Documentation](https://riverpod.dev)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)

## Contact & Support

For questions about this migration:
1. Review the detailed implementation guides
2. Check CODE_SAMPLES.md for examples
3. Consult IMPLEMENTATION_CHECKLIST.md for status

---

**Last Updated**: March 8, 2026
**Status**: Foundation Complete, Ready for Development
**Next Milestone**: Complete Authentication Phase
