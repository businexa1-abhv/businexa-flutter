import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  /// Create user profile
  Future<User?> createUserProfile({
    required String userId,
    required String mobileNumber,
    String? displayName,
    String? email,
  }) async {
    try {
      final now = DateTime.now();
      final user = User(
        id: userId,
        mobileNumber: mobileNumber,
        displayName: displayName,
        email: email,
        subscriptionPlan: 'free',
        subscriptionStatus: 'trial',
        subscriptionExpiry: now.add(const Duration(days: 30)), // 30-day trial
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(userId).set(user.toMap());
      return user;
    } catch (e) {
      print('Error creating user profile: $e');
      return null;
    }
  }

  /// Get user profile
  Future<User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return User.fromMap(doc.data()!, userId);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.collection('users').doc(userId).update(data);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Update subscription status
  Future<bool> updateSubscription({
    required String userId,
    required String plan,
    required String status,
    required DateTime expiryDate,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'subscriptionPlan': plan,
        'subscriptionStatus': status,
        'subscriptionExpiry': expiryDate,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }

  /// Check if subscription is active
  Future<bool> isSubscriptionActive(String userId) async {
    try {
      final user = await getUserProfile(userId);
      if (user == null) return false;
      return user.isSubscriptionActive();
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// Get user by mobile number
  Future<User?> getUserByMobileNumber(String mobileNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('mobileNumber', isEqualTo: mobileNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return User.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      print('Error fetching user by mobile: $e');
      return null;
    }
  }

  /// Stream user profile changes
  Stream<User?> streamUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return User.fromMap(doc.data()!, userId);
    });
  }
}
