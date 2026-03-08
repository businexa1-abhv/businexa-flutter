import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/theme.dart';

/// Public Ad Page
/// Shared page that users can send to customers to view advertisements
/// Tracked for QR code scans and engagement
class PublicAdPage extends ConsumerStatefulWidget {
  final String slug;

  const PublicAdPage({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<PublicAdPage> createState() => _PublicAdPageState();
}

class _PublicAdPageState extends ConsumerState<PublicAdPage> {
  @override
  void initState() {
    super.initState();
    // TODO: Record scan event in Firebase
    // ref.read(scanTrackingService).recordScan(adId, slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Businexa',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Product Details',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _shareAd,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Product Image (Placeholder)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image,
                              size: 80, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Product Info
                      Text(
                        'Sample Product',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Category
                      Chip(
                        label: const Text('Electronics'),
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                        labelStyle: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Price
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '₹999',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This is a high-quality product with excellent features and durability. Perfect for your needs and offers great value for money.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),

                      // Features List
                      Text(
                        'Features',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ..._buildFeatureList(context),
                      const SizedBox(height: 32),

                      // Contact Info
                      Text(
                        'Contact Seller',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _ContactButton(
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onPressed: _contactWhatsApp,
                      ),
                      const SizedBox(height: 12),
                      _ContactButton(
                        icon: Icons.phone,
                        label: 'Call',
                        color: AppTheme.primaryColor,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      _ContactButton(
                        icon: Icons.email,
                        label: 'Email',
                        color: Colors.red,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(BuildContext context) {
    final features = [
      'High Quality Material',
      'Durable & Long Lasting',
      'Easy to Use',
      'Great Value for Money',
    ];

    return features
        .map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    feature,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ))
        .toList();
  }

  void _shareAd() {
    // Copy link to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share link: https://businexa.com/ad/${widget.slug}'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _contactWhatsApp() async {
    // TODO: Replace with actual seller's WhatsApp number
    const whatsappUrl = 'https://wa.me/919876543210';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    }
  }
}

/// Contact Button Widget
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
