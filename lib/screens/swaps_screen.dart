// screens/swaps_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import '../models/swap_request_model.dart';
import '../services/ticket_service.dart';
import '../services/swap_service.dart';
import '../services/image_upload_service.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/ticket_image_viewer.dart';
import '../utils/price_calculator.dart';
import '../utils/user_helper.dart';

class SwapsScreen extends StatefulWidget {
  const SwapsScreen({super.key});

  @override
  State<SwapsScreen> createState() => _SwapsScreenState();
}

class _SwapsScreenState extends State<SwapsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Trade',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse or post trade requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTabButton('Browse Trades', 0),
                    const SizedBox(width: 12),
                    _buildTabButton('Post Trade', 1),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const BrowseSwapsTab(),
                PostSwapTab(
                  onPostSuccess: () {
                    if (mounted) {
                      _tabController.animateTo(0);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            final isSelected = _tabController.index == index;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
            );
          },
        ),
      ),
    );
  }
}

// Browse Swaps Tab
class BrowseSwapsTab extends StatefulWidget {
  const BrowseSwapsTab({super.key});

  @override
  State<BrowseSwapsTab> createState() => _BrowseSwapsTabState();
}

class _BrowseSwapsTabState extends State<BrowseSwapsTab> {
  final TicketService _ticketService = TicketService();
  final SwapService _swapService = SwapService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  String _selectedFilter = 'all'; // all, buy, sell, swap
  String? _supabaseUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supabaseUser =
            await UserHelper.getSupabaseUserByFirebaseUid(user.uid);
        // Fallback: if getSupabaseUserByFirebaseUid returns map with user_id, use it.
        // If not found (maybe first time or sync issue), we might need to rely on the ticket.userId
        // matching the firebase UID if the data was migrated that way.
        // But we know ticket.userId is UUID.
        if (mounted && supabaseUser != null) {
          setState(() {
            _supabaseUserId = supabaseUser['user_id'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error fetching current user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Buy', 'buy'),
                const SizedBox(width: 8),
                _buildFilterChip('Sell', 'sell'),
                const SizedBox(width: 8),
                _buildFilterChip('Swap', 'swap'),
              ],
            ),
          ),
        ),
        // Tickets list
        Expanded(
          child: StreamBuilder<List<TicketModel>>(
            stream: _selectedFilter == 'all'
                ? _ticketService.getActiveTickets()
                : _ticketService.getTicketsByType(_selectedFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00B25E),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final tickets = snapshot.data ?? [];

              if (tickets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tickets available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to post a ticket!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  return _buildTicketCard(tickets[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: const Color(0xFF00B25E),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.w600,
      ),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00B25E) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildTicketCard(TicketModel ticket) {
    // Compare with fetched Supabase User ID, fallback to Firebase UID if null (just in case)
    // NOTE: ticket.userId is a UUID from Supabase.
    final isOwnTicket = _supabaseUserId == ticket.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // User info and trade type badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF00B25E),
                      child: Text(
                        ticket.userName.isNotEmpty
                            ? ticket.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(ticket.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        _getTradeTypeColor(ticket.tradeType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.tradeType.toUpperCase(),
                    style: TextStyle(
                      color: _getTradeTypeColor(ticket.tradeType),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ticket image
          if (ticket.ticketImageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TicketImageThumbnail(
                imageUrl: ticket.ticketImageUrl,
                height: 180,
                ticketInfo: '${ticket.fromLocation} → ${ticket.toLocation}',
              ),
            ),

          // Journey details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFF00B25E), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${ticket.fromLocation} → ${ticket.toLocation}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(ticket.date)} at ${ticket.time}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Only show price for 'sell' tickets
                    if (ticket.tradeType == 'sell')
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee,
                              color: Colors.grey, size: 18),
                          Text(
                            ticket.price.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00B25E),
                            ),
                          ),
                        ],
                      )
                    else
                      Chip(
                        label: Text(
                          ticket.tradeType == 'buy'
                              ? 'Looking to Buy'
                              : 'Looking to Swap',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor:
                            const Color(0xFF00B25E).withOpacity(0.1),
                        labelStyle: const TextStyle(color: Color(0xFF00B25E)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    if (!isOwnTicket)
                      ElevatedButton(
                        onPressed: () => _showSwapRequestDialog(ticket),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B25E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Request'),
                      )
                    else
                      IconButton(
                        onPressed: () => _confirmDeleteTicket(ticket),
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Delete Ticket',
                      ),
                  ],
                ),
                if (ticket.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    ticket.description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTradeTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return Colors.blue;
      case 'sell':
        return Colors.orange;
      case 'swap':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _confirmDeleteTicket(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text(
            'Are you sure you want to delete this ticket? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteTicket(ticket);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteTicket(TicketModel ticket) async {
    try {
      // 1. Delete image if exists
      if (ticket.ticketImageUrl != null && ticket.ticketImageUrl!.isNotEmpty) {
        await _imageUploadService.deleteImage(ticket.ticketImageUrl!);
      }

      // 2. Delete ticket from database
      await _ticketService.deleteTicket(ticket.ticketId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket deleted successfully'),
            backgroundColor: Color(0xFF00B25E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSwapRequestDialog(TicketModel ticket) {
    final messageController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to send requests')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Swap Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To: ${ticket.userName}'),
            const SizedBox(height: 8),
            Text('Route: ${ticket.fromLocation} → ${ticket.toLocation}'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a message (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendSwapRequest(ticket, messageController.text);
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSwapRequest(TicketModel ticket, String message) async {
    try {
      // Get current user info from Supabase
      final userInfo = await UserHelper.getCurrentSupabaseUser();
      final supabaseUserId = userInfo['user_id'] as String;

      await _swapService.createSwapRequest(
        ticketId: ticket.ticketId,
        ticketOwnerId: ticket.userId,
        requestedBy: supabaseUserId,
        requesterName: userInfo['full_name'] ?? 'Unknown',
        requesterPhone: userInfo['roll_no'] ?? '',
        message: message.isNotEmpty ? message : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent successfully!'),
            backgroundColor: Color(0xFF00B25E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Post Trade Tab - Continues in next part
class PostSwapTab extends StatefulWidget {
  final VoidCallback? onPostSuccess;

  const PostSwapTab({super.key, this.onPostSuccess});

  @override
  State<PostSwapTab> createState() => _PostSwapTabState();
}

class _PostSwapTabState extends State<PostSwapTab> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TicketService _ticketService = TicketService();
  final ImageUploadService _imageService = ImageUploadService();

  String _selectedTradeType = 'swap';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isPriceFixed = false; // Track if route has fixed price

  @override
  void initState() {
    super.initState();
    // Add listeners to auto-calculate price when locations change
    _fromController.addListener(_updatePriceBasedOnRoute);
    _toController.addListener(_updatePriceBasedOnRoute);
  }

  @override
  void dispose() {
    _fromController.removeListener(_updatePriceBasedOnRoute);
    _toController.removeListener(_updatePriceBasedOnRoute);
    _fromController.dispose();
    _toController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Update price field based on predefined routes
  void _updatePriceBasedOnRoute() {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isNotEmpty && to.isNotEmpty) {
      final calculatedPrice = PriceCalculator.calculatePrice(
        fromLocation: from,
        toLocation: to,
      );

      setState(() {
        if (calculatedPrice != null) {
          _priceController.text = calculatedPrice.toStringAsFixed(0);
          _isPriceFixed = true;
        } else {
          _isPriceFixed = false;
          // Clear price if route changes to non-fixed route
          if (_priceController.text.isNotEmpty) {
            // Only clear if it was a calculated price
            final currentPrice = double.tryParse(_priceController.text);
            if (currentPrice != null) {
              final wasFixedPrice = PriceCalculator.hasFixedPrice(
                fromLocation: from,
                toLocation: to,
              );
              if (!wasFixedPrice) {
                _priceController.clear();
              }
            }
          }
        }
      });
    } else {
      setState(() {
        _isPriceFixed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post Your Ticket',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the details below to post your ticket',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),

            // Trade Type Selection
            Text(
              'Trade Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTradeTypeChip('Buy', 'buy'),
                const SizedBox(width: 8),
                _buildTradeTypeChip('Sell', 'sell'),
                const SizedBox(width: 8),
                _buildTradeTypeChip('Swap', 'swap'),
              ],
            ),
            const SizedBox(height: 20),

            // From Location
            Text(
              'From',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fromController,
              decoration: InputDecoration(
                hintText: 'Enter pickup location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pickup location';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // To Location
            Text(
              'To',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _toController,
              decoration: InputDecoration(
                hintText: 'Enter destination',
                prefixIcon: const Icon(Icons.location_on),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter destination';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(DateFormat('MMM dd, yyyy')
                                  .format(_selectedDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 8),
                              Text(_selectedTime.format(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price - Only show for 'sell' trade type
            if (_selectedTradeType == 'sell') ...[
              Text(
                'Price (₹)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                readOnly: _isPriceFixed,
                decoration: InputDecoration(
                  hintText: _isPriceFixed
                      ? 'Fixed price for this route'
                      : 'Enter price',
                  helperText: _isPriceFixed
                      ? '🔒 Price is fixed for this route and cannot be changed'
                      : 'Enter custom price or select a common route for auto-fill',
                  helperMaxLines: 2,
                  helperStyle: TextStyle(
                    color: _isPriceFixed
                        ? const Color(0xFF00B25E)
                        : Colors.grey[600],
                    fontWeight:
                        _isPriceFixed ? FontWeight.w500 : FontWeight.normal,
                  ),
                  prefixIcon: Icon(
                    _isPriceFixed ? Icons.lock : Icons.currency_rupee,
                    color: _isPriceFixed ? const Color(0xFF00B25E) : null,
                  ),
                  filled: _isPriceFixed,
                  fillColor: _isPriceFixed
                      ? const Color(0xFF00B25E).withOpacity(0.05)
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isPriceFixed
                          ? const Color(0xFF00B25E)
                          : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isPriceFixed
                          ? const Color(0xFF00B25E)
                          : Colors.grey[300]!,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],

            // Description
            Text(
              'Description (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any additional details...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Image Picker
            ImagePickerWidget(
              onImageSelected: (file) {
                setState(() {
                  _selectedImage = file;
                });
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B25E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Post Ticket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeTypeChip(String label, String value) {
    final isSelected = _selectedTradeType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTradeType = value;
            // Clear price when switching away from 'sell'
            if (value != 'sell') {
              _priceController.clear();
              _isPriceFixed = false;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00B25E)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00B25E) : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a ticket image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user info from Supabase
      final userInfo = await UserHelper.getCurrentSupabaseUser();
      final supabaseUserId = userInfo['user_id'] as String;

      // Upload image first
      final imageUrl = await _imageService.uploadImage(
        imageFile: _selectedImage!,
        userId: currentUser.uid,
      );

      // Create ticket
      final ticket = TicketModel(
        ticketId: '', // Will be generated by Supabase
        userId: supabaseUserId,
        userName: userInfo['full_name'] ?? 'Unknown',
        userPhone: userInfo['roll_no'] ?? '',
        tradeType: _selectedTradeType,
        status: 'active',
        fromLocation: _fromController.text.trim(),
        toLocation: _toController.text.trim(),
        date: _selectedDate,
        time: _selectedTime.format(context),
        price: _selectedTradeType == 'sell' && _priceController.text.isNotEmpty
            ? double.parse(_priceController.text)
            : 0.0, // Price only matters for sell
        description: _descriptionController.text.trim(),
        ticketImageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _ticketService.createTicket(ticket);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket posted successfully!'),
            backgroundColor: Color(0xFF00B25E),
          ),
        );

        // Notify parent
        widget.onPostSuccess?.call();

        // Clear form
        _formKey.currentState!.reset();
        _fromController.clear();
        _toController.clear();
        _priceController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedImage = null;
          _selectedTradeType = 'swap';
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
