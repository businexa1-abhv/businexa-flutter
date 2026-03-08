import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String mobileNumber;
  final String? displayName;
  final String? email;
  final String subscriptionPlan;
  final String subscriptionStatus; // active, inactive, trial
  final DateTime subscriptionExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.mobileNumber,
    this.displayName,
    this.email,
    this.subscriptionPlan = 'free',
    this.subscriptionStatus = 'trial',
    required this.subscriptionExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'mobileNumber': mobileNumber,
      'displayName': displayName,
      'email': email,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionExpiry': subscriptionExpiry,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore document
  factory User.fromMap(Map<String, dynamic> map, String userId) {
    return User(
      id: userId,
      mobileNumber: map['mobileNumber'] ?? '',
      displayName: map['displayName'],
      email: map['email'],
      subscriptionPlan: map['subscriptionPlan'] ?? 'free',
      subscriptionStatus: map['subscriptionStatus'] ?? 'trial',
      subscriptionExpiry: (map['subscriptionExpiry'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create from Firebase User
  factory User.fromFirebaseUser(String uid, String mobileNumber) {
    return User(
      id: uid,
      mobileNumber: mobileNumber,
      subscriptionExpiry: DateTime.now().add(const Duration(days: 30)), // 30-day free trial
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  User copyWith({
    String? id,
    String? mobileNumber,
    String? displayName,
    String? email,
    String? subscriptionPlan,
    String? subscriptionStatus,
    DateTime? subscriptionExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isSubscriptionActive() {
    return DateTime.now().isBefore(subscriptionExpiry);
  }
}
