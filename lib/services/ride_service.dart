// lib/services/ride_service.dart
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing rides and bookings in Supabase
class RideService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static final Map<String, Map<String, double>> _geocodeCache = {};

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
    double? sourceLat,
    double? sourceLng,
    double? destLat,
    double? destLng,
  }) async {
    try {
      final sourceCoords =
          sourceLat != null && sourceLng != null
              ? {'lat': sourceLat, 'lng': sourceLng}
              : await _geocodeLocation(fromLocation);
      final destCoords =
          destLat != null && destLng != null
              ? {'lat': destLat, 'lng': destLng}
              : await _geocodeLocation(toLocation);

      String? routeId;
      try {
        final routeResponse = await _supabase.functions.invoke(
          'create-route',
          body: {
            'source_lat': sourceCoords['lat'],
            'source_lng': sourceCoords['lng'],
            'dest_lat': destCoords['lat'],
            'dest_lng': destCoords['lng'],
          },
        );

        if (routeResponse.status == 200 && routeResponse.data is Map<String, dynamic>) {
          final routeData = routeResponse.data as Map<String, dynamic>;
          final success = routeData['success'] as bool? ?? false;
          if (success) {
            routeId = routeData['route_id'] as String?;
          }
        }
      } catch (e) {
        final errorText = e.toString();
        if (errorText.contains('driver_id') && errorText.contains('routes')) {
          routeId = null;
        } else {
          routeId = null;
        }
      }

      final payload = {
        'posted_by': postedBy,
        'from_location': fromLocation,
        'to_location': toLocation,
        'ride_date': rideDate,
        'ride_time': rideTime,
        'available_seats': availableSeats,
        'price_per_seat': pricePerSeat,
        'gender_preference': genderPreference ?? 'any',
        'status': 'active',
      };

      if (routeId != null && routeId.isNotEmpty) {
        payload['route_id'] = routeId;
      }

      try {
        final response = await _supabase
            .from('rides')
            .insert(payload)
            .select()
            .single();
        return response;
      } on PostgrestException catch (e) {
        final missingRouteIdColumn =
            e.message.contains('route_id') && e.message.contains('does not exist');

        if (!missingRouteIdColumn || !payload.containsKey('route_id')) {
          rethrow;
        }

        payload.remove('route_id');
        final response = await _supabase
            .from('rides')
            .insert(payload)
            .select()
            .single();
        return response;
      }
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
  double? sourceLat,
  double? sourceLng,
  double? destLat,
  double? destLng,
}) async {
  try {
    List<Map<String, dynamic>> rides;
    Map<String, double>? querySourceCoords;
    Map<String, double>? queryDestCoords;

    // ---------------------------------------------------------
    // PATH A: Spatial Search (If user provides both locations)
    // ---------------------------------------------------------
    final hasCoordinateInputs =
      sourceLat != null && sourceLng != null && destLat != null && destLng != null;
    final hasTextInputs = fromLocation != null && fromLocation.isNotEmpty &&
      toLocation != null && toLocation.isNotEmpty;

    if (hasCoordinateInputs || hasTextInputs) {
      final sourceCoords = hasCoordinateInputs
        ? {'lat': sourceLat, 'lng': sourceLng}
        : await _geocodeLocation(fromLocation!);
      final destCoords = hasCoordinateInputs
        ? {'lat': destLat, 'lng': destLng}
        : await _geocodeLocation(toLocation!);

      querySourceCoords = {
        'lat': sourceCoords['lat']!,
        'lng': sourceCoords['lng']!,
      };
      queryDestCoords = {
        'lat': destCoords['lat']!,
        'lng': destCoords['lng']!,
      };

      // 2. Call Edge Function -> PostGIS -> OSRM Detour Check
      final compatibleRides = await checkRouteCompatibility(
        sourceLat: sourceCoords['lat']!,
        sourceLng: sourceCoords['lng']!,
        destLat: destCoords['lat']!,
        destLng: destCoords['lng']!,
      );

      // Extract the ride IDs from the compatibility check
      final rideIds = compatibleRides.map((r) => r['ride_id'] as String).toList();
      
      // If the edge function created a NEW route, there are no existing 
      // active rides attached to it yet. We return an empty list to the user.
      if (rideIds.isEmpty) {
        var fallbackQuery = _supabase
            .from('rides')
            .select()
            .eq('status', 'active')
            .gt('available_seats', 0);

        if (fromLocation != null && fromLocation.isNotEmpty) {
          fallbackQuery = fallbackQuery.ilike('from_location', '%$fromLocation%');
        }

        rides = List<Map<String, dynamic>>.from(
          await fallbackQuery.order('ride_date', ascending: true),
        );
      } else {
        // 3. Fetch full ride rows so downstream filters and UI work correctly
        rides = List<Map<String, dynamic>>.from(await _supabase
            .from('rides')
            .select()
            .eq('status', 'active')
            .gt('available_seats', 0)
            .inFilter('ride_id', rideIds)
            .order('ride_date', ascending: true));
      }

    } 
    // ---------------------------------------------------------
    // PATH B: Fallback String Search (If missing a location)
    // ---------------------------------------------------------
    else {
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

      rides = List<Map<String, dynamic>>.from(await query.order('ride_date', ascending: true));
    }

    // ---------------------------------------------------------
    // COMMON: Apply Business Logic Filters (Price & Gender)
    // ---------------------------------------------------------
    if (maxPrice != null) {
      rides = rides.where((ride) => (ride['price_per_seat'] as num) <= maxPrice).toList();
    }

    if (minPrice != null) {
      rides = rides.where((ride) => (ride['price_per_seat'] as num) >= minPrice).toList();
    }

    if (genderPreference != null &&
        genderPreference.isNotEmpty &&
        genderPreference.toLowerCase() != 'any' &&
        genderPreference.toLowerCase() != 'all') {
      rides = rides.where((ride) {
        final pref = ride['gender_preference'] as String? ?? 'any';
        // Keeps the ride if it accepts 'any' gender, OR if it strictly matches the user's preference
        return pref == 'any' || pref.toLowerCase() == genderPreference.toLowerCase();
      }).toList();
    }

    // ---------------------------------------------------------
    // COMMON: Enrich Data with Poster Info
    // ---------------------------------------------------------
    List<Map<String, dynamic>> enriched = [];
    for (var ride in rides) {
      final userInfo = await _getUserInfo(ride['posted_by']);
      ride['poster_name'] = userInfo['full_name'] ?? 'Unknown';
      ride['poster_gender'] = userInfo['gender'] ?? '';
      enriched.add(ride);
    }

    if (querySourceCoords != null && queryDestCoords != null) {
      for (final ride in enriched) {
        final rideFrom = (ride['from_location'] as String? ?? '').trim();
        final rideTo = (ride['to_location'] as String? ?? '').trim();

        final rideSourceCoords = await _tryGeocodeLocation(rideFrom);
        final rideDestCoords = await _tryGeocodeLocation(rideTo);

        if (rideSourceCoords == null || rideDestCoords == null) {
          ride['overlap_score'] = 0.0;
          continue;
        }

        final score = _calculateOverlapScore(
          querySourceLat: querySourceCoords['lat']!,
          querySourceLng: querySourceCoords['lng']!,
          queryDestLat: queryDestCoords['lat']!,
          queryDestLng: queryDestCoords['lng']!,
          rideSourceLat: rideSourceCoords['lat']!,
          rideSourceLng: rideSourceCoords['lng']!,
          rideDestLat: rideDestCoords['lat']!,
          rideDestLng: rideDestCoords['lng']!,
        );
        ride['overlap_score'] = score;
      }

      enriched.sort((a, b) {
        final scoreA = (a['overlap_score'] as num?)?.toDouble() ?? 0;
        final scoreB = (b['overlap_score'] as num?)?.toDouble() ?? 0;
        if (scoreB != scoreA) {
          return scoreB.compareTo(scoreA);
        }
        return (a['ride_date'] as String).compareTo(b['ride_date'] as String);
      });
    } else {
      enriched.sort((a, b) => (a['ride_date'] as String).compareTo(b['ride_date'] as String));
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

  /// Check route compatibility using Supabase Edge Function
  /// Sends source and destination coordinates to check if they lie on existing routes
  /// or if adding them causes acceptable deviation (<10 min)
  /// Done using edge functions on supabase
  Future<List<Map<String, dynamic>>> checkRouteCompatibility({
    required double sourceLat,
    required double sourceLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'check-route-compatibility',
        body: {
          'source_lat': sourceLat,
          'source_lng': sourceLng,
          'dest_lat': destLat,
          'dest_lng': destLng,
        },
      );

      if (response.status != 200) {
        throw Exception('Edge function error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      final routeId = data['route_id'] as String?;
      if (routeId == null || routeId.isEmpty) {
        // throw Exception('Edge function returned no route_id.');
        //Return empty Postgres array instead of throwing error to indicate no compatible route found
        return [];
      }
      // Run a supabase dbms query into rides to check for rides with the returned route_id and return the ride_id(s) if found such that status is 'active' and there are seats
      final rides = await _supabase
          .from('rides')
          .select('ride_id')
          .eq('route_id', routeId)
          .eq('status', 'active')
          .gt('available_seats', 0);
      return rides;

    } catch (e) {
      throw Exception('Failed to check route compatibility: $e');
    }
  }

  double _calculateOverlapScore({
    required double querySourceLat,
    required double querySourceLng,
    required double queryDestLat,
    required double queryDestLng,
    required double rideSourceLat,
    required double rideSourceLng,
    required double rideDestLat,
    required double rideDestLng,
  }) {
    final sourceDistanceKm =
        _haversineKm(querySourceLat, querySourceLng, rideSourceLat, rideSourceLng);
    final destDistanceKm =
        _haversineKm(queryDestLat, queryDestLng, rideDestLat, rideDestLng);

    final queryLengthKm =
        _haversineKm(querySourceLat, querySourceLng, queryDestLat, queryDestLng);
    final rideLengthKm =
        _haversineKm(rideSourceLat, rideSourceLng, rideDestLat, rideDestLng);

    final queryBearing =
        _bearingDegrees(querySourceLat, querySourceLng, queryDestLat, queryDestLng);
    final rideBearing =
        _bearingDegrees(rideSourceLat, rideSourceLng, rideDestLat, rideDestLng);

    final sourceScore = _clamp01(1 - (sourceDistanceKm / 40));
    final destScore = _clamp01(1 - (destDistanceKm / 80));
    final directionScore = _clamp01(1 - (_angleDifference(queryBearing, rideBearing) / 180));
    final directionCosine = _directionCosine(
      querySourceLat: querySourceLat,
      querySourceLng: querySourceLng,
      queryDestLat: queryDestLat,
      queryDestLng: queryDestLng,
      rideSourceLat: rideSourceLat,
      rideSourceLng: rideSourceLng,
      rideDestLat: rideDestLat,
      rideDestLng: rideDestLng,
    );
    final directionConsistency = _clamp01((directionCosine + 1) / 2);
    final detourScore = _clamp01(
      1 - ((rideLengthKm - queryLengthKm).abs() / math.max(queryLengthKm, 1)),
    );

    final weighted =
        (0.38 * sourceScore) +
        (0.32 * destScore) +
        (0.20 * directionScore) +
        (0.10 * detourScore);

    var score = 100 * _clamp01(weighted) * directionConsistency;

    final angle = _angleDifference(queryBearing, rideBearing);
    final strongOppositeDirection = directionCosine < -0.35 || angle > 120;
    if (strongOppositeDirection) {
      score = math.min(score, 15);
    }

    return score;
  }

  double _directionCosine({
    required double querySourceLat,
    required double querySourceLng,
    required double queryDestLat,
    required double queryDestLng,
    required double rideSourceLat,
    required double rideSourceLng,
    required double rideDestLat,
    required double rideDestLng,
  }) {
    final meanLatRad =
        _toRadians((querySourceLat + queryDestLat + rideSourceLat + rideDestLat) / 4);

    final qDx = (queryDestLng - querySourceLng) * math.cos(meanLatRad);
    final qDy = (queryDestLat - querySourceLat);
    final rDx = (rideDestLng - rideSourceLng) * math.cos(meanLatRad);
    final rDy = (rideDestLat - rideSourceLat);

    final qMag = math.sqrt((qDx * qDx) + (qDy * qDy));
    final rMag = math.sqrt((rDx * rDx) + (rDy * rDy));
    if (qMag == 0 || rMag == 0) {
      return 0;
    }

    final cosine = ((qDx * rDx) + (qDy * rDy)) / (qMag * rMag);
    return cosine.clamp(-1.0, 1.0);
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _bearingDegrees(double lat1, double lng1, double lat2, double lng2) {
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);
    final dLngRad = _toRadians(lng2 - lng1);

    final y = math.sin(dLngRad) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLngRad);

    final bearing = (math.atan2(y, x) * 180 / math.pi + 360) % 360;
    return bearing;
  }

  double _angleDifference(double a, double b) {
    final diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);

  double _clamp01(double value) {
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return value;
  }

  Future<Map<String, double>?> _tryGeocodeLocation(String address) async {
    if (address.trim().isEmpty) {
      return null;
    }
    try {
      return await _geocodeLocation(address);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, double>> _geocodeLocation(String address) async {
    final normalized = address.trim().toLowerCase();
    final cached = _geocodeCache[normalized];
    if (cached != null) {
      return cached;
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': address,
      'format': 'json',
      'limit': '1',
    });

    final response = await http.get(uri, headers: {
      'User-Agent': 'Voyager/1.0 (contact@yourdomain.com)',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to geocode "$address": ${response.statusCode}');
    }

    final body = json.decode(response.body);
    if (body is! List || body.isEmpty) {
      throw Exception('No geocoding results for "$address"');
    }

    final first = body.first as Map<String, dynamic>;
    final coords = {
      'lat': double.parse(first['lat'] as String),
      'lng': double.parse(first['lon'] as String),
    };
    _geocodeCache[normalized] = coords;
    return coords;
  }

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
