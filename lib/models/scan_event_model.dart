import 'package:cloud_firestore/cloud_firestore.dart';

class ScanEvent {
  final String id;
  final String adId;
  final DateTime timestamp;
  final String? deviceInfo;
  final String? location;
  final String? userAgent;

  ScanEvent({
    required this.id,
    required this.adId,
    required this.timestamp,
    this.deviceInfo,
    this.location,
    this.userAgent,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'adId': adId,
      'timestamp': timestamp,
      'deviceInfo': deviceInfo,
      'location': location,
      'userAgent': userAgent,
    };
  }

  // Create from Firestore document
  factory ScanEvent.fromMap(Map<String, dynamic> map, String docId) {
    return ScanEvent(
      id: docId,
      adId: map['adId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      deviceInfo: map['deviceInfo'],
      location: map['location'],
      userAgent: map['userAgent'],
    );
  }
}
