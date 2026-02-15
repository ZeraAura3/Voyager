// lib/models/swap_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a swap request from one user to another
/// Tracks the status of swap negotiations
class SwapRequestModel {
  final String requestId;
  final String ticketId;
  final String ticketOwnerId;
  final String requestedBy; // User ID who is requesting the swap
  final String requesterName;
  final String requesterPhone;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? message; // Optional message from requester
  final DateTime createdAt;
  final DateTime? respondedAt;

  SwapRequestModel({
    required this.requestId,
    required this.ticketId,
    required this.ticketOwnerId,
    required this.requestedBy,
    required this.requesterName,
    required this.requesterPhone,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  /// Convert SwapRequestModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'ticketId': ticketId,
      'ticketOwnerId': ticketOwnerId,
      'requestedBy': requestedBy,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'status': status,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  /// Create SwapRequestModel from Firebase document
  factory SwapRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return SwapRequestModel(
      requestId: id,
      ticketId: map['ticketId'] ?? '',
      ticketOwnerId: map['ticketOwnerId'] ?? '',
      requestedBy: map['requestedBy'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhone: map['requesterPhone'] ?? '',
      status: map['status'] ?? 'pending',
      message: map['message'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create a copy of SwapRequestModel with updated fields
  SwapRequestModel copyWith({
    String? requestId,
    String? ticketId,
    String? ticketOwnerId,
    String? requestedBy,
    String? requesterName,
    String? requesterPhone,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return SwapRequestModel(
      requestId: requestId ?? this.requestId,
      ticketId: ticketId ?? this.ticketId,
      ticketOwnerId: ticketOwnerId ?? this.ticketOwnerId,
      requestedBy: requestedBy ?? this.requestedBy,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  String toString() {
    return 'SwapRequestModel(requestId: $requestId, ticketId: $ticketId, status: $status, requester: $requesterName)';
  }
}
