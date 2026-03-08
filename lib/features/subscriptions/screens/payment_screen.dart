import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/theme.dart';

/// Payment/Checkout Screen
/// Processes subscription payment using Razorpay
class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> plan;

  const PaymentScreen({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Order Summary
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Plan Card
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.plan['name'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.plan['duration']} days',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Text(
                          '₹${widget.plan['price']}',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                    const SizedBox(height: 20),

                    // Price Breakdown
                    _PricingRow(
                      label: 'Subtotal',
                      value: '₹${widget.plan['price']}',
                    ),
                    const SizedBox(height: 12),
                    _PricingRow(
                      label: 'Tax (18% GST)',
                      value:
                          '₹${(widget.plan['price'] * 0.18).toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                    const SizedBox(height: 12),
                    _PricingRow(
                      label: 'Total Amount',
                      value:
                          '₹${(widget.plan['price'] * 1.18).toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Payment Details
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Payment Method
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Razorpay Payment Gateway',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Secure online payment',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // Terms & Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'By proceeding, you agree to our Terms & Conditions and Privacy Policy',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Proceed to Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Secure Payment',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Payments are processed securely by Razorpay\n'
                        '• Your payment information is encrypted\n'
                        '• No refund after payment is processed\n'
                        '• For refund queries, contact support',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() => _errorMessage = null);
    setState(() => _isProcessing = true);

    try {
      // TODO: Integrate with Razorpay
      // 1. Initialize Razorpay with your key
      // 2. Create order on backend
      // 3. Initialize payment with Razorpay
      // 4. Handle payment success/failure

      // For now, simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Simulate payment success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Subscription activated.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Payment failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

/// Pricing Row Widget
class _PricingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PricingRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.labelMedium,
        ),
        Text(
          value,
          style: isBold
              ? Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
