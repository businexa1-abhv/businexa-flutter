# Businexa Flutter Migration Complete Guide

## Project Overview
Businexa is a QR-code based business advertisement platform migrated from React PWA to Flutter. This guide provides a complete implementation of all screens, services, and features.

## Architecture

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase config
├── core/                     # Core utilities
│   ├── config/
│   ├── constants/
│   ├── dev/
│   └── services/
├── features/                 # Feature modules
│   ├── auth/
│   ├── shops/
│   ├── products/
│   ├── subscriptions/
│   ├── qr/
│   ├── analytics/
│   └── settings/
├── models/                   # Data models
├── repositories/             # Data access layer
├── services/                 # Business logic
├── providers/                # Riverpod providers
├── routes/                   # Navigation
├── shared/                   # Shared widgets
├── utils/                    # Utilities
└── widgets/                  # Reusable widgets
```

## Key Features Implementation

### 1. **Authentication System**
- OTP-based login/signup
- Firebase Authentication integration
- User profile creation in Firestore
- Mobile number validation
- Session management

### 2. **Shop Management**
- Create/edit shop details
- Shop slug generation (URL-friendly)
- Shop subscription status
- Public shop pages
- Shop analytics

### 3. **Product Management**
- Add/edit/delete products
- Image upload to Firebase Storage
- Product categorization
- Stock management
- Product export/import (JSON/CSV)

### 4. **QR Code System**
- Generate QR codes for shops
- Download QR as PNG
- Share QR via WhatsApp
- Copy shop URL
- Deep linking support

### 5. **Subscription Management**
- Multiple subscription plans
- Razorpay payment integration
- Subscription status tracking
- Renewal management
- Auto-upgrade on new payments

### 6. **Analytics & Tracking**
- Track QR scans
- Log scan events
- Location tracking (optional)
- Device information
- Real-time dashboard

### 7. **Public Shop Display**
- Product gallery with images
- Category filtering
- Search functionality
- Infinite scroll pagination
- WhatsApp inquiry feature

## Firestore Database Design

### Collections

#### `users/`
```
Document ID: User ID (Firebase Auth UID)
{
  id: string
  email: string
  mobileNumber: string
  createdAt: timestamp
  lastLogin: timestamp
  displayName: string
  photoUrl: string
}
```

#### `shops/`
```
Document ID: Shop ID (UUID)
{
  id: string
  ownerId: string (User ID)
  shopName: string
  category: string
  address: string
  whatsappNumber: string
  email: string
  slug: string (unique URL identifier)
  description: string
  logoUrl: string
  createdAt: timestamp
  updatedAt: timestamp
  isActive: boolean
}
```

#### `products/`
```
Document ID: Product ID (UUID)
{
  id: string
  shopId: string
  name: string
  description: string
  price: number
  category: string
  imageUrl: string
  imageUrls: array (multiple images)
  sku: string
  stock: number
  createdAt: timestamp
  updatedAt: timestamp
  isActive: boolean
}
```

#### `subscriptions/`
```
Document ID: Subscription ID (UUID)
{
  id: string
  shopId: string
  planId: string (monthly, quarterly, half_yearly, yearly)
  status: string (active, inactive, expired, cancelled)
  amount: number
  currency: string (INR)
  razorpayPaymentId: string
  razorpayOrderId: string
  razorpaySignature: string
  startsAt: timestamp
  expiresAt: timestamp
  createdAt: timestamp
  updatedAt: timestamp
}
```

#### `scans/`
```
Document ID: Scan ID (UUID)
{
  id: string
  adId: string (Product ID or Shop ID)
  shopId: string
  timestamp: timestamp
  deviceInfo: {
    userAgent: string
    os: string
    browser: string
  }
  location: {
    latitude: number
    longitude: number
    country: string
    city: string
  }
  referer: string
}
```

#### `analytics/`
```
Document ID: Analytics ID
{
  shopId: string
  date: date
  totalScans: number
  uniqueScans: number
  topProducts: array
  referrerStats: map
}
```

## State Management with Riverpod

### Provider Structure
```dart
// Service Providers
final authServiceProvider = Provider<AuthService>
final shopServiceProvider = Provider<ShopService>
final productServiceProvider = Provider<ProductService>
final subscriptionServiceProvider = Provider<SubscriptionService>

// Data Providers
final authStateProvider = StreamProvider<User?>
final currentUserProfileProvider = FutureProvider<UserModel?>
final currentShopProvider = FutureProvider<ShopModel?>
final productsByShopProvider = FutureProvider.family<List<ProductModel>>
final activeSubscriptionProvider = FutureProvider.family<SubscriptionModel?>

// UI State Providers
final selectedCategoryProvider = StateProvider<String>
final productSearchQueryProvider = StateProvider<String>
final themeModeProvider = StateProvider<bool>
```

## Routing Configuration

```dart
GoRouter Routes:
/ → HomeScreen
/login → LoginScreen
/signup → SignupScreen
/business-details → BusinessDetailsScreen
/dashboard → DashboardScreen
/product/add → AddProductScreen
/product/edit/:id → EditProductScreen
/product/:id → ProductDetailsScreen
/settings → SettingsScreen
/account → AccountScreen
/shop/:shopId → PublicShopScreen
/terms → PolicyScreen(type: 'terms')
/privacy → PolicyScreen(type: 'privacy')
/help → PolicyScreen(type: 'help')
/refund → PolicyScreen(type: 'refund')
```

## Firebase Configuration

### Required Services
1. **Firebase Authentication** - OTP login
2. **Cloud Firestore** - Data storage
3. **Firebase Storage** - Image uploads
4. **Cloud Functions** - OTP verification, Razorpay orders
5. **Firebase Hosting** - Web deployment

### Environment Variables (.env.dev, .env.prod)
```
FIREBASE_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_APP_ID=
RAZORPAY_KEY_ID=
RAZORPAY_SECRET_KEY=
FAST2SMS_API_KEY=
PUBLIC_URL=https://businexa.com
```

## Key Services

### AuthService
- `sendOtp(String mobileNumber): Future<String>` - Returns verification ID
- `verifyOtpAndSignIn(String verificationId, String otp): Future<User>`
- `verifyOTPAndSignup(String verificationId, String mobileNumber): Future<User>`
- `createOrUpdateUserProfile(String mobileNumber): Future<UserModel>`
- `signOut(): Future<void>`
- `getCurrentUserProfile(): Future<UserModel?>`

### ShopService
- `createShop(ShopModel shop): Future<ShopModel>`
- `getShopByOwner(String userId): Future<ShopModel?>`
- `getShopById(String shopId): Future<ShopModel?>`
- `getShopBySlug(String slug): Future<ShopModel?>`
- `updateShop(String shopId, ShopModel shop): Future<ShopModel>`
- `deleteShop(String shopId): Future<void>`
- `generateUniqueSlug(String shopName): Future<String>`

### ProductService
- `addProduct(ProductModel product): Future<ProductModel>`
- `updateProduct(String productId, ProductModel product): Future<ProductModel>`
- `deleteProduct(String productId): Future<void>`
- `getProductById(String productId): Future<ProductModel?>`
- `getProductsByShop(String shopId, [int page = 0]): Future<List<ProductModel>>`
- `getProductsByCategory(String shopId, String category): Future<List<ProductModel>>`
- `searchProducts(List<ProductModel> products, String query): List<ProductModel>`

### SubscriptionService
- `getActivePlan(String planId): SubscriptionPlan?`
- `createSubscription(String shopId, String planId, PaymentResult result): Future<SubscriptionModel>`
- `getActiveSubscription(String shopId): Future<SubscriptionModel?>`
- `isSubscriptionActive(String shopId): Future<bool>`
- `renewSubscription(String shopId, String planId): Future<SubscriptionModel>`

### StorageService
- `uploadImage(String userId, File image): Future<String>` - Returns image URL
- `deleteImage(String imageUrl): Future<void>`
- `getSignedUrl(String imagePath, Duration expiresIn): Future<String>`

## Models (Data Classes)

All models use freezed for immutability and serialization.

```dart
class UserModel {
  final String id;
  final String? email;
  final String mobileNumber;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
}

class ShopModel {
  final String id;
  final String ownerId;
  final String shopName;
  final String category;
  final String address;
  final String? whatsappNumber;
  final String? email;
  final String slug; // URL-friendly
  final String? description;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final List<String> imageUrls;
  final String? sku;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}

class SubscriptionModel {
  final String id;
  final String shopId;
  final String planId;
  final String status; // active, inactive, expired, cancelled
  final double amount;
  final String currency;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
  final DateTime startsAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ScanEventModel {
  final String id;
  final String shopId;
  final String? productId;
  final DateTime timestamp;
  final Map<String, String> deviceInfo;
  final Map<String, dynamic>? location;
  final String? referer;
}
```

## Widgets & Components

### Shared Widgets
- `CustomAppBar` - Reusable app bar
- `PrimaryButton` - Styled button
- `ProductCard` - Product display card
- `ShopCard` - Shop display card
- `LoadingWidget` - Loading spinner
- `ErrorWidget` - Error display
- `EmptyStateWidget` - Empty state
- `SkeletonLoader` - Loading skeleton

## Testing Checklist

- [ ] Login/Signup flow with OTP
- [ ] Shop creation and management
- [ ] Product CRUD operations
- [ ] Image upload and display
- [ ] QR code generation and download
- [ ] Subscription management
- [ ] Public shop page display
- [ ] Product search and filtering
- [ ] Infinite scroll pagination
- [ ] Dark mode support
- [ ] Responsive design (Web, Android, iOS)
- [ ] Offline functionality (cached data)
- [ ] Performance optimization

## Deployment

### Firebase Hosting
```bash
firebase init hosting
firebase deploy --only hosting
```

### Android APK
```bash
flutter build apk --split-per-abi
```

### iOS App
```bash
flutter build ios
```

### Web Deployment
```bash
flutter build web
firebase hosting:channel:deploy production
```

## Performance Optimization

1. **Image Caching** - Use cached_network_image
2. **Lazy Loading** - Load products on scroll
3. **Code Splitting** - Use feature modules
4. **Offline Support** - Cache critical data
5. **State Management** - Only rebuild affected widgets
6. **Database Indexing** - Index frequently queried fields

## Security Best Practices

1. **API Keys** - Use Firebase Security Rules
2. **User Data** - Encrypt sensitive information
3. **OTP Verification** - Implement server-side verification
4. **Payment** - Never expose Razorpay secret key
5. **Storage** - Use secure storage for tokens
6. **Input Validation** - Validate all user input

## Known Limitations & Future Improvements

1. **SMS Service** - Currently using Fast2SMS (India only)
2. **Multi-language** - Future internationalization
3. **Push Notifications** - Firebase Cloud Messaging integration
4. **Analytics** - Enhanced analytics dashboard
5. **Advanced Features** - Inventory management, bulk orders
6. **API Rate Limiting** - Implement request throttling

## References

- [Flutter Official Docs](https://flutter.dev)
- [Firebase Flutter Guide](https://firebase.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

**Last Updated:** March 2024
**Version:** 1.0.0
