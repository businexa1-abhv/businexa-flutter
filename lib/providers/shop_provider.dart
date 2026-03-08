import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/shop_service.dart';
import '../models/shop_model.dart';

// Shop service provider
final shopServiceProvider = Provider<ShopService>((ref) {
  return ShopService();
});

// Get shop by ID
final shopByIdProvider = FutureProvider.family<Shop?, String>((ref, shopId) async {
  final shopService = ref.watch(shopServiceProvider);
  return await shopService.getShopById(shopId);
});

// Get shop by slug
final shopBySlugProvider = FutureProvider.family<Shop?, String>((ref, slug) async {
  final shopService = ref.watch(shopServiceProvider);
  return await shopService.getShopBySlug(slug);
});

// Get shop by owner ID
final shopByOwnerIdProvider = FutureProvider.family<Shop?, String>((ref, ownerId) async {
  final shopService = ref.watch(shopServiceProvider);
  return await shopService.getShopByOwnerId(ownerId);
});

// Check subscription status
final isSubscriptionActiveProvider = FutureProvider.family<bool, String>((ref, shopId) async {
  final shopService = ref.watch(shopServiceProvider);
  return await shopService.isSubscriptionActive(shopId);
});

// Shop state notifier
final shopProvider = StateNotifierProvider<ShopNotifier, AsyncValue<Shop?>>((ref) {
  final shopService = ref.watch(shopServiceProvider);
  return ShopNotifier(shopService);
});

class ShopNotifier extends StateNotifier<AsyncValue<Shop?>> {
  final ShopService _shopService;

  ShopNotifier(this._shopService) : super(const AsyncValue.data(null));

  Future<bool> createShop({
    required String ownerId,
    required String shopName,
    required String address,
    required String category,
    required String whatsappNumber,
    String? email,
  }) async {
    try {
      state = const AsyncValue.loading();
      final shop = await _shopService.createShop(
        ownerId: ownerId,
        shopName: shopName,
        address: address,
        category: category,
        whatsappNumber: whatsappNumber,
        email: email,
      );

      if (shop == null) {
        throw Exception('Failed to create shop');
      }

      state = AsyncValue.data(shop);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> loadShop(String shopId) async {
    try {
      state = const AsyncValue.loading();
      final shop = await _shopService.getShopById(shopId);
      state = AsyncValue.data(shop);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadShopByOwner(String ownerId) async {
    try {
      state = const AsyncValue.loading();
      final shop = await _shopService.getShopByOwnerId(ownerId);
      state = AsyncValue.data(shop);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateShop(String shopId, Map<String, dynamic> data) async {
    try {
      final success = await _shopService.updateShop(shopId, data);
      if (success) {
        final current = state.whenData((shop) => shop).value;
        if (current != null) {
          final updated = current.copyWith(
            shopName: data['shopName'] ?? current.shopName,
            address: data['address'] ?? current.address,
            category: data['category'] ?? current.category,
            whatsappNumber: data['whatsappNumber'] ?? current.whatsappNumber,
          );
          state = AsyncValue.data(updated);
        }
      }
      return success;
    } catch (e) {
      print('Error updating shop: $e');
      return false;
    }
  }
}
