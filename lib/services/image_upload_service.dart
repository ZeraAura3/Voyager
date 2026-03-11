// lib/services/image_upload_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service for handling image uploads to Supabase Storage
class ImageUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  static const String bucketName = 'ticket-images';
  static const int maxImageSizeKB = 2048; // 2MB max

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Show dialog to choose between camera or gallery
  Future<File?> pickImage({required bool fromCamera}) async {
    if (fromCamera) {
      return await pickImageFromCamera();
    } else {
      return await pickImageFromGallery();
    }
  }

  /// Compress image to reduce file size
  Future<File> compressImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if too large
      if (image.width > 1920 || image.height > 1080) {
        image = img.copyResize(
          image,
          width: image.width > 1920 ? 1920 : null,
          height: image.height > 1080 ? 1080 : null,
        );
      }

      // Compress to JPEG
      final compressedBytes = img.encodeJpg(image, quality: 85);

      // Save to temporary file
      final tempDir = imageFile.parent;
      final compressedFile = File(
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Upload image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    String? ticketId,
  }) async {
    try {
      // Compress image first
      final compressedImage = await compressImage(imageFile);

      // Check file size
      final fileSize = await compressedImage.length();
      if (fileSize > maxImageSizeKB * 1024) {
        throw Exception('Image size exceeds ${maxImageSizeKB}KB limit');
      }

      // Generate unique filename
      final uuid = const Uuid();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueId = ticketId ?? uuid.v4();
      final fileName = '$userId/$uniqueId\_$timestamp.jpg';

      // Upload to Supabase Storage
      await _supabase.storage.from(bucketName).upload(
            fileName,
            compressedImage,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final String publicUrl =
          _supabase.storage.from(bucketName).getPublicUrl(fileName);

      // Clean up compressed file
      if (await compressedImage.exists()) {
        await compressedImage.delete();
      }

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete image from Supabase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final path = extractFilePath(imageUrl);

      if (path != null) {
        // Delete from storage
        await _supabase.storage.from(bucketName).remove([path]);
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Extract file path from Supabase public URL
  String? extractFilePath(String publicUrl) {
    try {
      final uri = Uri.parse(publicUrl);
      // Get path after bucket name
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        return segments.sublist(bucketIndex + 1).join('/');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update image (delete old and upload new)
  Future<String> updateImage({
    required File newImageFile,
    required String userId,
    String? oldImageUrl,
    String? ticketId,
  }) async {
    try {
      // Delete old image if exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          await deleteImage(oldImageUrl);
        } catch (e) {
          // Continue even if deletion fails
          print('Warning: Failed to delete old image: $e');
        }
      }

      // Upload new image
      return await uploadImage(
        imageFile: newImageFile,
        userId: userId,
        ticketId: ticketId,
      );
    } catch (e) {
      throw Exception('Failed to update image: $e');
    }
  }
}
