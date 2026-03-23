import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Storage Service for Supabase - Using your buckets
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Upload bill photo (Purchase) - stores path in billphotopath
  Future<String?> uploadBillPhoto(String purchaseId, XFile file) async {
    try {
      String fileName = 'bill_${purchaseId}_${_uuid.v4()}.jpg';

      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await file.readAsBytes();
      } else {
        fileBytes = File(file.path).readAsBytesSync();
      }

      // Upload to 'bills' bucket
      await _supabase.storage.from('bills').uploadBinary(fileName, fileBytes,
          fileOptions: const FileOptions(upsert: true));

      // Return the path (not full URL, just path as per your schema)
      return 'bills/$fileName';
    } catch (e) {
      debugPrint('Error uploading bill photo: $e');
      return null;
    }
  }

  /// Upload bilti photo (Distribution) - stores path in biltiphotopath
  Future<String?> uploadBiltiPhoto(String distributionId, XFile file) async {
    try {
      String fileName = 'bilti_${distributionId}_${_uuid.v4()}.jpg';

      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await file.readAsBytes();
      } else {
        fileBytes = File(file.path).readAsBytesSync();
      }

      // Upload to 'biltis' bucket
      await _supabase.storage.from('biltis').uploadBinary(fileName, fileBytes,
          fileOptions: const FileOptions(upsert: true));

      // Return the path
      return 'biltis/$fileName';
    } catch (e) {
      debugPrint('Error uploading bilti photo: $e');
      return null;
    }
  }

  /// Get public URL from path
  String? getPublicUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    try {
      // Path format: "bucket/filename"
      final parts = path.split('/');
      if (parts.length < 2) return null;

      final bucket = parts[0];
      final fileName = parts.sublist(1).join('/');

      return _supabase.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error getting public URL: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }
}
