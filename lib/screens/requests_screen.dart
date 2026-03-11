// screens/requests_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/ride_service.dart';
import '../services/swap_service.dart';
import '../services/ticket_service.dart';
import '../models/swap_request_model.dart';
import '../utils/user_helper.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RideService _rideService = RideService();
  final SwapService _swapService = SwapService();
  final TicketService _ticketService = TicketService();

  String? _supabaseUserId;
  bool _loading = true;

  // Join requests (ride bookings on user's posted rides)
  List<Map<String, dynamic>> _joinRequests = [];
  
  // Approval requests (bookings where this user needs to vote)
  List<Map<String, dynamic>> _approvalRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userInfo = await UserHelper.getCurrentSupabaseUser();
      _supabaseUserId = userInfo['user_id'] as String;
      await Future.wait([
        _loadJoinRequests(),
        _loadApprovalRequests(),
      ]);
    } catch (e) {
      // User may not be synced yet
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadJoinRequests() async {
    if (_supabaseUserId == null) return;
    try {
      // Get rides posted by user
      final userRides = await _rideService.getUserRides(_supabaseUserId!);
      List<Map<String, dynamic>> allBookings = [];

      for (var ride in userRides) {
        final bookings =
            await _rideService.getRideBookings(ride['ride_id']);
        for (var booking in bookings) {
          booking['from_location'] = ride['from_location'];
          booking['to_location'] = ride['to_location'];
          booking['ride_date'] = ride['ride_date'];
          booking['ride_time'] = ride['ride_time'];
          allBookings.add(booking);
        }
      }

      if (mounted) {
        setState(() => _joinRequests = allBookings);
      }
    } catch (e) {
      // silently fail
    }
  }

  Future<void> _loadApprovalRequests() async {
    if (_supabaseUserId == null) return;
    try {
      // This would need a stream subscription in production, but for now we'll poll
      final stream = _rideService.getPendingApprovals(_supabaseUserId!);
      final approvals = await stream.first;
      
      if (mounted) {
        setState(() => _approvalRequests = approvals);
      }
    } catch (e) {
      // silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          AppLocalizations.of(context)!.requests,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.manageRequests,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabButton(
                                '${AppLocalizations.of(context)!.joinRequests} (${_joinRequests.where((b) => b['status'] == 'pending').length})',
                                0),
                            const SizedBox(width: 12),
                            _buildTabButton(
                                'Approval Requests (${_approvalRequests.length})',
                                1),
                            const SizedBox(width: 12),
                            _buildTabButton(AppLocalizations.of(context)!.swapRequests, 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildJoinRequestsList(),
                      _buildApprovalRequestsList(),
                      _buildSwapRequestsList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00B25E)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B25E)
                : Theme.of(context).dividerColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  // ─── JOIN REQUESTS TAB ────────────────────────────────────────────────

  Widget _buildJoinRequestsList() {
    if (_joinRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.noJoinRequests,
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.bookingAppearsHere,
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJoinRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _joinRequests.length,
        itemBuilder: (context, index) {
          final booking = _joinRequests[index];
          return _buildJoinRequestCard(booking);
        },
      ),
    );
  }

  Widget _buildJoinRequestCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';
    final riderName = booking['rider_name'] ?? 'Unknown';
    final from = booking['from_location'] ?? '';
    final to = booking['to_location'] ?? '';
    final date = booking['ride_date'] ?? '';
    final time = booking['ride_time'] ?? '';
    final seats = booking['seats_booked'] ?? 1;
    final totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riderName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      '$seats seat(s) • ₹${totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (!isPending)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRejected
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF00B25E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isRejected ? Colors.red : const Color(0xFF00B25E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Color(0xFF00B25E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$from → $to',
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            Theme.of(context).textTheme.bodyMedium?.color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$date • $time',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _rideService
                              .approveBooking(booking['booking_id'], _supabaseUserId!);
                          _loadJoinRequests();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.bookingApproved),
                                backgroundColor: const Color(0xFF00B25E),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B25E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(AppLocalizations.of(context)!.approve,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          await _rideService
                              .rejectBooking(booking['booking_id'], _supabaseUserId!);
                          _loadJoinRequests();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.bookingRejected),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.reject,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── APPROVAL REQUESTS TAB ────────────────────────────────────────────

  Widget _buildApprovalRequestsList() {
    if (_approvalRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_vote_outlined, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No Pending Approvals',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 4),
            Text('Approval requests will appear here',
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApprovalRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _approvalRequests.length,
        itemBuilder: (context, index) {
          final approval = _approvalRequests[index];
          return _buildApprovalRequestCard(approval);
        },
      ),
    );
  }

  Widget _buildApprovalRequestCard(Map<String, dynamic> approval) {
    final booking = approval['booking'] as Map<String, dynamic>;
    final ride = approval['ride'] as Map<String, dynamic>;
    final requesterName = approval['requester_name'] ?? 'Unknown';
    final seatsRequested = approval['seats_requested'] ?? 1;
    final from = ride['from_location'] ?? '';
    final to = ride['to_location'] ?? '';
    final date = ride['ride_date'] ?? '';
    final time = ride['ride_time'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.how_to_vote, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$requesterName wants to join',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      '$seatsRequested seat(s) requested',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: Color(0xFF00B25E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('$from → $to',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$date • $time',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All passengers must approve before this person can join',
                    style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _rideService.approveBooking(
                            booking['booking_id'], _supabaseUserId!);
                        await _loadApprovalRequests();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You approved this request'),
                              backgroundColor: Color(0xFF00B25E),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B25E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Approve',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await _rideService.rejectBooking(
                            booking['booking_id'], _supabaseUserId!);
                        await _loadApprovalRequests();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You rejected this request'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Reject',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SWAP REQUESTS TAB ────────────────────────────────────────────────

  Widget _buildSwapRequestsList() {
    if (_supabaseUserId == null) {
      return Center(child: Text(AppLocalizations.of(context)!.notLoggedIn));
    }

    return StreamBuilder<List<SwapRequestModel>>(
      stream: _swapService.getReceivedRequests(_supabaseUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 56, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.noSwapRequests,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                    AppLocalizations.of(context)!.swapAppearsHere,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return _buildSwapRequestCard(requests[index]);
          },
        );
      },
    );
  }

  Widget _buildSwapRequestCard(SwapRequestModel request) {
    final isPending = request.status == 'pending';
    final isRejected = request.status == 'rejected';

    return FutureBuilder(
      future: _ticketService.getTicketById(request.ticketId),
      builder: (context, snapshot) {
        final ticket = snapshot.data;
        final ticketInfo = ticket != null
            ? '${ticket.fromLocation} → ${ticket.toLocation}'
            : 'Loading...';
        final ticketDate = ticket != null
            ? DateFormat('dd MMM yyyy').format(ticket.date)
            : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz,
                        color: Colors.purple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.requesterName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (request.message != null &&
                            request.message!.isNotEmpty)
                          Text(
                            '"${request.message}"',
                            style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  if (!isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRejected
                            ? Colors.red.withOpacity(0.1)
                            : const Color(0xFF00B25E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isRejected
                              ? Colors.red
                              : const Color(0xFF00B25E),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.ticket,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticketInfo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (ticketDate.isNotEmpty)
                      Text(
                        ticketDate,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await _swapService.acceptSwapRequest(
                                  request.requestId, request.ticketId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!.swapRequestAccepted),
                                    backgroundColor: const Color(0xFF00B25E),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Failed: $e'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B25E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(AppLocalizations.of(context)!.accept,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () async {
                            try {
                              await _swapService
                                  .rejectSwapRequest(request.requestId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!.swapRequestRejected),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Failed: $e'),
                                      backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Theme.of(context).dividerColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.reject,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
