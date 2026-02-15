// lib/services/ticket_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

/// Service for managing tickets in Supabase
class TicketService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new ticket
  Future<TicketModel> createTicket(TicketModel ticket) async {
    try {
      final response = await _supabase
          .from('tickets')
          .insert({
            'user_id': ticket.userId,
            'trade_type': ticket.tradeType,
            'status': ticket.status,
            'from_location': ticket.fromLocation,
            'to_location': ticket.toLocation,
            'ride_date': ticket.date.toIso8601String().split('T')[0],
            'ride_time': ticket.time,
            'price': ticket.price,
            'description': ticket.description,
            'ticket_image_url': ticket.ticketImageUrl,
          })
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('Failed to create ticket: No data returned');
      }

      return TicketModel(
        ticketId: response['ticket_id'],
        userId: response['user_id'],
        userName: ticket.userName,
        userPhone: ticket.userPhone,
        tradeType: response['trade_type'],
        status: response['status'],
        fromLocation: response['from_location'],
        toLocation: response['to_location'],
        date: DateTime.parse(response['ride_date']),
        time: response['ride_time'],
        price: (response['price'] as num).toDouble(),
        description: response['description'] ?? '',
        ticketImageUrl: response['ticket_image_url'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : null,
      );
    } catch (e) {
      throw Exception('Failed to create ticket: $e');
    }
  }

  /// Get all active tickets
  Stream<List<TicketModel>> getActiveTickets() {
    return _supabase
        .from('tickets')
        .stream(primaryKey: ['ticket_id'])
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          List<TicketModel> tickets = [];
          for (var item in data) {
            // Fetch user info from users table
            final userInfo = await _getUserInfo(item['user_id']);

            tickets.add(TicketModel(
              ticketId: item['ticket_id'],
              userId: item['user_id'],
              userName: userInfo['full_name'] ?? 'Unknown',
              userPhone: userInfo['roll_no'] ?? '',
              tradeType: item['trade_type'],
              status: item['status'],
              fromLocation: item['from_location'],
              toLocation: item['to_location'],
              date: DateTime.parse(item['ride_date']),
              time: item['ride_time'],
              price: (item['price'] as num).toDouble(),
              description: item['description'] ?? '',
              ticketImageUrl: item['ticket_image_url'],
              createdAt: DateTime.parse(item['created_at']),
              updatedAt: item['updated_at'] != null
                  ? DateTime.parse(item['updated_at'])
                  : null,
            ));
          }
          return tickets;
        });
  }

  /// Get tickets by user ID
  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _supabase
        .from('tickets')
        .stream(primaryKey: ['ticket_id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          List<TicketModel> tickets = [];
          for (var item in data) {
            final userInfo = await _getUserInfo(item['user_id']);

            tickets.add(TicketModel(
              ticketId: item['ticket_id'],
              userId: item['user_id'],
              userName: userInfo['full_name'] ?? 'Unknown',
              userPhone: userInfo['roll_no'] ?? '',
              tradeType: item['trade_type'],
              status: item['status'],
              fromLocation: item['from_location'],
              toLocation: item['to_location'],
              date: DateTime.parse(item['ride_date']),
              time: item['ride_time'],
              price: (item['price'] as num).toDouble(),
              description: item['description'] ?? '',
              ticketImageUrl: item['ticket_image_url'],
              createdAt: DateTime.parse(item['created_at']),
              updatedAt: item['updated_at'] != null
                  ? DateTime.parse(item['updated_at'])
                  : null,
            ));
          }
          return tickets;
        });
  }

  /// Get tickets by trade type (buy/sell/swap)
  Stream<List<TicketModel>> getTicketsByType(String tradeType) {
    return _supabase
        .from('tickets')
        .stream(primaryKey: ['ticket_id'])
        .eq('trade_type', tradeType)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          List<TicketModel> tickets = [];
          for (var item in data) {
            if (item['trade_type'] == tradeType && item['status'] == 'active') {
              final userInfo = await _getUserInfo(item['user_id']);

              tickets.add(TicketModel(
                ticketId: item['ticket_id'],
                userId: item['user_id'],
                userName: userInfo['full_name'] ?? 'Unknown',
                userPhone: userInfo['roll_no'] ?? '',
                tradeType: item['trade_type'],
                status: item['status'],
                fromLocation: item['from_location'],
                toLocation: item['to_location'],
                date: DateTime.parse(item['ride_date']),
                time: item['ride_time'],
                price: (item['price'] as num).toDouble(),
                description: item['description'] ?? '',
                ticketImageUrl: item['ticket_image_url'],
                createdAt: DateTime.parse(item['created_at']),
                updatedAt: item['updated_at'] != null
                    ? DateTime.parse(item['updated_at'])
                    : null,
              ));
            }
          }
          return tickets;
        });
  }

  /// Get a single ticket by ID
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('ticket_id', ticketId)
          .single();

      final userInfo = await _getUserInfo(response['user_id']);

      return TicketModel(
        ticketId: response['ticket_id'],
        userId: response['user_id'],
        userName: userInfo['full_name'] ?? 'Unknown',
        userPhone: userInfo['roll_no'] ?? '',
        tradeType: response['trade_type'],
        status: response['status'],
        fromLocation: response['from_location'],
        toLocation: response['to_location'],
        date: DateTime.parse(response['ride_date']),
        time: response['ride_time'],
        price: (response['price'] as num).toDouble(),
        description: response['description'] ?? '',
        ticketImageUrl: response['ticket_image_url'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update ticket
  Future<void> updateTicket(TicketModel ticket) async {
    try {
      await _supabase.from('tickets').update({
        'trade_type': ticket.tradeType,
        'status': ticket.status,
        'from_location': ticket.fromLocation,
        'to_location': ticket.toLocation,
        'ride_date': ticket.date.toIso8601String().split('T')[0],
        'ride_time': ticket.time,
        'price': ticket.price,
        'description': ticket.description,
        'ticket_image_url': ticket.ticketImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('ticket_id', ticket.ticketId);
    } catch (e) {
      throw Exception('Failed to update ticket: $e');
    }
  }

  /// Update ticket status
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      await _supabase.from('tickets').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('ticket_id', ticketId);
    } catch (e) {
      throw Exception('Failed to update ticket status: $e');
    }
  }

  /// Delete ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _supabase.from('tickets').delete().eq('ticket_id', ticketId);
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }

  /// Search tickets by location
  Future<List<TicketModel>> searchTickets({
    String? fromLocation,
    String? toLocation,
    double? maxPrice,
    String? tradeType,
  }) async {
    try {
      var query = _supabase.from('tickets').select().eq('status', 'active');

      if (fromLocation != null && fromLocation.isNotEmpty) {
        query = query.ilike('from_location', '%$fromLocation%');
      }

      if (toLocation != null && toLocation.isNotEmpty) {
        query = query.ilike('to_location', '%$toLocation%');
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (tradeType != null && tradeType.isNotEmpty) {
        query = query.eq('trade_type', tradeType);
      }

      final response = await query.order('created_at', ascending: false);

      List<TicketModel> tickets = [];
      for (var item in response) {
        final userInfo = await _getUserInfo(item['user_id']);

        tickets.add(TicketModel(
          ticketId: item['ticket_id'],
          userId: item['user_id'],
          userName: userInfo['full_name'] ?? 'Unknown',
          userPhone: userInfo['roll_no'] ?? '',
          tradeType: item['trade_type'],
          status: item['status'],
          fromLocation: item['from_location'],
          toLocation: item['to_location'],
          date: DateTime.parse(item['ride_date']),
          time: item['ride_time'],
          price: (item['price'] as num).toDouble(),
          description: item['description'] ?? '',
          ticketImageUrl: item['ticket_image_url'],
          createdAt: DateTime.parse(item['created_at']),
          updatedAt: item['updated_at'] != null
              ? DateTime.parse(item['updated_at'])
              : null,
        ));
      }
      return tickets;
    } catch (e) {
      throw Exception('Failed to search tickets: $e');
    }
  }

  /// Helper method to fetch user info
  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('full_name, roll_no')
          .eq('user_id', userId)
          .maybeSingle();
      return response ?? {'full_name': 'Unknown', 'roll_no': ''};
    } catch (e) {
      return {'full_name': 'Unknown', 'roll_no': ''};
    }
  }
}
