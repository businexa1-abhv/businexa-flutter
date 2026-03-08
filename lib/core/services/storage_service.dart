import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _firebaseStorage = FirebaseStorage.instance;
  static const uuid = Uuid();

  /// Upload image to Firebase Storage
  /// Returns the download URL or null on failure
  Future<String?> uploadImage({
    required File imageFile,
    required String userId,
    String folder = 'products',
  }) async {
    try {
      final fileName = '${uuid.v4()}.jpg';
      final storagePath = '$folder/$userId/$fileName';

      final ref = _firebaseStorage.ref().child(storagePath);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments;

      if (path.isEmpty) return false;

      // Reconstruct path from URL components
      final ref = _firebaseStorage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get temporary download URL for an image
  Future<String?> getDownloadUrl(String imagePath) async {
    try {
      final ref = _firebaseStorage.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String imagePath) async {
    try {
      final ref = _firebaseStorage.ref().child(imagePath);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file size in MB
  Future<double?> getFileSizeMB(String imagePath) async {
    try {
      final ref = _firebaseStorage.ref().child(imagePath);
      final metadata = await ref.getMetadata();
      final sizeInBytes = metadata.size ?? 0;
      return sizeInBytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }
}
