import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../core/services/auth_service.dart';
import '../core/services/user_service.dart';
import '../models/user_model.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Firebase auth state changes
final firebaseAuthStateProvider = StreamProvider<fb_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user data provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);
  
  final firebaseUser = authService.currentUser;
  if (firebaseUser == null) return null;
  
  return await userService.getUserProfile(firebaseUser.uid);
});

// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUserId;
});

// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);
  return AuthStateNotifier(authService, userService);
});

// Send OTP provider
final sendOTPProvider = FutureProvider.family<bool, String>((ref, phoneNumber) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.sendOTP(phoneNumber);
});

// Verify OTP provider
final verifyOTPProvider = FutureProvider.family<String?, (String, String)>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.verifyOTPAndLogin(params.$1, params.$2);
});

// Auth state notifier
class AuthStateNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final UserService _userService;

  AuthStateNotifier(this._authService, this._userService) 
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final user = await _userService.getUserProfile(firebaseUser.uid);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendOTP(String phoneNumber) async {
    try {
      final success = await _authService.sendOTP(phoneNumber);
      if (!success) {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  Future<bool> verifyOTPAndLogin(String phoneNumber, String otp) async {
    try {
      state = const AsyncValue.loading();
      final userId = await _authService.verifyOTPAndLogin(phoneNumber, otp);
      
      if (userId == null) {
        throw Exception('OTP verification failed');
      }

      final user = await _userService.getUserProfile(userId);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
