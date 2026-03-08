import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../providers/ad_provider.dart';
import '../../../providers/storage_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/advertisement_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/theme.dart';
import '../../../core/utils/constants.dart';

/// Create Advertisement Screen
/// Allows users to create new QR-based advertisements
/// Includes image upload to Firebase Storage
class CreateAdScreen extends ConsumerStatefulWidget {
  const CreateAdScreen({super.key});

  @override
  ConsumerState<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends ConsumerState<CreateAdScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;

  XFile? _selectedImage;
  String? _titleError;
  String? _descriptionError;
  String? _priceError;
  String? _categoryError;
  String? _imageError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _imageError = null;
        });
      }
    } catch (e) {
      setState(() => _imageError = 'Failed to pick image');
    }
  }

  bool _validateForm() {
    bool hasError = false;

    final titleError = Validators.validateTitle(_titleController.text);
    setState(() => _titleError = titleError);
    if (titleError != null) hasError = true;

    final descError =
        Validators.validateDescription(_descriptionController.text);
    setState(() => _descriptionError = descError);
    if (descError != null) hasError = true;

    final priceError = Validators.validatePrice(_priceController.text);
    setState(() => _priceError = priceError);
    if (priceError != null) hasError = true;

    if (_categoryController.text.isEmpty) {
      setState(() => _categoryError = 'Please select a category');
      hasError = true;
    } else {
      setState(() => _categoryError = null);
    }

    if (_selectedImage == null) {
      setState(() => _imageError = 'Please select an image');
      hasError = true;
    } else {
      setState(() => _imageError = null);
    }

    return !hasError;
  }

  Future<void> _handleCreateAd() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      // Get current user ID
      final userAsync = ref.read(currentUserProvider);
      String? userId;

      // Extract userId from AsyncValue
      userAsync.when(
        data: (currentUser) {
          userId = currentUser?.id;
        },
        loading: () {},
        error: (_, __) {},
      );

      if (userId == null || userId!.isEmpty) {
        throw Exception('User not authenticated');
      }
      final uploadNotifier = ref.read(uploadStateProvider.notifier);
      final success = await uploadNotifier.uploadImage(
        imageFile: File(_selectedImage!.path),
        userId: userId!,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      // Get the uploaded image URL from the state
      final uploadState = ref.read(uploadStateProvider);
      String? imageUrl;
      uploadState.whenData((url) => imageUrl = url);

      if (imageUrl == null || imageUrl!.isEmpty) {
        throw Exception('Image URL not available');
      }

      // Create advertisement
      final adNotifier = ref.read(adListProvider.notifier);

      final adId = DateTime.now().millisecondsSinceEpoch.toString();
      final adTitle = _titleController.text;
      final adDesc = _descriptionController.text;
      final adCategory = _categoryController.text;
      final adPrice = double.parse(_priceController.text);

      await adNotifier.addAd(
        userId: userId!,
        shopId: 'current-shop-id',
        title: adTitle,
        description: adDesc,
        imageUrl: imageUrl!,
        category: adCategory,
        price: adPrice,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advertisement created successfully')),
        );
        context.pop(); // Navigate back to dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create ad: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Advertisement'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Header
              Text(
                'Create New Ad',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add details about your product or service',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Title Field
              Text(
                'Ad Title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: 'Enter product or service name',
                  prefixIcon: const Icon(Icons.text_fields),
                  errorText: _titleError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 24),

              // Description Field
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your product or service',
                  prefixIcon: const Icon(Icons.description),
                  errorText: _descriptionError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLength: 500,
              ),
              const SizedBox(height: 24),

              // Category Dropdown
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                decoration: InputDecoration(
                  hintText: 'Select a category',
                  prefixIcon: const Icon(Icons.category),
                  errorText: _categoryError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: Constants.productCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _categoryController.text = value ?? '';
                          _categoryError = null;
                        });
                      },
              ),
              const SizedBox(height: 24),

              // Price Field
              Text(
                'Price',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter price in ₹',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  prefixText: '₹ ',
                  errorText: _priceError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Image Section
              Text(
                'Product Image',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              // Image Preview or Picker
              if (_selectedImage != null)
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() => _selectedImage = null);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: _isSubmitting ? null : _pickImage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 64,
                          color: AppTheme.primaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to select image',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'or drag and drop',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

              if (_imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _imageError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleCreateAd,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Advertisement',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Ad Creation Tips',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Use clear, descriptive titles\n'
                        '• Write detailed descriptions\n'
                        '• Upload high-quality product images\n'
                        '• Set competitive pricing',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
