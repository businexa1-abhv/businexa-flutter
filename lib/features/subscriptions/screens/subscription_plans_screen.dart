import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/theme.dart';

/// Subscription Plans Screen
/// Displays available subscription tiers with features and pricing
/// Allows users to select and purchase plans
class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Subscription Plans'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 24),
              Text(
                'Choose Your Plan',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a plan that works best for your business',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Plans Grid
              ..._buildPlanCards(context),

              const SizedBox(height: 40),

              // Features Comparison
              Text(
                'What\'s Included',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _FeaturesComparisonTable(),

              const SizedBox(height: 40),

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const _FAQItem(
                question: 'Can I cancel my subscription anytime?',
                answer:
                    'Yes, you can cancel your subscription at any time. You will have access until the end of your billing cycle.',
              ),
              const _FAQItem(
                question: 'Can I upgrade or downgrade my plan?',
                answer:
                    'Yes, you can change your plan at any time. The new price will be calculated on a pro-rata basis.',
              ),
              const _FAQItem(
                question: 'Do you offer refunds?',
                answer:
                    'We offer a 7-day money-back guarantee if you are not satisfied with our service.',
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPlanCards(BuildContext context) {
    final plansList = Constants.subscriptionPlans.values.toList();
    return plansList.map((plan) {
      final isPopular = plan['name'] == 'Quarterly';
      final durationText = '${plan['duration']} days';
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isPopular
                  ? AppTheme.primaryColor
                  : Theme.of(context).dividerColor,
              width: isPopular ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Name
                    Text(
                      plan['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Duration
                    Text(
                      durationText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${plan['price']}',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '/${plan['name'].toLowerCase()}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Savings Badge (if applicable)
                    if (plan['savings'] != null)
                      Chip(
                        label: Text('Save ${plan['savings']}%'),
                        backgroundColor: Colors.green.withValues(alpha: 0.2),
                        labelStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Features List
                    ...(plan['features'] as List<String>).map((feature) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/payment', extra: plan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPopular
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          foregroundColor:
                              isPopular ? Colors.white : AppTheme.primaryColor,
                          side: isPopular
                              ? null
                              : const BorderSide(
                                  color: AppTheme.primaryColor,
                                ),
                        ),
                        child: const Text('Choose Plan'),
                      ),
                    ),
                  ],
                ),
              ),
              if (isPopular)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Text(
                      'Most Popular',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

/// Features Comparison Table Widget
class _FeaturesComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _ComparisonRow(
              feature: 'QR Code Generation',
              monthly: true,
              quarterly: true,
              halfYearly: true,
              yearly: true,
            ),
            _ComparisonRow(
              feature: 'Scan Analytics',
              monthly: true,
              quarterly: true,
              halfYearly: true,
              yearly: true,
            ),
            _ComparisonRow(
              feature: 'Public Shop Page',
              monthly: true,
              quarterly: true,
              halfYearly: true,
              yearly: true,
            ),
            _ComparisonRow(
              feature: 'Priority Support',
              monthly: false,
              quarterly: true,
              halfYearly: true,
              yearly: true,
            ),
            _ComparisonRow(
              feature: 'Advanced Analytics',
              monthly: false,
              quarterly: false,
              halfYearly: true,
              yearly: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Comparison Row Widget
class _ComparisonRow extends StatelessWidget {
  final String feature;
  final bool monthly;
  final bool quarterly;
  final bool halfYearly;
  final bool yearly;

  const _ComparisonRow({
    required this.feature,
    required this.monthly,
    required this.quarterly,
    required this.halfYearly,
    required this.yearly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  feature,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    monthly ? Icons.check : Icons.close,
                    color: monthly ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    quarterly ? Icons.check : Icons.close,
                    color: quarterly ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    halfYearly ? Icons.check : Icons.close,
                    color: halfYearly ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    yearly ? Icons.check : Icons.close,
                    color: yearly ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }
}

/// FAQ Item Widget
class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
