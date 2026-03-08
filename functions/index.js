/**
 * Businexa - Firebase Cloud Function for OTP
 *
 * This function handles OTP generation and sending via Fast2SMS
 * Deploy to Firebase with: firebase deploy --only functions:sendOtp
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const crypto = require('crypto');

admin.initializeApp();
const db = admin.firestore();

// Constants
const FAST2SMS_API_KEY = process.env.FAST2SMS_API_KEY;
const FAST2SMS_URL = 'https://www.fast2sms.com/dev/bulkV2';
const OTP_LENGTH = 6;
const OTP_EXPIRY_MINUTES = 10;
const MAX_OTP_REQUESTS = 3;
const OTP_REQUEST_WINDOW_MINUTES = 30;

/**
 * Generate OTP
 */
function generateOTP() {
  return Math.floor(Math.random() * 900000) + 100000;
}

/**
 * Generate SHA-256 hash
 */
function hashOTP(otp) {
  return crypto.createHash('sha256').update(otp.toString()).digest('hex');
}

/**
 * Check if mobile number is valid (Indian format)
 */
function isValidMobileNumber(mobileNumber) {
  const regex = /^[6-9]\d{9}$/;
  return regex.test(mobileNumber);
}

/**
 * Check OTP request rate limiting
 */
async function checkRateLimit(mobileNumber) {
  const now = new Date();
  const windowStart = new Date(now.getTime() - OTP_REQUEST_WINDOW_MINUTES * 60 * 1000);

  const query = await db.collection('otp_verifications')
    .where('mobile_number', '==', mobileNumber)
    .where('created_at', '>=', windowStart)
    .get();

  return {
    canRequest: query.docs.length < MAX_OTP_REQUESTS,
    requestCount: query.docs.length,
    remaining: MAX_OTP_REQUESTS - query.docs.length
  };
}

/**
 * Send SMS via Fast2SMS
 */
async function sendSMS(mobileNumber, otp) {
  try {
    const message = `Your Businexa OTP is: ${otp}. Valid for ${OTP_EXPIRY_MINUTES} minutes. Do not share this with anyone.`;

    const response = await axios.post(FAST2SMS_URL, {
      route: 'otp',
      numbers: mobileNumber,
      message: message,
      flash: 0
    }, {
      headers: {
        'authorization': FAST2SMS_API_KEY,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    functions.logger.info(`OTP sent to ${mobileNumber}`, {
      response: response.data
    });

    return {
      success: true,
      messageId: response.data?.message_id || null
    };
  } catch (error) {
    functions.logger.error(`Failed to send SMS to ${mobileNumber}`, {
      error: error.message,
      response: error.response?.data
    });

    throw new functions.https.HttpsError(
      'internal',
      `Failed to send OTP: ${error.message}`
    );
  }
}

/**
 * Cloud Function: Send OTP
 *
 * Request body:
 * {
 *   "mobileNumber": "9876543210"
 * }
 *
 * Response:
 * {
 *   "success": true,
 *   "otp": "123456",
 *   "expiresIn": 600
 * }
 */
exports.sendOtp = functions.https.onCall(async (data, context) => {
  const mobileNumber = data.mobileNumber?.toString().trim();

  // Validation
  if (!mobileNumber) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Mobile number is required'
    );
  }

  if (!isValidMobileNumber(mobileNumber)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid mobile number format. Please enter a valid 10-digit Indian number.'
    );
  }

  // Rate limiting
  const rateLimit = await checkRateLimit(mobileNumber);
  if (!rateLimit.canRequest) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      `Too many OTP requests. Please try again after ${OTP_REQUEST_WINDOW_MINUTES} minutes.`
    );
  }

  // Generate OTP
  const otp = generateOTP();
  const otpHash = hashOTP(otp);
  const now = new Date();
  const expiresAt = new Date(now.getTime() + OTP_EXPIRY_MINUTES * 60 * 1000);

  try {
    // Store OTP in Firestore
    const otpRef = await db.collection('otp_verifications').add({
      mobile_number: mobileNumber,
      otp_hash: otpHash,
      verified: false,
      created_at: now,
      expires_at: expiresAt
    });

    // Send SMS
    const smsResult = await sendSMS(mobileNumber, otp);

    functions.logger.info(`OTP generated and stored`, {
      mobileNumber,
      otpId: otpRef.id,
      smsMessageId: smsResult.messageId
    });

    return {
      success: true,
      message: 'OTP sent successfully',
      expiresIn: OTP_EXPIRY_MINUTES * 60 // seconds
    };
  } catch (error) {
    functions.logger.error(`Error in sendOtp function`, {
      error: error.message,
      mobileNumber
    });

    throw error;
  }
});

/**
 * Cloud Function: Verify OTP
 *
 * Request body:
 * {
 *   "mobileNumber": "9876543210",
 *   "otp": "123456"
 * }
 *
 * Response:
 * {
 *   "success": true,
 *   "verified": true,
 *   "message": "OTP verified successfully"
 * }
 */
exports.verifyOtp = functions.https.onCall(async (data, context) => {
  const mobileNumber = data.mobileNumber?.toString().trim();
  const inputOtp = data.otp?.toString().trim();

  // Validation
  if (!mobileNumber || !inputOtp) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Mobile number and OTP are required'
    );
  }

  const otpRegex = /^\d{6}$/;
  if (!otpRegex.test(inputOtp)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'OTP must be a 6-digit number'
    );
  }

  try {
    // Find unverified OTP
    const query = await db.collection('otp_verifications')
      .where('mobile_number', '==', mobileNumber)
      .where('verified', '==', false)
      .orderBy('created_at', 'desc')
      .limit(1)
      .get();

    if (query.empty) {
      throw new functions.https.HttpsError(
        'not-found',
        'No pending OTP found. Please request a new one.'
      );
    }

    const otpDoc = query.docs[0];
    const otpData = otpDoc.data();

    // Check expiration
    if (new Date() > otpData.expires_at.toDate()) {
      await otpDoc.ref.update({ verified: false });
      throw new functions.https.HttpsError(
        'deadline-exceeded',
        'OTP has expired. Please request a new one.'
      );
    }

    // Verify OTP
    const inputHash = hashOTP(inputOtp);
    if (inputHash !== otpData.otp_hash) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Invalid OTP. Please try again.'
      );
    }

    // Mark as verified
    await otpDoc.ref.update({
      verified: true,
      verified_at: new Date()
    });

    functions.logger.info(`OTP verified successfully`, {
      mobileNumber,
      otpId: otpDoc.id
    });

    return {
      success: true,
      verified: true,
      message: 'OTP verified successfully'
    };
  } catch (error) {
    functions.logger.error(`Error in verifyOtp function`, {
      error: error.message,
      mobileNumber
    });

    throw error;
  }
});

/**
 * Cloud Function: Order Creation for Razorpay
 *
 * Request body:
 * {
 *   "amount": 99,
 *   "currency": "INR",
 *   "planId": "monthly"
 * }
 */
exports.createRazorpayOrder = functions.https.onCall(async (data, context) => {
  // Implement Razorpay order creation
  // This would integrate with Razorpay API

  return {
    success: true,
    orderId: 'order_' + Math.random().toString(36).substr(2, 9),
    amount: data.amount,
    currency: data.currency
  };
});
