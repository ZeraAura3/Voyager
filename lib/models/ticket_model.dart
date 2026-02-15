// lib/models/ticket_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a ticket in the swap system
/// Can be of type: buy, sell, or swap
class TicketModel {
  final String ticketId;
  final String userId;
  final String userName;
  final String userPhone;
  final String tradeType; // 'buy', 'sell', 'swap'
  final String status; // 'active', 'completed', 'cancelled'
  final String fromLocation;
  final String toLocation;
  final DateTime date;
  final String time;
  final double price;
  final String description;
  final String? ticketImageUrl; // Photo proof of the ticket
  final DateTime createdAt;
  final DateTime? updatedAt;

  TicketModel({
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.tradeType,
    required this.status,
    required this.fromLocation,
    required this.toLocation,
    required this.date,
    required this.time,
    required this.price,
    required this.description,
    this.ticketImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert TicketModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'tradeType': tradeType,
      'status': status,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'date': Timestamp.fromDate(date),
      'time': time,
      'price': price,
      'description': description,
      'ticketImageUrl': ticketImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create TicketModel from Firebase document
  factory TicketModel.fromMap(Map<String, dynamic> map, String id) {
    return TicketModel(
      ticketId: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      tradeType: map['tradeType'] ?? 'swap',
      status: map['status'] ?? 'active',
      fromLocation: map['fromLocation'] ?? '',
      toLocation: map['toLocation'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      ticketImageUrl: map['ticketImageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create a copy of TicketModel with updated fields
  TicketModel copyWith({
    String? ticketId,
    String? userId,
    String? userName,
    String? userPhone,
    String? tradeType,
    String? status,
    String? fromLocation,
    String? toLocation,
    DateTime? date,
    String? time,
    double? price,
    String? description,
    String? ticketImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      ticketId: ticketId ?? this.ticketId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      tradeType: tradeType ?? this.tradeType,
      status: status ?? this.status,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      description: description ?? this.description,
      ticketImageUrl: ticketImageUrl ?? this.ticketImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to Supabase format for history
  Map<String, dynamic> toSupabaseMap() {
    return {
      'ticket_id': ticketId,
      'user_id': userId,
      'username': userName,
      'phone_number': userPhone,
      'trade_type': tradeType,
      'status': status,
      'from_location': fromLocation,
      'to_location': toLocation,
      'date': date.toIso8601String(),
      'time': time,
      'price': price,
      'description': description,
      'ticket_image_url': ticketImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TicketModel(ticketId: $ticketId, tradeType: $tradeType, from: $fromLocation, to: $toLocation, status: $status)';
  }
}
