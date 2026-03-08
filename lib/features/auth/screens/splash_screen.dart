import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/theme.dart';

/// Splash Screen
/// Shows logo/branding while checking authentication state
/// Automatically navigates to appropriate screen based on auth status
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check authentication after initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });

    // Force navigation to login after 6 seconds if not already navigated
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  Future<void> _checkAuthState() async {
    // Wait a moment for Firebase initialization
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (!mounted) return;
        if (user != null) {
          // User is authenticated - go to dashboard
          context.go('/dashboard');
        } else {
          // User not authenticated - go to login
          context.go('/login');
        }
      },
      loading: () {
        // Still loading, timeout will handle navigation
      },
      error: (error, stackTrace) {
        // On error, go to login
        if (mounted) {
          context.go('/login');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Branding
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Businexa',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              'QR-Based Advertisements',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 60),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),

            // Loading Text
            Text(
              'Initializing...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
