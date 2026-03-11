// lib/services/ride_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing rides and bookings in Supabase
class RideService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── RIDES ────────────────────────────────────────────────────────────

  /// Post a new ride
  Future<Map<String, dynamic>> createRide({
    required String postedBy,
    required String fromLocation,
    required String toLocation,
    required String rideDate,
    required String rideTime,
    required int availableSeats,
    required double pricePerSeat,
    String? genderPreference,
  }) async {
    try {
      final response = await _supabase
          .from('rides')
          .insert({
            'posted_by': postedBy,
            'from_location': fromLocation,
            'to_location': toLocation,
            'ride_date': rideDate,
            'ride_time': rideTime,
            'available_seats': availableSeats,
            'price_per_seat': pricePerSeat,
            'gender_preference': genderPreference ?? 'any',
            'status': 'active',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to create ride: $e');
    }
  }

  /// Search rides with filters
  Future<List<Map<String, dynamic>>> searchRides({
    String? fromLocation,
    String? toLocation,
    double? maxPrice,
    double? minPrice,
    String? genderPreference,
  }) async {
    try {
      var query = _supabase
          .from('rides')
          .select()
          .eq('status', 'active')
          .gt('available_seats', 0);

      if (fromLocation != null && fromLocation.isNotEmpty) {
        query = query.ilike('from_location', '%$fromLocation%');
      }

      if (toLocation != null && toLocation.isNotEmpty) {
        query = query.ilike('to_location', '%$toLocation%');
      }

      if (maxPrice != null) {
        query = query.lte('price_per_seat', maxPrice);
      }

      if (minPrice != null) {
        query = query.gte('price_per_seat', minPrice);
      }

      if (genderPreference != null &&
          genderPreference.isNotEmpty &&
          genderPreference.toLowerCase() != 'any' &&
          genderPreference.toLowerCase() != 'all') {
        query = query.or(
            'gender_preference.eq.any,gender_preference.ilike.$genderPreference');
      }

      final response = await query.order('ride_date', ascending: true);

      // Enrich each ride with poster info
      List<Map<String, dynamic>> enriched = [];
      for (var ride in List<Map<String, dynamic>>.from(response)) {
        final userInfo = await _getUserInfo(ride['posted_by']);
        ride['poster_name'] = userInfo['full_name'] ?? 'Unknown';
        ride['poster_gender'] = userInfo['gender'] ?? '';
        enriched.add(ride);
      }

      return enriched;
    } catch (e) {
      throw Exception('Failed to search rides: $e');
    }
  }

  /// Get all active rides as stream
  Stream<List<Map<String, dynamic>>> getActiveRides() {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['ride_id'])
        .eq('status', 'active')
        .order('ride_date', ascending: true)
        .asyncMap((data) async {
      List<Map<String, dynamic>> enriched = [];
      for (var ride in data) {
        if ((ride['available_seats'] as int? ?? 0) > 0) {
          final userInfo = await _getUserInfo(ride['posted_by']);
          ride['poster_name'] = userInfo['full_name'] ?? 'Unknown';
          ride['poster_gender'] = userInfo['gender'] ?? '';
          enriched.add(ride);
        }
      }
      return enriched;
    });
  }

  /// Get rides posted by a user
  Future<List<Map<String, dynamic>>> getUserRides(String userId) async {
    try {
      final response = await _supabase
          .from('rides')
          .select()
          .eq('posted_by', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get user rides: $e');
    }
  }

  /// Update ride status
  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      await _supabase
          .from('rides')
          .update({'status': status}).eq('ride_id', rideId);
    } catch (e) {
      throw Exception('Failed to update ride status: $e');
    }
  }

  /// Delete a ride
  Future<void> deleteRide(String rideId) async {
    try {
      await _supabase.from('rides').delete().eq('ride_id', rideId);
    } catch (e) {
      throw Exception('Failed to delete ride: $e');
    }
  }

  // ─── BOOKINGS ─────────────────────────────────────────────────────────

  /// Book a ride (create a booking request with multi-party approval)
  Future<Map<String, dynamic>> createBooking({
    required String rideId,
    required String riderId,
    required int seatsBooked,
  }) async {
    try {
      // First get ride details to calculate price
      final ride = await _supabase
          .from('rides')
          .select()
          .eq('ride_id', rideId)
          .single();

      final pricePerSeat = (ride['price_per_seat'] as num).toDouble();
      final totalPrice = pricePerSeat * seatsBooked;

      // Create the booking
      final response = await _supabase
          .from('bookings')
          .insert({
            'ride_id': rideId,
            'rider_id': riderId,
            'seats_booked': seatsBooked,
            'total_price': totalPrice,
            'status': 'pending',
          })
          .select()
          .single();

      final bookingId = response['booking_id'] as String;

      // Get all people who need to approve:
      // 1. Ride poster
      final posterId = ride['posted_by'] as String;
      
      // 2. All existing confirmed passengers
      final confirmedBookings = await _supabase
          .from('bookings')
          .select('rider_id')
          .eq('ride_id', rideId)
          .eq('status', 'confirmed');

      // Collect all approvers (poster + existing passengers)
      Set<String> approverIds = {posterId};
      for (var booking in confirmedBookings) {
        approverIds.add(booking['rider_id'] as String);
      }

      // Create approval records for each approver
      List<Map<String, dynamic>> approvals = approverIds.map((approverId) {
        return {
          'booking_id': bookingId,
          'approver_id': approverId,
          'status': 'pending',
        };
      }).toList();

      await _supabase.from('booking_approvals').insert(approvals);

      return response;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get bookings for a ride (for ride poster to see join requests)
  Future<List<Map<String, dynamic>>> getRideBookings(String rideId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('ride_id', rideId)
          .order('created_at', ascending: false);

      // Enrich with user info
      List<Map<String, dynamic>> enriched = [];
      for (var booking in response) {
        final userInfo = await _getUserInfo(booking['rider_id']);
        booking['rider_name'] = userInfo['full_name'] ?? 'Unknown';
        booking['rider_gender'] = userInfo['gender'] ?? '';
        enriched.add(booking);
      }
      return enriched;
    } catch (e) {
      throw Exception('Failed to get ride bookings: $e');
    }
  }

  /// Get incoming booking requests for a user's rides (pending)
  Stream<List<Map<String, dynamic>>> getIncomingBookingRequests(
      String userId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['booking_id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
      // Get all ride IDs posted by this user
      final userRides = await _supabase
          .from('rides')
          .select('ride_id, from_location, to_location, ride_date, ride_time')
          .eq('posted_by', userId);

      final userRideIds =
          userRides.map((r) => r['ride_id'] as String).toSet();

      List<Map<String, dynamic>> requests = [];
      for (var booking in data) {
        if (userRideIds.contains(booking['ride_id'])) {
          // Enrich with rider info
          final userInfo = await _getUserInfo(booking['rider_id']);
          booking['rider_name'] = userInfo['full_name'] ?? 'Unknown';
          booking['rider_gender'] = userInfo['gender'] ?? '';

          // Enrich with ride info
          final ride = userRides.firstWhere(
            (r) => r['ride_id'] == booking['ride_id'],
            orElse: () => {},
          );
          booking['from_location'] = ride['from_location'] ?? '';
          booking['to_location'] = ride['to_location'] ?? '';
          booking['ride_date'] = ride['ride_date'] ?? '';
          booking['ride_time'] = ride['ride_time'] ?? '';

          requests.add(booking);
        }
      }
      return requests;
    });
  }

  /// Get bookings made by a user (as rider)
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('rider_id', userId)
          .order('created_at', ascending: false);

      // Enrich with ride info
      List<Map<String, dynamic>> enriched = [];
      for (var booking in response) {
        try {
          final ride = await _supabase
              .from('rides')
              .select()
              .eq('ride_id', booking['ride_id'])
              .single();

          booking['from_location'] = ride['from_location'];
          booking['to_location'] = ride['to_location'];
          booking['ride_date'] = ride['ride_date'];
          booking['ride_time'] = ride['ride_time'];

          final posterInfo = await _getUserInfo(ride['posted_by']);
          booking['poster_name'] = posterInfo['full_name'] ?? 'Unknown';
        } catch (_) {
          booking['from_location'] = 'Unknown';
          booking['to_location'] = 'Unknown';
          booking['ride_date'] = '';
          booking['ride_time'] = '';
          booking['poster_name'] = 'Unknown';
        }
        enriched.add(booking);
      }
      return enriched;
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  /// Approve a booking request (multi-party approval)
  Future<void> approveBooking(String bookingId, String approverId) async {
    try {
      // Update this approver's status to 'approved'
      await _supabase
          .from('booking_approvals')
          .update({
            'status': 'approved',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('booking_id', bookingId)
          .eq('approver_id', approverId);

      // Check if ALL approvers have approved
      final allApprovals = await _supabase
          .from('booking_approvals')
          .select('status')
          .eq('booking_id', bookingId);

      final allApproved = allApprovals.every((a) => a['status'] == 'approved');

      if (allApproved) {
        // ALL approvers said yes! Confirm the booking
        final booking = await _supabase
            .from('bookings')
            .select()
            .eq('booking_id', bookingId)
            .single();

        // Update booking status to confirmed
        await _supabase.from('bookings').update({
          'status': 'confirmed',
        }).eq('booking_id', bookingId);

        // Decrease available seats on the ride
        final ride = await _supabase
            .from('rides')
            .select()
            .eq('ride_id', booking['ride_id'])
            .single();

        final currentSeats = ride['available_seats'] as int;
        final seatsBooked = booking['seats_booked'] as int;
        final newSeats = currentSeats - seatsBooked;

        await _supabase.from('rides').update({
          'available_seats': newSeats < 0 ? 0 : newSeats,
          'status': newSeats <= 0 ? 'full' : 'active',
        }).eq('ride_id', booking['ride_id']);
      }
    } catch (e) {
      throw Exception('Failed to approve booking: $e');
    }
  }

  /// Reject a booking request (multi-party rejection)
  Future<void> rejectBooking(String bookingId, String approverId) async {
    try {
      // Update this approver's status to 'rejected'
      await _supabase
          .from('booking_approvals')
          .update({
            'status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('booking_id', bookingId)
          .eq('approver_id', approverId);

      // If ANY approver rejects, the entire booking is rejected
      await _supabase.from('bookings').update({
        'status': 'rejected',
      }).eq('booking_id', bookingId);
    } catch (e) {
      throw Exception('Failed to reject booking: $e');
    }
  }

  /// Get all pending approval requests for a specific user
  /// Returns bookings that need this user's approval decision
  Stream<List<Map<String, dynamic>>> getPendingApprovals(String userId) {
    return _supabase
        .from('booking_approvals')
        .stream(primaryKey: ['approval_id'])
        .map((approvals) async {
          List<Map<String, dynamic>> enrichedApprovals = [];
          
          for (var approval in approvals) {
            // Filter by user and pending status
            if (approval['approver_id'] != userId || approval['status'] != 'pending') {
              continue;
            }
            
            try {
              // Get booking details
              final booking = await _supabase
                  .from('bookings')
                  .select()
                  .eq('booking_id', approval['booking_id'])
                  .maybeSingle();
              
              if (booking == null) continue;
              
              // Get ride details
              final ride = await _supabase
                  .from('rides')
                  .select()
                  .eq('ride_id', booking['ride_id'])
                  .maybeSingle();
              
              if (ride == null) continue;
              
              // Get requester info (person trying to join)
              final requesterInfo = await _getUserInfo(booking['rider_id']);
              
              enrichedApprovals.add({
                'approval_id': approval['approval_id'],
                'booking_id': approval['booking_id'],
                'booking': booking,
                'ride': ride,
                'requester_name': requesterInfo['full_name'],
                'requester_id': booking['rider_id'],
                'seats_requested': booking['seats_booked'],
                'created_at': approval['created_at'],
              });
            } catch (e) {
              print('Error enriching approval: $e');
            }
          }
          
          return enrichedApprovals;
        })
        .asyncMap((future) => future);
  }

  /// Get detailed approval status for a specific booking
  /// Returns list of approvers with their approval status
  Future<Map<String, dynamic>> getBookingApprovalStatus(String bookingId) async {
    try {
      final approvals = await _supabase
          .from('booking_approvals')
          .select()
          .eq('booking_id', bookingId);
      
      List<Map<String, dynamic>> approverDetails = [];
      int approvedCount = 0;
      int rejectedCount = 0;
      int pendingCount = 0;
      
      for (var approval in approvals) {
        final userInfo = await _getUserInfo(approval['approver_id']);
        
        approverDetails.add({
          'approver_id': approval['approver_id'],
          'approver_name': userInfo['full_name'],
          'status': approval['status'],
          'updated_at': approval['updated_at'],
        });
        
        if (approval['status'] == 'approved') approvedCount++;
        else if (approval['status'] == 'rejected') rejectedCount++;
        else if (approval['status'] == 'pending') pendingCount++;
      }
      
      return {
        'approvers': approverDetails,
        'total_approvers': approvals.length,
        'approved_count': approvedCount,
        'rejected_count': rejectedCount,
        'pending_count': pendingCount,
        'all_approved': approvedCount == approvals.length && approvals.isNotEmpty,
        'any_rejected': rejectedCount > 0,
      };
    } catch (e) {
      throw Exception('Failed to get booking approval status: $e');
    }
  }

  /// Cancel a booking (by rider)
  Future<void> cancelBooking(String bookingId) async {
    try {
      final booking = await _supabase
          .from('bookings')
          .select()
          .eq('booking_id', bookingId)
          .single();

      await _supabase.from('bookings').update({
        'status': 'cancelled',
      }).eq('booking_id', bookingId);

      // If booking was confirmed, restore seats
      if (booking['status'] == 'confirmed') {
        final ride = await _supabase
            .from('rides')
            .select()
            .eq('ride_id', booking['ride_id'])
            .single();

        final currentSeats = ride['available_seats'] as int;
        final seatsBooked = booking['seats_booked'] as int;

        await _supabase.from('rides').update({
          'available_seats': currentSeats + seatsBooked,
          'status': 'active',
        }).eq('ride_id', booking['ride_id']);
      }
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────

  /// Get user info from users table
  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('full_name, gender')
          .eq('user_id', userId)
          .maybeSingle();
      return response ?? {'full_name': 'Unknown', 'gender': ''};
    } catch (e) {
      return {'full_name': 'Unknown', 'gender': ''};
    }
  }
}
