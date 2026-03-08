import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/ad_service.dart';
import '../models/advertisement_model.dart';

// Ad service provider
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

// Get single ad by ID
final adDetailProvider = FutureProvider.family<Advertisement?, String>((ref, adId) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.getAdById(adId);
});

// Get ad by slug (for public ad page)
final adBySlugProvider = FutureProvider.family<Advertisement?, String>((ref, slug) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.getAdBySlug(slug);
});

// Get ads by shop ID (paginated)
final adsByShopIdProvider = FutureProvider.family<List<Advertisement>, String>((ref, shopId) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.getAdsByShopId(shopId);
});

// Get ads by user ID
final adsByUserIdProvider = FutureProvider.family<List<Advertisement>, String>((ref, userId) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.getAdsByUserId(userId);
});

// Get ads by category
final adsByCategoryProvider = FutureProvider.family<List<Advertisement>, (String, String)>((ref, params) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.getAdsByCategory(params.$1, params.$2);
});

// Search ads
final searchAdsProvider = FutureProvider.family<List<Advertisement>, String>((ref, query) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.searchAds(query);
});

// Create ad notifier
final createAdProvider = FutureProvider.family<Advertisement?, Map<String, dynamic>>((ref, data) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.createAd(
    userId: data['userId'],
    shopId: data['shopId'],
    title: data['title'],
    description: data['description'],
    imageUrl: data['imageUrl'],
    category: data['category'],
    price: data['price'],
  );
});

// Ad list state notifier
final adListProvider = StateNotifierProvider<AdListNotifier, AsyncValue<List<Advertisement>>>((ref) {
  final adService = ref.watch(adServiceProvider);
  return AdListNotifier(adService);
});

class AdListNotifier extends StateNotifier<AsyncValue<List<Advertisement>>> {
  final AdService _adService;

  AdListNotifier(this._adService) : super(const AsyncValue.loading());

  Future<void> loadAds({required String userId}) async {
    try {
      state = const AsyncValue.loading();
      final ads = await _adService.getAdsByUserId(userId);
      state = AsyncValue.data(ads);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadAdsByShop({required String shopId}) async {
    try {
      state = const AsyncValue.loading();
      final ads = await _adService.getAdsByShopId(shopId);
      state = AsyncValue.data(ads);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addAd({
    required String userId,
    required String shopId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    required double price,
  }) async {
    try {
      final ad = await _adService.createAd(
        userId: userId,
        shopId: shopId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        category: category,
        price: price,
      );
      
      if (ad == null) return false;
      
      // Add to current list
      final current = state.whenData((ads) => ads).value ?? [];
      state = AsyncValue.data([ad, ...current]);
      return true;
    } catch (e) {
      print('Error adding ad: $e');
      return false;
    }
  }

  Future<bool> updateAd(String adId, Map<String, dynamic> data) async {
    try {
      final success = await _adService.updateAd(adId, data);
      if (success) {
        // Reload ads
        final current = state.whenData((ads) => ads).value ?? [];
        final updated = current.map((ad) {
          if (ad.id == adId) {
            return ad.copyWith(
              title: data['title'] ?? ad.title,
              description: data['description'] ?? ad.description,
              price: data['price'] ?? ad.price,
              category: data['category'] ?? ad.category,
            );
          }
          return ad;
        }).toList();
        state = AsyncValue.data(updated);
      }
      return success;
    } catch (e) {
      print('Error updating ad: $e');
      return false;
    }
  }

  Future<bool> deleteAd(String adId) async {
    try {
      final success = await _adService.deleteAd(adId);
      if (success) {
        final current = state.whenData((ads) => ads).value ?? [];
        state = AsyncValue.data(current.where((ad) => ad.id != adId).toList());
      }
      return success;
    } catch (e) {
      print('Error deleting ad: $e');
      return false;
    }
  }
}
