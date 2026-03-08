import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/advertisement_model.dart';

class AdService {
  final _firestore = FirebaseFirestore.instance;
  static const uuid = Uuid();

  /// Create a new advertisement
  Future<Advertisement?> createAd({
    required String userId,
    required String shopId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    required double price,
  }) async {
    try {
      final adId = uuid.v4();
      final slug = _generateSlug(title);

      final ad = Advertisement(
        id: adId,
        userId: userId,
        shopId: shopId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        slug: slug,
        category: category,
        price: price,
        scanCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('ads').doc(adId).set(ad.toMap());
      return ad;
    } catch (e) {
      print('Error creating ad: $e');
      return null;
    }
  }

  /// Get advertisement by ID
  Future<Advertisement?> getAdById(String adId) async {
    try {
      final doc = await _firestore.collection('ads').doc(adId).get();
      if (!doc.exists) return null;
      return Advertisement.fromMap(doc.data()!, adId);
    } catch (e) {
      print('Error fetching ad: $e');
      return null;
    }
  }

  /// Get advertisement by slug
  Future<Advertisement?> getAdBySlug(String slug) async {
    try {
      final query = await _firestore
          .collection('ads')
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return Advertisement.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      print('Error fetching ad by slug: $e');
      return null;
    }
  }

  /// Get all ads for a shop (paginated)
  Future<List<Advertisement>> getAdsByShopId(
    String shopId, {
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('ads')
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final docs = await query.get();
      return docs.docs
          .map((doc) => Advertisement.fromMap(doc.data() as Map<String, dynamic>,
              doc.id))
          .toList();
    } catch (e) {
      print('Error fetching ads by shop: $e');
      return [];
    }
  }

  /// Get all ads for a user
  Future<List<Advertisement>> getAdsByUserId(String userId) async {
    try {
      final docs = await _firestore
          .collection('ads')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return docs.docs
          .map((doc) => Advertisement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching user ads: $e');
      return [];
    }
  }

  /// Update advertisement
  Future<bool> updateAd(String adId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.collection('ads').doc(adId).update(data);
      return true;
    } catch (e) {
      print('Error updating ad: $e');
      return false;
    }
  }

  /// Delete advertisement
  Future<bool> deleteAd(String adId) async {
    try {
      await _firestore.collection('ads').doc(adId).delete();
      return true;
    } catch (e) {
      print('Error deleting ad: $e');
      return false;
    }
  }

  /// Get ads by category
  Future<List<Advertisement>> getAdsByCategory(
    String shopId,
    String category,
  ) async {
    try {
      final docs = await _firestore
          .collection('ads')
          .where('shopId', isEqualTo: shopId)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return docs.docs
          .map((doc) => Advertisement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching ads by category: $e');
      return [];
    }
  }

  /// Generate slug from title
  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .substring(0, 50); // Limit to 50 chars
  }

  /// Search ads by title or description
  Future<List<Advertisement>> searchAds(String query) async {
    try {
      final docs = await _firestore
          .collection('ads')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .get();

      return docs.docs
          .map((doc) => Advertisement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error searching ads: $e');
      return [];
    }
  }
}
