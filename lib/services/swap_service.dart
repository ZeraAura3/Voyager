// lib/services/swap_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/swap_request_model.dart';
import 'ticket_service.dart';
import 'history_service.dart';

/// Service for managing swap requests between users
class SwapService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TicketService _ticketService = TicketService();
  final HistoryService _historyService = HistoryService();

  /// Create a swap request
  Future<SwapRequestModel> createSwapRequest({
    required String ticketId,
    required String ticketOwnerId,
    required String requestedBy,
    required String requesterName,
    required String requesterPhone,
    String? message,
  }) async {
    try {
      // Check if user already has a pending request for this ticket
      final existingRequest = await _supabase
          .from('swap_requests')
          .select()
          .eq('ticket_id', ticketId)
          .eq('requested_by', requestedBy)
          .eq('status', 'pending');

      if (existingRequest.isNotEmpty) {
        throw Exception('You already have a pending request for this ticket');
      }

      final response = await _supabase
          .from('swap_requests')
          .insert({
            'ticket_id': ticketId,
            'ticket_owner_id': ticketOwnerId,
            'requested_by': requestedBy,
            'requester_name': requesterName,
            'requester_phone': requesterPhone,
            'status': 'pending',
            'message': message,
          })
          .select()
          .single();

      return SwapRequestModel(
        requestId: response['request_id'],
        ticketId: response['ticket_id'],
        ticketOwnerId: response['ticket_owner_id'],
        requestedBy: response['requested_by'],
        requesterName: response['requester_name'],
        requesterPhone: response['requester_phone'],
        status: response['status'],
        message: response['message'],
        createdAt: DateTime.parse(response['created_at']),
        respondedAt: response['responded_at'] != null
            ? DateTime.parse(response['responded_at'])
            : null,
      );
    } catch (e) {
      throw Exception('Failed to create swap request: $e');
    }
  }

  /// Get swap requests for a specific ticket
  Stream<List<SwapRequestModel>> getTicketRequests(String ticketId) {
    return _supabase
        .from('swap_requests')
        .stream(primaryKey: ['request_id'])
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((item) => SwapRequestModel(
                  requestId: item['request_id'],
                  ticketId: item['ticket_id'],
                  ticketOwnerId: item['ticket_owner_id'],
                  requestedBy: item['requested_by'],
                  requesterName: item['requester_name'],
                  requesterPhone: item['requester_phone'],
                  status: item['status'],
                  message: item['message'],
                  createdAt: DateTime.parse(item['created_at']),
                  respondedAt: item['responded_at'] != null
                      ? DateTime.parse(item['responded_at'])
                      : null,
                ))
            .toList());
  }

  /// Get swap requests received by user (as ticket owner)
  Stream<List<SwapRequestModel>> getReceivedRequests(String userId) {
    return _supabase
        .from('swap_requests')
        .stream(primaryKey: ['request_id'])
        .eq('ticket_owner_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((item) => SwapRequestModel(
                  requestId: item['request_id'],
                  ticketId: item['ticket_id'],
                  ticketOwnerId: item['ticket_owner_id'],
                  requestedBy: item['requested_by'],
                  requesterName: item['requester_name'],
                  requesterPhone: item['requester_phone'],
                  status: item['status'],
                  message: item['message'],
                  createdAt: DateTime.parse(item['created_at']),
                  respondedAt: item['responded_at'] != null
                      ? DateTime.parse(item['responded_at'])
                      : null,
                ))
            .toList());
  }

  /// Get swap requests sent by user (as requester)
  Stream<List<SwapRequestModel>> getSentRequests(String userId) {
    return _supabase
        .from('swap_requests')
        .stream(primaryKey: ['request_id'])
        .eq('requested_by', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((item) => SwapRequestModel(
                  requestId: item['request_id'],
                  ticketId: item['ticket_id'],
                  ticketOwnerId: item['ticket_owner_id'],
                  requestedBy: item['requested_by'],
                  requesterName: item['requester_name'],
                  requesterPhone: item['requester_phone'],
                  status: item['status'],
                  message: item['message'],
                  createdAt: DateTime.parse(item['created_at']),
                  respondedAt: item['responded_at'] != null
                      ? DateTime.parse(item['responded_at'])
                      : null,
                ))
            .toList());
  }

  /// Get pending requests count for user
  Future<int> getPendingRequestsCount(String userId) async {
    try {
      final response = await _supabase
          .from('swap_requests')
          .select('request_id')
          .eq('ticket_owner_id', userId)
          .eq('status', 'pending');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Accept a swap request
  Future<void> acceptSwapRequest(String requestId, String ticketId) async {
    try {
      // Update swap request status
      await _supabase.from('swap_requests').update({
        'status': 'accepted',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('request_id', requestId);

      // Update ticket status to completed
      await _ticketService.updateTicketStatus(ticketId, 'completed');

      // Get ticket info and save to history
      final ticket = await _ticketService.getTicketById(ticketId);
      if (ticket != null) {
        final request = await _getRequestById(requestId);
        if (request != null) {
          await _historyService.saveTicketToHistory(
            ticket,
            completedBy: request.requestedBy,
          );
        }
      }

      // Reject all other pending requests for this ticket
      await _rejectOtherRequests(ticketId, requestId);
    } catch (e) {
      throw Exception('Failed to accept swap request: $e');
    }
  }

  /// Reject a swap request
  Future<void> rejectSwapRequest(String requestId) async {
    try {
      await _supabase.from('swap_requests').update({
        'status': 'rejected',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('request_id', requestId);
    } catch (e) {
      throw Exception('Failed to reject swap request: $e');
    }
  }

  /// Cancel a swap request (by requester)
  Future<void> cancelSwapRequest(String requestId) async {
    try {
      await _supabase
          .from('swap_requests')
          .delete()
          .eq('request_id', requestId);
    } catch (e) {
      throw Exception('Failed to cancel swap request: $e');
    }
  }

  /// Reject all other pending requests for a ticket (when one is accepted)
  Future<void> _rejectOtherRequests(
      String ticketId, String acceptedRequestId) async {
    try {
      await _supabase
          .from('swap_requests')
          .update({
            'status': 'rejected',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('ticket_id', ticketId)
          .eq('status', 'pending')
          .neq('request_id', acceptedRequestId);
    } catch (e) {
      // Log error but don't throw
      print('Warning: Failed to reject other requests: $e');
    }
  }

  /// Get a single swap request by ID
  Future<SwapRequestModel?> _getRequestById(String requestId) async {
    try {
      final response = await _supabase
          .from('swap_requests')
          .select()
          .eq('request_id', requestId)
          .single();

      return SwapRequestModel(
        requestId: response['request_id'],
        ticketId: response['ticket_id'],
        ticketOwnerId: response['ticket_owner_id'],
        requestedBy: response['requested_by'],
        requesterName: response['requester_name'],
        requesterPhone: response['requester_phone'],
        status: response['status'],
        message: response['message'],
        createdAt: DateTime.parse(response['created_at']),
        respondedAt: response['responded_at'] != null
            ? DateTime.parse(response['responded_at'])
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get swap request with ticket details
  Future<Map<String, dynamic>?> getRequestWithTicket(String requestId) async {
    try {
      final request = await _getRequestById(requestId);
      if (request == null) return null;

      final ticket = await _ticketService.getTicketById(request.ticketId);
      if (ticket == null) return null;

      return {
        'request': request,
        'ticket': ticket,
      };
    } catch (e) {
      return null;
    }
  }
}
