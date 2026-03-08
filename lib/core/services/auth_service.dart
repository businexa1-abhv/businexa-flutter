import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Get current user UID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Send OTP to mobile number
  /// Returns true if OTP was sent successfully
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      // Format phone number
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      // Check rate limiting (max 3 requests per 30 minutes)
      final recentOtps = await _firestore
          .collection('otp_verifications')
          .where('mobileNumber', isEqualTo: formattedPhone)
          .where('createdAt',
              isGreaterThan: DateTime.now().subtract(const Duration(minutes: 30)))
          .get();

      if (recentOtps.docs.length >= 3) {
        throw Exception('Too many OTP requests. Try again later.');
      }

      // Generate random 6-digit OTP
      final otp = _generateOTP();

      // Hash OTP (simplified - in production use bcrypt)
      final otpHash = otp.hashCode.toString();

      // Store OTP in Firestore
      await _firestore.collection('otp_verifications').add({
        'mobileNumber': formattedPhone,
        'otpHash': otpHash,
        'otp': otp, // For development only - remove in production
        'expiresAt': DateTime.now().add(const Duration(minutes: 10)),
        'verified': false,
        'createdAt': DateTime.now(),
      });

      // In production, send SMS here
      // For development, return OTP
      print('DEBUG: OTP for $formattedPhone is $otp');

      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  /// Verify OTP and authenticate user
  /// Returns user ID if successful, null otherwise
  Future<String?> verifyOTPAndLogin(String phoneNumber, String otp) async {
    try {
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      // Find OTP record
      final otpDoc = await _firestore
          .collection('otp_verifications')
          .where('mobileNumber', isEqualTo: formattedPhone)
          .where('verified', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (otpDoc.docs.isEmpty) {
        throw Exception('OTP not found');
      }

      final otpRecord = otpDoc.docs.first;
      final data = otpRecord.data();

      // Check if OTP is expired
      if ((data['expiresAt'] as Timestamp).toDate().isBefore(DateTime.now())) {
        throw Exception('OTP expired');
      }

      // Verify OTP hash
      final expectedHash = otp.hashCode.toString();
      if (data['otpHash'] != expectedHash) {
        // Also check plain OTP for development
        if (data['otp'] != otp) {
          throw Exception('Invalid OTP');
        }
      }

      // Mark OTP as verified
      await otpRecord.reference.update({'verified': true});

      // Create or update user with email/password auth
      final email = '${formattedPhone.replaceAll('+', '')}@businexa.local';
      final password = 'Auth@${formattedPhone.replaceAll('+', '')}#Businexa';

      firebase_auth.UserCredential? authResult;

      try {
        // Try to sign in
        authResult = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Create new user
          authResult = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Create user profile in Firestore
          await _firestore.collection('users').doc(authResult.user!.uid).set({
            'mobileNumber': formattedPhone,
            'email': email,
            'subscriptionPlan': 'free',
            'subscriptionStatus': 'trial',
            'subscriptionExpiry':
                DateTime.now().add(const Duration(days: 30)), // 30-day free trial
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          });
        } else {
          rethrow;
        }
      }

      return authResult.user?.uid;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Generate random 6-digit OTP
  String _generateOTP() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
  }

  /// Format phone number to E.164 format
  String _formatPhoneNumber(String phoneNumber) {
    // Remove non-numeric characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // If 10 digits (Indian mobile), prepend +91
    if (cleaned.length == 10) {
      return '+91$cleaned';
    }

    // If already has country code
    if (cleaned.length > 10) {
      return '+$cleaned';
    }

    return '+$cleaned';
  }

  /// Get current user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;
}
