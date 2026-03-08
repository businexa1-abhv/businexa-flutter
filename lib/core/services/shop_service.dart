import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/shop_model.dart';

class ShopService {
  final _firestore = FirebaseFirestore.instance;
  static const uuid = Uuid();

  /// Create a new shop
  Future<Shop?> createShop({
    required String ownerId,
    required String shopName,
    required String address,
    required String category,
    required String whatsappNumber,
    String? email,
  }) async {
    try {
      final shopId = uuid.v4();
      final slug = _generateSlug(shopName);

      final shop = Shop(
        id: shopId,
        ownerId: ownerId,
        shopName: shopName,
        address: address,
        category: category,
        whatsappNumber: whatsappNumber,
        slug: slug,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('shops').doc(shopId).set(shop.toMap());

      // Initialize free trial subscription
      await _firestore.collection('shops').doc(shopId).collection('subscriptions').add({
        'planId': 'free',
        'status': 'trial',
        'expiresAt': DateTime.now().add(const Duration(days: 30)),
        'createdAt': DateTime.now(),
      });

      return shop;
    } catch (e) {
      print('Error creating shop: $e');
      return null;
    }
  }

  /// Get shop by ID
  Future<Shop?> getShopById(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();
      if (!doc.exists) return null;
      return Shop.fromMap(doc.data()!, shopId);
    } catch (e) {
      print('Error fetching shop: $e');
      return null;
    }
  }

  /// Get shop by slug
  Future<Shop?> getShopBySlug(String slug) async {
    try {
      final query = await _firestore
          .collection('shops')
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return Shop.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      print('Error fetching shop by slug: $e');
      return null;
    }
  }

  /// Get shop by owner ID
  Future<Shop?> getShopByOwnerId(String ownerId) async {
    try {
      final query = await _firestore
          .collection('shops')
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return Shop.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      print('Error fetching shop by owner: $e');
      return null;
    }
  }

  /// Update shop details
  Future<bool> updateShop(String shopId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.collection('shops').doc(shopId).update(data);
      return true;
    } catch (e) {
      print('Error updating shop: $e');
      return false;
    }
  }

  /// Delete shop
  Future<bool> deleteShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).delete();
      return true;
    } catch (e) {
      print('Error deleting shop: $e');
      return false;
    }
  }

  /// Check if slug is available
  Future<bool> isSlugAvailable(String slug) async {
    try {
      final query = await _firestore
          .collection('shops')
          .where('slug', isEqualTo: slug)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      print('Error checking slug availability: $e');
      return true;
    }
  }

  /// Generate slug from shop name
  String _generateSlug(String shopName) {
    String baseSlug = shopName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .substring(0, 50);

    return baseSlug;
  }

  /// Verify subscription is active
  Future<bool> isSubscriptionActive(String shopId) async {
    try {
      final query = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('subscriptions')
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: DateTime.now())
          .limit(1)
          .get();

      // Also check for trial status
      if (query.docs.isEmpty) {
        final trialQuery = await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('subscriptions')
            .where('status', isEqualTo: 'trial')
            .where('expiresAt', isGreaterThan: DateTime.now())
            .limit(1)
            .get();

        return trialQuery.docs.isNotEmpty;
      }

      return true;
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }
}
