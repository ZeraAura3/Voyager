// lib/models/swap_request_model.dart

/// Represents a swap request from one user to another
/// Tracks the status of swap negotiations
class SwapRequestModel {
  final String requestId;
  final String ticketId;
  final String ticketOwnerId;
  final String requestedBy; // User ID who is requesting the swap
  final String status; // 'pending', 'accepted', 'rejected'
  final String? message; // Optional message from requester
  final DateTime createdAt;
  final DateTime? respondedAt;

  // Enriched fields (looked up from users table, not stored in swap_requests)
  final String? requesterName;
  final String? requesterPhone;

  SwapRequestModel({
    required this.requestId,
    required this.ticketId,
    required this.ticketOwnerId,
    required this.requestedBy,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
    this.requesterName,
    this.requesterPhone,
  });

  /// Create from Supabase response
  factory SwapRequestModel.fromSupabase(Map<String, dynamic> map) {
    return SwapRequestModel(
      requestId: map['request_id'] ?? '',
      ticketId: map['ticket_id'] ?? '',
      ticketOwnerId: map['ticket_owner_id'] ?? '',
      requestedBy: map['requested_by'] ?? '',
      status: map['status'] ?? 'pending',
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
      respondedAt: map['responded_at'] != null
          ? DateTime.parse(map['responded_at'])
          : null,
    );
  }

  /// Create a copy of SwapRequestModel with updated fields
  SwapRequestModel copyWith({
    String? requestId,
    String? ticketId,
    String? ticketOwnerId,
    String? requestedBy,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? requesterName,
    String? requesterPhone,
  }) {
    return SwapRequestModel(
      requestId: requestId ?? this.requestId,
      ticketId: ticketId ?? this.ticketId,
      ticketOwnerId: ticketOwnerId ?? this.ticketOwnerId,
      requestedBy: requestedBy ?? this.requestedBy,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
    );
  }

  @override
  String toString() {
    return 'SwapRequestModel(requestId: $requestId, ticketId: $ticketId, status: $status, requester: $requesterName)';
  }
}
