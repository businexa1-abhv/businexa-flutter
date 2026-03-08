import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../models/scan_event_model.dart';

class ScanTrackingService {
  final _firestore = FirebaseFirestore.instance;
  static const uuid = Uuid();

  /// Record a scan event
  Future<bool> recordScan(String adId) async {
    try {
      final scanId = uuid.v4();

      // Create scan event
      final scanEvent = ScanEvent(
        id: scanId,
        adId: adId,
        timestamp: DateTime.now(),
        deviceInfo: _getDeviceInfo(),
        userAgent: _getUserAgent(),
      );

      // Add to scans collection
      await _firestore.collection('scans').doc(scanId).set(scanEvent.toMap());

      // Increment ad scan count
      await _firestore.collection('ads').doc(adId).update({
        'scanCount': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error recording scan: $e');
      return false;
    }
  }

  /// Get all scans for an ad
  Future<List<ScanEvent>> getScansByAdId(String adId) async {
    try {
      final docs = await _firestore
          .collection('scans')
          .where('adId', isEqualTo: adId)
          .orderBy('timestamp', descending: true)
          .get();

      return docs.docs
          .map((doc) => ScanEvent.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching scans: $e');
      return [];
    }
  }

  /// Get scan count for an ad
  Future<int> getScanCount(String adId) async {
    try {
      final doc = await _firestore.collection('ads').doc(adId).get();
      return doc.data()?['scanCount'] ?? 0;
    } catch (e) {
      print('Error getting scan count: $e');
      return 0;
    }
  }

  /// Get scans in date range
  Future<List<ScanEvent>> getScansByDateRange(
    String adId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final docs = await _firestore
          .collection('scans')
          .where('adId', isEqualTo: adId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();

      return docs.docs
          .map((doc) => ScanEvent.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching scans by date: $e');
      return [];
    }
  }

  /// Get today's scans for an ad
  Future<int> getTodaysScanCount(String adId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final scans = await getScansByDateRange(adId, startOfDay, endOfDay);
    return scans.length;
  }

  /// Get device information
  String _getDeviceInfo() {
    try {
      return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get user agent
  String _getUserAgent() {
    // In a web context, this would be the browser user agent
    // For mobile, we return a simple identifier
    try {
      return 'Businexa-App/${Platform.operatingSystem}';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Delete old scans (data retention policy)
  Future<void> deleteOldScans(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await _firestore
          .collection('scans')
          .where('timestamp', isLessThan: cutoffDate)
          .get()
          .then((snapshot) async {
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      });
    } catch (e) {
      print('Error deleting old scans: $e');
    }
  }
}
