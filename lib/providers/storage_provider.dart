import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/services/storage_service.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Upload image provider
final uploadImageProvider = FutureProvider.family<String?, (File, String)>((ref, params) async {
  final storageService = ref.watch(storageServiceProvider);
  return await storageService.uploadImage(
    imageFile: params.$1,
    userId: params.$2,
    folder: 'products',
  );
});

// Delete image provider
final deleteImageProvider = FutureProvider.family<bool, String>((ref, imageUrl) async {
  final storageService = ref.watch(storageServiceProvider);
  return await storageService.deleteImage(imageUrl);
});

// Upload state notifier
final uploadStateProvider = StateNotifierProvider<UploadStateNotifier, AsyncValue<String?>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UploadStateNotifier(storageService);
});

class UploadStateNotifier extends StateNotifier<AsyncValue<String?>> {
  final StorageService _storageService;

  UploadStateNotifier(this._storageService) : super(const AsyncValue.data(null));

  Future<bool> uploadImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      state = const AsyncValue.loading();
      final url = await _storageService.uploadImage(
        imageFile: imageFile,
        userId: userId,
      );

      if (url == null) {
        throw Exception('Failed to upload image');
      }

      state = AsyncValue.data(url);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final success = await _storageService.deleteImage(imageUrl);
      if (success) {
        state = const AsyncValue.data(null);
      }
      return success;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
