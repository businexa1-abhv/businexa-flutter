import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/ads/screens/create_ad_screen.dart';
import '../../features/ads/screens/my_ads_screen.dart';
import '../../features/ads/screens/public_ad_page.dart';
import '../../features/subscriptions/screens/subscription_plans_screen.dart';
import '../../features/subscriptions/screens/payment_screen.dart';
import '../../features/shops/screens/public_shop_page.dart';
import '../../features/account/screens/account_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/account/screens/help_screen.dart';

// Define route names
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String businessDetails = '/business-details';
  static const String dashboard = '/dashboard';
  static const String createAd = '/create-ad';
  static const String editAd = '/edit-ad/:id';
  static const String myAds = '/my-ads';
  static const String adDetail = '/ad-detail/:id';
  static const String publicAd = '/ad/:slug';
  static const String settings = '/settings';
  static const String account = '/account';
  static const String subscriptions = '/subscriptions';
  static const String help = '/help';
  static const String notFound = '/404';
}

// Create a GoRouter configuration
final goRouter = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,
  routes: [
    // Splash Screen
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),

    // Home Screen
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) {
        return const Placeholder(); // Replace with HomeScreen
      },
    ),

    // Login Screen
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    // OTP Screen
    GoRoute(
      path: Routes.otp,
      name: 'otp',
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '+91';
        return OTPScreen(phoneNumber: phoneNumber);
      },
    ),

    // Register Screen
    GoRoute(
      path: Routes.register,
      name: 'register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),

    // Business Details Screen
    GoRoute(
      path: Routes.businessDetails,
      name: 'businessDetails',
      builder: (context, state) {
        return const Placeholder(); // Replace with BusinessDetailsScreen
      },
    ),

    // Dashboard Screen
    GoRoute(
      path: Routes.dashboard,
      name: 'dashboard',
      builder: (context, state) {
        return const DashboardScreen();
      },
    ),

    // Create Ad Screen
    GoRoute(
      path: Routes.createAd,
      name: 'createAd',
      builder: (context, state) {
        return const CreateAdScreen();
      },
    ),

    // Edit Ad Screen
    GoRoute(
      path: Routes.editAd,
      name: 'editAd',
      builder: (context, state) {
        return const Placeholder(); // Replace with EditAdScreen(adId: state.pathParameters['id'])
      },
    ),

    // My Ads Screen
    GoRoute(
      path: Routes.myAds,
      name: 'myAds',
      builder: (context, state) {
        return const MyAdsScreen();
      },
    ),

    // Ad Detail Screen
    GoRoute(
      path: Routes.adDetail,
      name: 'adDetail',
      builder: (context, state) {
        return const Placeholder(); // Replace with AdDetailScreen(adId: state.pathParameters['id'])
      },
    ),

    // Public Ad Screen (deep link support)
    GoRoute(
      path: Routes.publicAd,
      name: 'publicAd',
      builder: (context, state) {
        final slug = state.pathParameters['slug'];
        if (slug == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid ad slug'),
            ),
          );
        }
        return PublicAdPage(slug: slug);
      },
    ),

    // Public Shop Screen
    GoRoute(
      path: '/shop/:slug',
      name: 'publicShop',
      builder: (context, state) {
        final slug = state.pathParameters['slug'];
        if (slug == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid shop slug'),
            ),
          );
        }
        return PublicShopPage(shopSlug: slug);
      },
    ),

    // Settings Screen
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      builder: (context, state) {
        return const SettingsScreen();
      },
    ),

    // Account Screen
    GoRoute(
      path: Routes.account,
      name: 'account',
      builder: (context, state) {
        return const AccountScreen();
      },
    ),

    // Subscriptions Screen
    GoRoute(
      path: Routes.subscriptions,
      name: 'subscriptions',
      builder: (context, state) {
        return const SubscriptionPlansScreen();
      },
    ),

    // Payment Screen
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) {
        final plan = state.extra as Map<String, dynamic>?;
        if (plan == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid plan selected'),
            ),
          );
        }
        return PaymentScreen(plan: plan);
      },
    ),

    // Help Screen
    GoRoute(
      path: Routes.help,
      name: 'help',
      builder: (context, state) {
        return const HelpScreen();
      },
    ),

    // 404 Not Found
    GoRoute(
      path: Routes.notFound,
      name: '404',
      builder: (context, state) {
        return const Placeholder(); // Replace with NotFoundScreen
      },
    ),
  ],
  errorBuilder: (context, state) {
    return const Placeholder(); // Replace with ErrorScreen
  },
);
