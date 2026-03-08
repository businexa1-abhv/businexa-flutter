# Businexa Flutter - Complete Implementation Checklist

## Implementation Status Overview

### Phase 1: Core Infrastructure ✅
- [x] Project setup and configuration
- [x] Firebase configuration
- [x] Pubspec dependencies
- [x] Data models (User, Shop, Product, Subscription, Scan)
- [x] Service providers (Riverpod)
- [x] Routing configuration (go_router)
- [x] Theme and constants

### Phase 2: Authentication System 🔄
- [x] OTP Service implementation
- [x] Firebase Auth service
- [x] User profile management
- [ ] Login screen UI
- [ ] Signup screen UI
- [ ] Business details setup screen
- [ ] Phone verification UI

### Phase 3: Shop Management 🔄
- [ ] Shop creation service
- [ ] Shop service repository
- [ ] Dashboard screen
- [ ] Shop settings screen
- [ ] Shop info card widget

### Phase 4: Product Management 🔄
- [x] Product model
- [x] Product service (CRUD)
- [ ] Add product screen
- [ ] Edit product screen
- [ ] Product list screen
- [ ] Product details screen
- [ ] Image upload widget

### Phase 5: QR & Public Shop 📋
- [ ] QR code generation service
- [ ] QR display widget
- [ ] Public shop page
- [ ] Product gallery widget
- [ ] Category filter component
- [ ] Infinite scroll pagination
- [ ] Scan tracking

### Phase 6: Subscriptions & Payments 📋
- [x] Subscription model
- [x] Subscription service
- [ ] Subscription screen
- [ ] Razorpay integration
- [ ] Payment UI

### Phase 7: Settings & Account 📋
- [ ] Settings screen
- [ ] Account profile screen
- [ ] Logout functionality
- [ ] Data export feature

### Phase 8: Shared Components 📋
- [ ] App bar widget
- [ ] Bottom navigation
- [ ] Loading indicators
- [ ] Error handling UI
- [ ] Empty state widgets
- [ ] Custom buttons

## Service Implementation Guide

### 1. Complete Shop Service

```dart
// lib/features/shops/services/shop_service.dart
import 'package:businexa/core/constants/app_constants.dart';
import 'package:businexa/core/services/firebase_service.dart';
import 'package:businexa/features/shops/models/shop_model.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class ShopService {
  static final ShopService _instance = ShopService._internal();
  final Logger _logger = Logger();
  final FirebaseService _firebaseService = FirebaseService();

  ShopService._internal();

  factory ShopService() {
    return _instance;
  }

  /// Create a new shop
  Future<ShopModel> createShop({
    required String ownerId,
    required String shopName,
    required String category,
    String? address,
    String? whatsappNumber,
    String? email,
  }) async {
    try {
      // Generate unique slug
      final slug = await _generateUniqueSlug(shopName);

      final now = DateTime.now();
      final shop = ShopModel(
        id: const Uuid().v4(),
        ownerId: ownerId,
        shopName: shopName,
        category: category,
        address: address,
        whatsappNumber: whatsappNumber,
        email: email,
        slug: slug,
        createdAt: now,
        updatedAt: now,
      );

      await _firebaseService.setDocument(
        AppConstants.shopsCollection,
        shop.id,
        shop.toFirestore(),
      );

      _logger.i('Shop created: ${shop.id}');
      return shop;
    } catch (e) {
      _logger.e('Error creating shop: $e');
      rethrow;
    }
  }

  /// Get shop by owner ID
  Future<ShopModel?> getShopByOwner(String ownerId) async {
    try {
      final docs = await _firebaseService.queryDocuments(
        AppConstants.shopsCollection,
        where: {'owner_id': ownerId},
      );

      if (docs.isEmpty) return null;
      return ShopModel.fromFirestore(docs.first);
    } catch (e) {
      _logger.e('Error getting shop by owner: $e');
      rethrow;
    }
  }

  /// Get shop by ID
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      final doc = await _firebaseService.getDocument(
        AppConstants.shopsCollection,
        shopId,
      );

      if (doc == null) return null;
      return ShopModel.fromFirestore(doc);
    } catch (e) {
      _logger.e('Error getting shop by ID: $e');
      rethrow;
    }
  }

  /// Get shop by slug (for public shop page)
  Future<ShopModel?> getShopBySlug(String slug) async {
    try {
      final docs = await _firebaseService.queryDocuments(
        AppConstants.shopsCollection,
        where: {'slug': slug},
      );

      if (docs.isEmpty) return null;
      return ShopModel.fromFirestore(docs.first);
    } catch (e) {
      _logger.e('Error getting shop by slug: $e');
      rethrow;
    }
  }

  /// Update shop details
  Future<void> updateShop(String shopId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now();
      await _firebaseService.updateDocument(
        AppConstants.shopsCollection,
        shopId,
        data,
      );
      _logger.i('Shop updated: $shopId');
    } catch (e) {
      _logger.e('Error updating shop: $e');
      rethrow;
    }
  }

  /// Generate unique slug
  Future<String> _generateUniqueSlug(String shopName) async {
    try {
      String slug = shopName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');

      int counter = 1;
      String uniqueSlug = slug;

      // Check if slug exists
      while (await _slugExists(uniqueSlug)) {
        uniqueSlug = '$slug-$counter';
        counter++;
      }

      return uniqueSlug;
    } catch (e) {
      _logger.e('Error generating slug: $e');
      return const Uuid().v4();
    }
  }

  /// Check if slug exists
  Future<bool> _slugExists(String slug) async {
    try {
      final docs = await _firebaseService.queryDocuments(
        AppConstants.shopsCollection,
        where: {'slug': slug},
      );
      return docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get public shop URL
  String getShopPublicUrl(ShopModel shop) {
    const baseUrl = 'https://businexa.com';
    return '$baseUrl/shop/${shop.slug}';
  }
}
```

### 2. QR Code Service

```dart
// lib/features/products/services/qr_service.dart
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrService {
  static final QrService _instance = QrService._internal();
  final Logger _logger = Logger();

  QrService._internal();

  factory QrService() {
    return _instance;
  }

  /// Generate QR code for shop URL
  String generateQrData(String shopUrl) {
    return shopUrl;
  }

  /// Download QR code as image
  Future<void> downloadQrCode(
    String qrData, {
    String filename = 'businexa_qrcode.png',
  }) async {
    try {
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: false,
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      // Generate image
      final image = await qrPainter.toImageData(200);
      await file.writeAsBytes(image!.buffer.asUint8List());

      // Save to gallery
      await ImageGallerySaver.saveFile(filePath);

      _logger.i('QR code downloaded: $filePath');
    } catch (e) {
      _logger.e('Error downloading QR code: $e');
      rethrow;
    }
  }

  /// Share QR code via WhatsApp
  Future<void> shareViaWhatsApp(
    String shopUrl,
    String shopName,
  ) async {
    try {
      final message = Uri.encodeComponent(
        'Check out $shopName on Businexa!\n\nVisit: $shopUrl',
      );
      // Implement WhatsApp sharing using url_launcher
    } catch (e) {
      _logger.e('Error sharing via WhatsApp: $e');
      rethrow;
    }
  }

  /// Copy shop URL to clipboard
  Future<void> copyToClipboard(String text) async {
    try {
      // Use flutter/services to copy text
    } catch (e) {
      _logger.e('Error copying to clipboard: $e');
      rethrow;
    }
  }
}
```

## Screen Implementation Examples

### 1. Login Screen Template

```dart
// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  bool _showOtpField = false;
  bool _isLoading = false;
  String? _verificationId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final verificationId = await authService.sendOtp(_phoneController.text);
      setState(() {
        _verificationId = verificationId;
        _showOtpField = true;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _verificationId == null) {
      setState(() => _errorMessage = 'Please enter OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyOtpAndSignIn(_verificationId!, _otpController.text);

      if (mounted) {
        context.go('/business-details');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Invalid OTP. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Businexa',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Advertise Your Products with QR Codes',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            if (!_showOtpField) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '9876543210',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP'),
                ),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify OTP'),
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Dashboard Screen Template

```dart
// lib/features/shops/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentShop = ref.watch(currentShopProvider);
    final userProducts = ref.watch(currentUserProductsProvider);
    final activeSubscription = ref.watch(currentUserSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: currentShop.when(
        data: (shop) {
          if (shop == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No shop found'),
                  ElevatedButton(
                    onPressed: () => context.go('/business-details'),
                    child: const Text('Create Shop'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(currentShopProvider);
              ref.refresh(currentUserProductsProvider);
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Shop Info Card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.shopName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text('Category: ${shop.category}'),
                            if (shop.address != null)
                              Text('Address: ${shop.address}'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Subscription Status
                  activeSubscription.when(
                    data: (subscription) {
                      if (subscription == null) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            color: Colors.orange.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('No Active Subscription'),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Activate subscription to show products publicly',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        context.go('/subscription'),
                                    child: const Text('Subscribe'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.green.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Active Subscription'),
                                Text(
                                  'Expires: ${subscription.expiresAt}',
                                ),
                                Text(
                                  'Remaining: ${subscription.remainingDuration.inDays} days',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),

                  // Products Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Products',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/product/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                        ),
                      ],
                    ),
                  ),

                  userProducts.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No products found'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('₹${product.price}'),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Edit'),
                                  onTap: () =>
                                      context.go('/product/edit/${product.id}'),
                                ),
                                PopupMenuItem(
                                  child: const Text('Delete'),
                                  onTap: () {
                                    // Delete product
                                  },
                                ),
                              ],
                            ),
                            onTap: () =>
                                context.go('/product/${product.id}'),
                          );
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

## Firebase Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper function to check if user is the owner
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Users collection - Only users can read/write their own profile
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      allow create: if isAuthenticated();
    }

    // Shops collection - Owner can read/write, others can read if public
    match /shops/{shopId} {
      allow read: if true; // Public read for shop discovery
      allow write: if isAuthenticated() && isOwner(resource.data.owner_id);
      allow create: if isAuthenticated();
    }

    // Products collection - Owner can read/write via shop, public read
    match /products/{productId} {
      allow read: if true; // Public read
      allow write: if isAuthenticated() &&
                      get(/databases/$(database)/documents/shops/$(resource.data.shop_id)).data.owner_id == request.auth.uid;
      allow create: if isAuthenticated();
    }

    // Subscriptions collection - Owner can read/write
    match /subscriptions/{subscriptionId} {
      allow read, write: if isAuthenticated() &&
                           get(/databases/$(database)/documents/shops/$(resource.data.shop_id)).data.owner_id == request.auth.uid;
      allow create: if isAuthenticated();
    }

    // Scans collection - Anyone can write (track scans), owner can read
    match /scans/{scanId} {
      allow write: if true; // Anonymous scan tracking
      allow read: if isAuthenticated() &&
                     get(/databases/$(database)/documents/shops/$(resource.data.shop_id)).data.owner_id == request.auth.uid;
    }

    // OTP Verifications - Internal use only
    match /otp_verifications/{otpId} {
      allow read, write: if false; // Only Cloud Functions access
    }
  }
}
```

## Deployment Checklist

- [ ] Configure Firebase project
- [ ] Enable Firestore
- [ ] Enable Firebase Storage
- [ ] Enable Firebase Authentication (Phone)
- [ ] Set Firestore security rules
- [ ] Configure storage rules
- [ ] Add Firebase config to Android
- [ ] Add Firebase config to iOS
- [ ] Set up Razorpay keys
- [ ] Configure Cloud Functions for OTP
- [ ] Test authentication flow
- [ ] Test product CRUD
- [ ] Test subscription flow
- [ ] Test public shop page
- [ ] Build Android APK/AAB
- [ ] Build iOS APP
- [ ] Deploy web version
- [ ] Submit to Google Play
- [ ] Submit to App Store

