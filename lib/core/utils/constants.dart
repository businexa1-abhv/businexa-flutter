/// App-wide constants
class Constants {
  // App Info
  static const String appName = 'Businexa';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'QR-based Advertisement Platform';

  // Firebase
  static const String firebaseProjectId = 'businexa-project';
  static const String firebaseWebApiKey = 'YOUR_WEB_API_KEY';

  // URLs
  static const String websiteDomain = 'businexa.com';
  static const String websiteUrl = 'https://businexa.com';
  static const String publicBaseUrl = 'https://businexa.com';

  // Timeouts
  static const Duration callTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(seconds: 30);

  // Pagination
  static const int pageSize = 20;
  static const int adPageSize = 20;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String shopsCollection = 'shops';
  static const String adsCollection = 'ads';
  static const String scansCollection = 'scans';
  static const String subscriptionsCollection = 'subscriptions';
  static const String otpVerificationsCollection = 'otp_verifications';

  // Storage Paths
  static const String productsStoragePath = 'products';
  static const String shopImagesStoragePath = 'shops';

  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'monthly': {
      'name': 'Monthly',
      'price': 99,
      'currency': 'INR',
      'duration': 30,
      'features': ['QR Code', 'Basic Analytics', '100 Products'],
    },
    'quarterly': {
      'name': 'Quarterly',
      'price': 279,
      'currency': 'INR',
      'duration': 90,
      'features': ['QR Code', 'Advanced Analytics', 'Unlimited Products'],
    },
    'halfyearly': {
      'name': 'Half-Yearly',
      'price': 499,
      'currency': 'INR',
      'duration': 180,
      'features': [
        'QR Code',
        'Advanced Analytics',
        'Unlimited Products',
        'Priority Support'
      ],
    },
    'yearly': {
      'name': 'Yearly',
      'price': 899,
      'currency': 'INR',
      'duration': 365,
      'features': [
        'QR Code',
        'Advanced Analytics',
        'Unlimited Products',
        'Priority Support',
        'Dedicated Account Manager'
      ],
    },
  };

  // Product Categories
  static const List<String> productCategories = [
    'Retail',
    'Restaurant',
    'Services',
    'Electronics',
    'Fashion',
    'Grocery',
    'Pharmacy',
    'Other'
  ];

  // OTP Settings
  static const int otpLength = 6;
  static const Duration otpValidity = Duration(minutes: 10);
  static const int maxOtpRetries = 3;
  static const Duration otpRetryWindow = Duration(minutes: 30);

  // Trial Period
  static const int trialDays = 30;

  static const String whatsappBaseUrl = 'https://wa.me';

  // Regex Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[0-9]{10}$';
  static const String passwordPattern =
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$';
}
