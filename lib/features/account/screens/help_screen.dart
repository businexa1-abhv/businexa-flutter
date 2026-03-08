import 'package:flutter/material.dart';

import '../../../core/utils/theme.dart';

/// Help/FAQ Screen
/// Provides frequently asked questions and support information
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Help
              Text(
                'Quick Help',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _HelpCard(
                icon: Icons.phone,
                title: 'Call Support',
                subtitle: '+91-1234-567890',
                onTap: () {},
              ),
              _HelpCard(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@businexa.com',
                onTap: () {},
              ),
              _HelpCard(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () {},
              ),
              const SizedBox(height: 32),

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const _FAQItem(
                question: 'How do I create an advertisement?',
                answer:
                    'Go to the Dashboard and click the "Create Advertisement" button. Fill in the details like title, description, price, and upload an image. Your ad will be live immediately.',
              ),
              const _FAQItem(
                question: 'What subscription plans are available?',
                answer:
                    'We offer 4 subscription plans: Monthly (₹99), Quarterly (₹279), Half-Yearly (₹499), and Yearly (₹899). Each plan includes different features.',
              ),
              const _FAQItem(
                question: 'How do QR codes work?',
                answer:
                    'QR codes are generated for each advertisement. When customers scan the QR code, they are taken to your product details page. We track all scans for you.',
              ),
              const _FAQItem(
                question: 'Can I edit my advertisements?',
                answer:
                    'Yes! You can edit any of your advertisements from the "My Ads" section. Changes are reflected immediately.',
              ),
              const _FAQItem(
                question: 'How do I share my products with customers?',
                answer:
                    'You can share the QR code from your ad or send customers the public link. Both will take them directly to your product details page.',
              ),
              const _FAQItem(
                question: 'What payment methods do you accept?',
                answer:
                    'We accept all major payment methods including credit cards, debit cards, net banking, and UPI through Razorpay.',
              ),
              const _FAQItem(
                question: 'Can I cancel my subscription?',
                answer:
                    'Yes, you can cancel your subscription at any time. You will have access until the end of your billing cycle.',
              ),
              const _FAQItem(
                question: 'How is my data protected?',
                answer:
                    'We use industry-standard encryption and follow all data protection regulations. Your data is never shared with third parties.',
              ),
              const SizedBox(height: 32),

              // Still Need Help
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still need help?',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our support team is available 24/7 to help you with any questions or issues.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Contact Support'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Help Card Widget
class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).hintColor,
        ),
        onTap: onTap,
      ),
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
  final bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: Theme.of(context).textTheme.labelMedium,
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
