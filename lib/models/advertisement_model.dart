import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisement {
  final String id;
  final String userId;
  final String shopId;
  final String title;
  final String description;
  final String imageUrl;
  final String slug;
  final String category;
  final double price;
  final int scanCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Advertisement({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.slug,
    required this.category,
    required this.price,
    this.scanCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shopId': shopId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'slug': slug,
      'category': category,
      'price': price,
      'scanCount': scanCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore document
  factory Advertisement.fromMap(Map<String, dynamic> map, String docId) {
    return Advertisement(
      id: docId,
      userId: map['userId'] ?? '',
      shopId: map['shopId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      slug: map['slug'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      scanCount: map['scanCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Advertisement copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? title,
    String? description,
    String? imageUrl,
    String? slug,
    String? category,
    double? price,
    int? scanCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Advertisement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      price: price ?? this.price,
      scanCount: scanCount ?? this.scanCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get public ad URL
  String getPublicUrl(String domain) {
    return '$domain/ad/$slug';
  }

  // Get QR code data
  String getQRData(String domain) {
    return getPublicUrl(domain);
  }
}
