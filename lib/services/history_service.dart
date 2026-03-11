// lib/services/history_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

/// Service for managing ticket history in Supabase
/// Keeps audit trail of completed swaps/trades
class HistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Save completed ticket to history
  Future<void> saveTicketToHistory(
    TicketModel ticket, {
    String? completedBy,
  }) async {
    try {
      await _supabase.from('tickets_history').insert({
        'ticket_id': ticket.ticketId,
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
        'completed_by': completedBy,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save ticket to history: $e');
    }
  }

  /// Get user's ticket history
  Future<List<Map<String, dynamic>>> getUserHistory(String userId) async {
    try {
      final response = await _supabase
          .from('tickets_history')
          .select()
          .or('user_id.eq.$userId,completed_by.eq.$userId')
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get user history: $e');
    }
  }

  /// Get user's ticket history stream
  Stream<List<Map<String, dynamic>>> getUserHistoryStream(String userId) {
    return _supabase
        .from('tickets_history')
        .stream(primaryKey: ['history_id'])
        .eq('user_id', userId)
        .order('completed_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Get statistics for user
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get all history for user
      final history = await getUserHistory(userId);

      // Count by trade type
      int buyCount = 0;
      int sellCount = 0;
      int swapCount = 0;
      double totalSpent = 0.0;
      double totalEarned = 0.0;

      for (var item in history) {
        final tradeType = item['trade_type'] as String;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final isOwner = item['user_id'] == userId;

        if (tradeType == 'buy') {
          buyCount++;
          if (!isOwner) totalSpent += price; // User bought this ticket
        } else if (tradeType == 'sell') {
          sellCount++;
          if (isOwner) totalEarned += price; // User sold their ticket
        } else if (tradeType == 'swap') {
          swapCount++;
        }
      }

      return {
        'totalTransactions': history.length,
        'buyCount': buyCount,
        'sellCount': sellCount,
        'swapCount': swapCount,
        'totalSpent': totalSpent,
        'totalEarned': totalEarned,
        'netSavings': totalEarned - totalSpent,
      };
    } catch (e) {
      return {
        'totalTransactions': 0,
        'buyCount': 0,
        'sellCount': 0,
        'swapCount': 0,
        'totalSpent': 0.0,
        'totalEarned': 0.0,
        'netSavings': 0.0,
      };
    }
  }

  /// Get recent completed tickets (for dashboard)
  Future<List<Map<String, dynamic>>> getRecentCompletedTickets({
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('tickets_history')
          .select()
          .order('completed_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get recent completed tickets: $e');
    }
  }

  /// Delete history entry (admin only)
  Future<void> deleteHistoryEntry(int historyId) async {
    try {
      await _supabase
          .from('tickets_history')
          .delete()
          .eq('history_id', historyId);
    } catch (e) {
      throw Exception('Failed to delete history entry: $e');
    }
  }

  /// Clear old history (older than specified days)
  Future<void> clearOldHistory({int daysToKeep = 90}) async {
    try {
      final cutoffDate =
          DateTime.now().subtract(Duration(days: daysToKeep)).toIso8601String();

      await _supabase
          .from('tickets_history')
          .delete()
          .lt('completed_at', cutoffDate);
    } catch (e) {
      throw Exception('Failed to clear old history: $e');
    }
  }

  /// Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStats(
    String userId, {
    int? year,
    int? month,
  }) async {
    try {
      final targetYear = year ?? DateTime.now().year;
      final targetMonth = month ?? DateTime.now().month;

      final startDate = DateTime(targetYear, targetMonth, 1);
      final endDate = DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

      final response = await _supabase
          .from('tickets_history')
          .select()
          .or('user_id.eq.$userId,completed_by.eq.$userId')
          .gte('completed_at', startDate.toIso8601String())
          .lte('completed_at', endDate.toIso8601String());

      int count = response.length;
      double totalAmount = 0.0;

      for (var item in response) {
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        totalAmount += price;
      }

      return {
        'month': targetMonth,
        'year': targetYear,
        'totalTransactions': count,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      return {
        'month': month ?? DateTime.now().month,
        'year': year ?? DateTime.now().year,
        'totalTransactions': 0,
        'totalAmount': 0.0,
      };
    }
  }
}
