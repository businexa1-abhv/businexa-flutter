import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  final String id;
  final String ownerId;
  final String shopName;
  final String? address;
  final String? category;
  final String? whatsappNumber;
  final String slug;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  Shop({
    required this.id,
    required this.ownerId,
    required this.shopName,
    this.address,
    this.category,
    this.whatsappNumber,
    required this.slug,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'shopName': shopName,
      'address': address,
      'category': category,
      'whatsappNumber': whatsappNumber,
      'slug': slug,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore document
  factory Shop.fromMap(Map<String, dynamic> map, String docId) {
    return Shop(
      id: docId,
      ownerId: map['ownerId'] ?? '',
      shopName: map['shopName'] ?? '',
      address: map['address'],
      category: map['category'],
      whatsappNumber: map['whatsappNumber'],
      slug: map['slug'] ?? '',
      email: map['email'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Shop copyWith({
    String? id,
    String? ownerId,
    String? shopName,
    String? address,
    String? category,
    String? whatsappNumber,
    String? slug,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shop(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      category: category ?? this.category,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      slug: slug ?? this.slug,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get shop public URL
  String getPublicUrl(String domain) {
    return '$domain/shop/$slug';
  }
}
