import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/constants.dart';

// Subscription plans provider
final subscriptionPlansProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
  return Constants.subscriptionPlans;
});

// Get single plan provider
final subscriptionPlanProvider = Provider.family<Map<String, dynamic>?, String>((ref, planId) {
  final plans = ref.watch(subscriptionPlansProvider);
  return plans[planId];
});

// User subscription notifier
final userSubscriptionProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  SubscriptionNotifier() : super(const AsyncValue.data(null));

  void setSubscription(Map<String, dynamic> subscription) {
    state = AsyncValue.data(subscription);
  }

  void clearSubscription() {
    state = const AsyncValue.data(null);
  }

  bool isSubscriptionActive(Map<String, dynamic>? subscription) {
    if (subscription == null) return false;
    
    final expiresAt = subscription['expiresAt'] as DateTime?;
    if (expiresAt == null) return false;
    
    return DateTime.now().isBefore(expiresAt);
  }

  bool isTrialActive(Map<String, dynamic>? subscription) {
    if (subscription == null) return false;
    return subscription['status'] == 'trial' && isSubscriptionActive(subscription);
  }

  String getTimeUntilExpiry(Map<String, dynamic>? subscription) {
    if (subscription == null) return 'No subscription';
    
    final expiresAt = subscription['expiresAt'] as DateTime?;
    if (expiresAt == null) return 'Invalid date';
    
    final daysLeft = expiresAt.difference(DateTime.now()).inDays;
    
    if (daysLeft <= 0) return 'Expired';
    if (daysLeft == 1) return '1 day left';
    return '$daysLeft days left';
  }
}
