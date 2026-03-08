import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/scan_tracking_service.dart';
import '../models/scan_event_model.dart';

// Scan service provider
final scanServiceProvider = Provider<ScanTrackingService>((ref) {
  return ScanTrackingService();
});

// Record scan provider
final recordScanProvider = FutureProvider.family<bool, String>((ref, adId) async {
  final scanService = ref.watch(scanServiceProvider);
  return await scanService.recordScan(adId);
});

// Get scans for ad
final scansForAdProvider = FutureProvider.family<List<ScanEvent>, String>((ref, adId) async {
  final scanService = ref.watch(scanServiceProvider);
  return await scanService.getScansByAdId(adId);
});

// Get scan count
final scanCountProvider = FutureProvider.family<int, String>((ref, adId) async {
  final scanService = ref.watch(scanServiceProvider);
  return await scanService.getScanCount(adId);
});

// Get today's scan count
final todaysScanCountProvider = FutureProvider.family<int, String>((ref, adId) async {
  final scanService = ref.watch(scanServiceProvider);
  return await scanService.getTodaysScanCount(adId);
});

// Get scans by date range
final scansByDateRangeProvider = FutureProvider.family<List<ScanEvent>, (String, DateTime, DateTime)>((ref, params) async {
  final scanService = ref.watch(scanServiceProvider);
  return await scanService.getScansByDateRange(params.$1, params.$2, params.$3);
});

// Scan history notifier
final scanHistoryProvider = StateNotifierProvider<ScanHistoryNotifier, AsyncValue<List<ScanEvent>>>((ref) {
  final scanService = ref.watch(scanServiceProvider);
  return ScanHistoryNotifier(scanService);
});

class ScanHistoryNotifier extends StateNotifier<AsyncValue<List<ScanEvent>>> {
  final ScanTrackingService _scanService;

  ScanHistoryNotifier(this._scanService) : super(const AsyncValue.loading());

  Future<void> loadScans(String adId) async {
    try {
      state = const AsyncValue.loading();
      final scans = await _scanService.getScansByAdId(adId);
      state = AsyncValue.data(scans);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadScansByDate(String adId, DateTime startDate, DateTime endDate) async {
    try {
      state = const AsyncValue.loading();
      final scans = await _scanService.getScansByDateRange(adId, startDate, endDate);
      state = AsyncValue.data(scans);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> recordNewScan(String adId) async {
    try {
      final success = await _scanService.recordScan(adId);
      if (success) {
        // Reload scans
        await loadScans(adId);
      }
      return success;
    } catch (e) {
      print('Error recording scan: $e');
      return false;
    }
  }
}
