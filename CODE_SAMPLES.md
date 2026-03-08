# Businexa Flutter - Ready-to-Use Code Samples

## Complete Screen Implementations

### 1. Business Details Screen

```dart
// lib/features/shops/screens/business_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:businexa/core/constants/app_constants.dart';
import 'package:businexa/providers/app_providers.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState
    extends ConsumerState<BusinessDetailsScreen> {
  late TextEditingController _shopNameController;
  late TextEditingController _categoryController;
  late TextEditingController _addressController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;

  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _categoryController = TextEditingController();
    _addressController = TextEditingController();
    _whatsappController = TextEditingController();
    _emailController = TextEditingController();
    _selectedCategory = AppConstants.productCategories.first;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _categoryController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createShop() async {
    if (_shopNameController.text.isEmpty || _selectedCategory == null) {
      setState(() => _errorMessage = 'Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('User not authenticated');

      final shopService = ref.read(shopServiceProvider);
      await shopService.createShop(
        ownerId: userId,
        shopName: _shopNameController.text,
        category: _selectedCategory!,
        address: _addressController.text,
        whatsappNumber: _whatsappController.text,
        email: _emailController.text,
      );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _shopNameController,
              decoration: InputDecoration(
                labelText: 'Shop Name *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
              items: AppConstants.productCategories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'WhatsApp Number',
                prefixText: '+91 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createShop,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Shop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Add Product Screen

```dart
// lib/features/products/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  File? _selectedImage;
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
    _selectedCategory = 'other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategory == null) {
      setState(() => _errorMessage = 'Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentShop = await ref.watch(currentShopProvider.future);
      if (currentShop == null) throw Exception('Shop not found');

      final productService = ref.read(productServiceProvider);
      await productService.addProduct(
        shopId: currentShop.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory!,
        description: _descriptionController.text,
        imageFile: _selectedImage,
      );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image picker
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text('Tap to select image'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price *',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
              items: ['electronics', 'fashion', 'food', 'home', 'other']
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Public Shop Screen

```dart
// lib/features/products/screens/public_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PublicShopScreen extends ConsumerStatefulWidget {
  final String shopId;

  const PublicShopScreen({
    Key? key,
    required this.shopId,
  }) : super(key: key);

  @override
  ConsumerState<PublicShopScreen> createState() => _PublicShopScreenState();
}

class _PublicShopScreenState extends ConsumerState<PublicShopScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final shopFuture = ref.watch(shopByIdProvider(widget.shopId));
    final productsFuture = ref.watch(productsByShopProvider(widget.shopId));
    final subscriptionFuture =
        ref.watch(activeSubscriptionProvider(widget.shopId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        elevation: 0,
      ),
      body: shopFuture.when(
        data: (shop) {
          if (shop == null) {
            return const Center(child: Text('Shop not found'));
          }

          return subscriptionFuture.when(
            data: (subscription) {
              if (subscription == null || !subscription.isActive) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('This shop is currently inactive'),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Shop Info Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.shopName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        if (shop.address != null)
                          Text(shop.address!, style: TextStyle(
                            color: Colors.grey.shade600,
                          )),
                        const SizedBox(height: 16),
                        if (shop.whatsappNumber != null)
                          ElevatedButton.icon(
                            onPressed: () {
                              // Open WhatsApp
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Contact on WhatsApp'),
                          ),
                      ],
                    ),
                  ),

                  // Category Filter
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == 'all',
                            onSelected: (selected) {
                              setState(
                                  () => _selectedCategory = 'all');
                            },
                          ),
                          const SizedBox(width: 8),
                          ...['electronics', 'fashion', 'food', 'other']
                              .map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(cat),
                                      selected:
                                          _selectedCategory == cat,
                                      onSelected: (selected) {
                                        setState(
                                            () =>
                                                _selectedCategory =
                                                    cat);
                                      },
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),

                  // Products List
                  Expanded(
                    child: productsFuture.when(
                      data: (products) {
                        final filteredProducts =
                            _selectedCategory == 'all'
                                ? products
                                : products
                                    .where((p) =>
                                        p.category ==
                                        _selectedCategory)
                                    .toList();

                        if (filteredProducts.isEmpty) {
                          return const Center(
                            child: Text('No products found'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                filteredProducts[index];
                            return Card(
                              margin:
                                  const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  if (product.imageUrl !=
                                      null)
                                    CachedNetworkImage(
                                      imageUrl:
                                          product
                                              .imageUrl!,
                                      height: 200,
                                      width:
                                          double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context,
                                              url) =>
                                              Container(
                                                color: Colors
                                                    .grey
                                                    .shade200,
                                                height:
                                                    200,
                                              ),
                                    ),
                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .all(
                                            12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          product
                                              .name,
                                          style: Theme.of(
                                                  context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(
                                            height:
                                                4),
                                        Text(
                                          '₹${product.price}',
                                          style: Theme.of(
                                                  context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        if (product
                                            .description !=
                                            null)
                                          Text(
                                            product
                                                .description!,
                                            maxLines:
                                                2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style: TextStyle(
                                              color: Colors
                                                  .grey
                                                  .shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(
                              child: Text('Error: $error')),
                    ),
                  ),
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

## Widget Examples

### QR Code Display Widget

```dart
// lib/features/qr/widgets/qr_code_display_widget.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeDisplayWidget extends StatelessWidget {
  final String data;
  final String? title;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const QrCodeDisplayWidget({
    Key? key,
    required this.data,
    this.title,
    this.onDownload,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
            ],
            QrImage(
              data: data,
              version: QrVersions.auto,
              size: 250.0,
              gapless: false,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onDownload != null)
                  IconButton(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                if (onShare != null)
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
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

### Product Card Widget

```dart
// lib/shared/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:businexa/features/products/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (product.imageUrl != null)
              CachedNetworkImage(
                imageUrl: product.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  height: 180,
                ),
              ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              PopupMenuItem(
                                child: const Text('Edit'),
                                onTap: onEdit,
                              ),
                            if (onDelete != null)
                              PopupMenuItem(
                                child: const Text('Delete'),
                                onTap: onDelete,
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (product.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Service Extension Examples

### Product Service Extension

```dart
// Add to lib/features/products/services/product_service.dart
extension ProductServiceExtension on ProductService {
  /// Search products by name or description
  List<ProductModel> searchProducts(
    List<ProductModel> products,
    String query,
  ) {
    if (query.isEmpty) return products;

    return products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            (p.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();
  }

  /// Filter products by category
  List<ProductModel> filterByCategory(
    List<ProductModel> products,
    String category,
  ) {
    if (category == 'all') return products;
    return products.where((p) => p.category == category).toList();
  }

  /// Get total value of all products
  double getTotalProductValue(List<ProductModel> products) {
    return products.fold(0, (sum, p) => sum + p.price);
  }
}
```

