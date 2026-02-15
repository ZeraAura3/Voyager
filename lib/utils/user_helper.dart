// lib/utils/user_helper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for user-related operations between Firebase and Supabase
class UserHelper {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get Supabase user information using Firebase UID
  /// Returns Map with: user_id (UUID), full_name, roll_no
  static Future<Map<String, dynamic>?> getSupabaseUserByFirebaseUid(
    String firebaseUid,
  ) async {
    try {
      final response = await _supabase
          .from('users')
          .select('user_id, full_name, roll_no, email')
          .eq('firebase_uid', firebaseUid)
          .maybeSingle();

      return response;
    } catch (e) {
      // Silently return null if user not found
      return null;
    }
  }

  /// Get current user's Supabase information
  /// Automatically attempts to sync from Firebase if Supabase profile is missing
  static Future<Map<String, dynamic>> getCurrentSupabaseUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Try to get user from Supabase
    var userInfo = await getSupabaseUserByFirebaseUid(currentUser.uid);

    // If user not found in Supabase, try to sync from Firestore
    if (userInfo == null) {
      print('User not found in Supabase, attempting to sync from Firestore...');
      await _syncFromFirestore(currentUser.uid);

      // Retry fetching
      userInfo = await getSupabaseUserByFirebaseUid(currentUser.uid);
    }

    if (userInfo == null) {
      throw Exception('User profile not found. Please complete your profile.');
    }

    return userInfo;
  }

  /// Syncs user data from Firestore to Supabase
  static Future<void> _syncFromFirestore(String uid) async {
    try {
      // Check students collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();

      String role = 'student';

      if (!userDoc.exists) {
        // Check drivers collection
        userDoc = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(uid)
            .get();
        role = 'driver';
      }

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        // Use role from document if available, otherwise fallback to inferred role
        final docRole = data['role'] ?? role;

        await syncUserToSupabase(
          firebaseUid: uid,
          email: data['email'] ?? '',
          fullName: data['fullName'] ?? 'Unknown',
          role: docRole,
          rollNo: docRole == 'student' ? (data['studentId'] ?? '') : null,
          phone: data['phone'],
        );
      }
    } catch (e) {
      print('Auto-sync failed: $e');
    }
  }

  /// Sync Firebase user to Supabase explicitly
  static Future<void> syncUserToSupabase({
    required String firebaseUid,
    required String email,
    required String fullName,
    required String role,
    String? rollNo,
    String? phone,
  }) async {
    try {
      // Check if user exists to avoid duplicates if RLS/Constraints don't catch it
      final existingUser = await getSupabaseUserByFirebaseUid(firebaseUid);
      if (existingUser != null) {
        print('User already exists in Supabase, skipping sync.');
        return;
      }

      await _supabase.from('users').insert({
        'firebase_uid': firebaseUid,
        'email': email,
        'full_name': fullName,
        'roll_no': rollNo ?? '',
      });
      print('User synced to Supabase successfully');
    } catch (e) {
      print('Error syncing user to Supabase: $e');
      // Don't throw here to allow calling method to verify success via fetching
    }
  }

  /// Get Supabase user_id (UUID) for current Firebase user
  static Future<String> getCurrentSupabaseUserId() async {
    final userInfo = await getCurrentSupabaseUser();
    return userInfo['user_id'] as String;
  }

  /// Check if current Firebase user exists in Supabase
  static Future<bool> currentUserExistsInSupabase() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final userInfo = await getSupabaseUserByFirebaseUid(currentUser.uid);
    return userInfo != null;
  }
}
