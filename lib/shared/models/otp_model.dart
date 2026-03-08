import 'package:cloud_firestore/cloud_firestore.dart';

class OtpModel {
  final String id;
  final String mobileNumber;
  final String otpHash;
  final bool? verified;
  final DateTime expiresAt;
  final DateTime createdAt;

  OtpModel({
    required this.id,
    required this.mobileNumber,
    required this.otpHash,
    this.verified,
    required this.expiresAt,
    required this.createdAt,
  });

  factory OtpModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return OtpModel(
      id: docId,
      mobileNumber: data['mobile_number'] ?? '',
      otpHash: data['otp_hash'] ?? '',
      verified: data['verified'] ?? false,
      expiresAt: (data['expires_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'mobile_number': mobileNumber,
    'otp_hash': otpHash,
    'verified': verified,
    'expires_at': Timestamp.fromDate(expiresAt),
    'created_at': Timestamp.fromDate(createdAt),
  };

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isValid {
    return !isExpired && verified == false;
  }

  OtpModel copyWith({
    String? id,
    String? mobileNumber,
    String? otpHash,
    bool? verified,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) =>
      OtpModel(
        id: id ?? this.id,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        otpHash: otpHash ?? this.otpHash,
        verified: verified ?? this.verified,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt ?? this.createdAt,
      );
}
