import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ad_provider.dart';
import '../../../models/user_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../core/utils/theme.dart';

/// Dashboard Screen
/// Main hub after authentication
/// Shows user's ads, subscription status, and QR codes
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
        loading: () => const Scaffold(
              body: LoadingIndicator(),
            ),
        error: (error, st) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Failed to load user data'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // ignore: unused_result
                        ref.refresh(currentUserProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        data: (user) {
          if (user == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('User data not available'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // ignore: unused_result
                        ref.refresh(currentUserProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppHeader(
              title: 'Dashboard',
              showBackButton: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final authNotifier = ref.read(authStateProvider.notifier);
                    await authNotifier.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.list_alt),
                    text: 'My Ads',
                  ),
                  Tab(
                    icon: Icon(Icons.card_giftcard),
                    text: 'Subscription',
                  ),
                  Tab(
                    icon: Icon(Icons.qr_code_2),
                    text: 'QR Codes',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: My Ads
                _AdsTab(),
                // Tab 2: Subscription
                _SubscriptionTab(user: user),
                // Tab 3: QR Codes
                _QRCodesTab(),
              ],
            ),
            floatingActionButton: _tabController.index == 0
                ? FloatingActionButton(
                    onPressed: () => context.push('/create-ad'),
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        });
  }
}

/// Ads Tab Widget
class _AdsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);

    if (currentUserId == null) {
      return const Center(child: Text('Not authenticated'));
    }

    final adList = ref.watch(adListProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Advertisements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/my-ads'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ads List or Empty State
            adList.when(
              loading: () => const LoadingIndicator(),
              error: (error, st) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                  ],
                ),
              ),
              data: (ads) {
                if (ads.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image,
                          size: 48,
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No advertisements yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first QR-based advertisement',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Create Advertisement',
                          onPressed: () => context.push('/create-ad'),
                          isExpanded: true,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ads.take(3).length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ad.imageUrl.isNotEmpty
                              ? Image.network(
                                  ad.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image);
                                  },
                                )
                              : const Icon(Icons.image),
                        ),
                        title: Text(ad.title),
                        subtitle: Text('₹${ad.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => context.push('/ad-detail/${ad.id}'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Subscription Tab Widget
class _SubscriptionTab extends ConsumerWidget {
  final User user;

  const _SubscriptionTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionActive = user.isSubscriptionActive();
    final daysLeft = user.subscriptionExpiry.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Subscription Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Plan',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      Chip(
                        label: Text(
                          subscriptionActive ? 'Active' : 'Expired',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: subscriptionActive
                            ? Colors.green.withValues(alpha: 0.7)
                            : Colors.red.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.subscriptionPlan.toUpperCase(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subscriptionActive
                        ? '$daysLeft days remaining'
                        : 'Subscription expired',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/subscriptions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('View Plans'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Subscription Benefits
            Text(
              'Plan Benefits',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const _BenefitItem(
              icon: Icons.qr_code_2,
              title: 'QR Code Generation',
              description: 'Create QR codes for your advertisements',
            ),
            const _BenefitItem(
              icon: Icons.analytics,
              title: 'Scan Analytics',
              description: 'Track how many times your ads are scanned',
            ),
            const _BenefitItem(
              icon: Icons.language,
              title: 'Public Shop Page',
              description: 'Get a public page to showcase your ads',
            ),
          ],
        ),
      ),
    );
  }
}

/// Benefit Item Widget
class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// QR Codes Tab Widget
class _QRCodesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QR Codes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Generate and download QR codes for your advertisements',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'QR codes are available only with an active subscription',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Features List
            const _FeatureItem(
              icon: Icons.download,
              title: 'Download QR Codes',
              description: 'Download QR codes in PNG format for printing',
            ),
            const _FeatureItem(
              icon: Icons.share,
              title: 'Share on WhatsApp',
              description: 'Share your ads directly on WhatsApp',
            ),
            const _FeatureItem(
              icon: Icons.link,
              title: 'Copy Link',
              description: 'Copy the ad link to clipboard',
            ),
            const SizedBox(height: 24),

            // CTA Button
            AppButton(
              label: 'View My Ads',
              onPressed: () => context.push('/my-ads'),
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature Item Widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
