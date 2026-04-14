// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'post_ride_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';
import 'swaps_screen.dart';
import 'cab_services_screen.dart';
import '../services/ride_service.dart';
import '../utils/user_helper.dart';
import '../l10n/app_localizations.dart';
import '../widgets/location_autocomplete_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FindRideTab(),
    const PostRideScreen(),
    const RequestsScreen(),
    const SwapsScreen(),
    const CabServicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00B25E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            activeIcon: const Icon(Icons.add_circle),
            label: AppLocalizations.of(context)!.postRide,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article_outlined),
            activeIcon: const Icon(Icons.article),
            label: AppLocalizations.of(context)!.requests,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.swap_horiz_outlined),
            activeIcon: const Icon(Icons.swap_horiz),
            label: AppLocalizations.of(context)!.trades,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_taxi_outlined),
            activeIcon: const Icon(Icons.local_taxi),
            label: AppLocalizations.of(context)!.cabServices,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}

// Find a Ride Tab
class FindRideTab extends StatefulWidget {
  const FindRideTab({super.key});

  @override
  State<FindRideTab> createState() => _FindRideTabState();
}

class _FindRideTabState extends State<FindRideTab> {
  String? _selectedFrom;
  String? _selectedTo;
  double? _selectedFromLat;
  double? _selectedFromLng;
  double? _selectedToLat;
  double? _selectedToLng;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final RideService _rideService = RideService();

  // Filter options
  String? _selectedGender;
  RangeValues _priceRange = const RangeValues(0, 2000);

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _supabaseUserId;

  // All available rides (unfiltered feed)
  List<Map<String, dynamic>> _allRides = [];
  bool _loadingAllRides = true;

  // Active bookings (user's booked trips)
  List<Map<String, dynamic>> _activeBookings = [];
  bool _loadingBookings = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final userInfo = await UserHelper.getCurrentSupabaseUser();
      _supabaseUserId = userInfo['user_id'] as String;
      await Future.wait([
        _loadAllRides(),
        _loadUserBookings(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingAllRides = false;
          _loadingBookings = false;
        });
      }
    }
  }


  Future<void> _loadAllRides() async {
    try {
      final rides = await _rideService.searchRides();
      if (mounted) {
        setState(() {
          _allRides = rides;
          _loadingAllRides = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingAllRides = false);
    }
  }

  Future<void> _loadUserBookings() async {
    if (_supabaseUserId == null) return;
    try {
      final bookings = await _rideService.getUserBookings(_supabaseUserId!);
      if (mounted) {
        setState(() {
          _activeBookings = bookings
              .where(
                  (b) => b['status'] == 'pending' || b['status'] == 'confirmed')
              .toList();
          _loadingBookings = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingBookings = false);
    }
  }

  Future<void> _searchRides() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });
    try {
      final results = await _rideService.searchRides(
        fromLocation: _selectedFrom,
        toLocation: _selectedTo,
        sourceLat: _selectedFromLat,
        sourceLng: _selectedFromLng,
        destLat: _selectedToLat,
        destLng: _selectedToLng,
        maxPrice: _priceRange.end < 2000 ? _priceRange.end : null,
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        genderPreference: _selectedGender,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Search failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Apply filters — show filtered results in search results section
  Future<void> _applyFilters() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });
    try {
      final results = await _rideService.searchRides(
        fromLocation: _selectedFrom,
        toLocation: _selectedTo,
        sourceLat: _selectedFromLat,
        sourceLng: _selectedFromLng,
        destLat: _selectedToLat,
        destLng: _selectedToLng,
        maxPrice: _priceRange.end < 2000 ? _priceRange.end : null,
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        genderPreference: _selectedGender,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  /// Clear all search and filters, restore available rides view
  void _clearSearchAndFilters() {
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _selectedGender = null;
      _priceRange = const RangeValues(0, 2000);
      _selectedFrom = null;
      _selectedTo = null;
      _selectedFromLat = null;
      _selectedFromLng = null;
      _selectedToLat = null;
      _selectedToLng = null;
    });
    _fromController.clear();
    _toController.clear();
    _loadAllRides();
  }

  /// Whether any filter is currently active
  bool get _hasActiveFilters =>
      _selectedGender != null ||
      _priceRange.start > 0 ||
      _priceRange.end < 2000;

  Future<void> _bookRide(Map<String, dynamic> ride) async {
    if (_supabaseUserId == null) return;

    // Don't let user book their own ride
    if (ride['posted_by'] == _supabaseUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't book your own ride"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _rideService.createBooking(
        rideId: ride['ride_id'],
        riderId: _supabaseUserId!,
        seatsBooked: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent!'),
            backgroundColor: Color(0xFF00B25E),
          ),
        );
        _loadUserBookings();
        _loadAllRides();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Booking failed: $e'), backgroundColor: Colors.red),
        );
      }
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
          AppLocalizations.of(context)!.findRide,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search section
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.whereHeading,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LocationAutocompleteField(
                    controller: _fromController,
                    hintText: AppLocalizations.of(context)!.fromWhere,
                    prefixIcon: Icons.trip_origin_rounded,
                    onLocationSelected: (displayName, lat, lng) {
                      setState(() {
                        _selectedFrom = displayName;
                        _selectedFromLat = lat;
                        _selectedFromLng = lng;
                      });
                    },
                    onCleared: () {
                      setState(() {
                        _selectedFrom = null;
                        _selectedFromLat = null;
                        _selectedFromLng = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  LocationAutocompleteField(
                    controller: _toController,
                    hintText: AppLocalizations.of(context)!.whereTo,
                    prefixIcon: Icons.location_on_rounded,
                    onLocationSelected: (displayName, lat, lng) {
                      setState(() {
                        _selectedTo = displayName;
                        _selectedToLat = lat;
                        _selectedToLng = lng;
                      });
                    },
                    onCleared: () {
                      setState(() {
                        _selectedTo = null;
                        _selectedToLat = null;
                        _selectedToLng = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSearching ? null : _searchRides,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B25E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSearching
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.searchRides,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: ElevatedButton(
                          onPressed: () => _showFilterBottomSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasActiveFilters
                                ? const Color(0xFF00B25E)
                                : Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: _hasActiveFilters
                                      ? const Color(0xFF00B25E)
                                      : Colors.grey[300]!),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: Icon(
                            Icons.tune,
                            color: _hasActiveFilters
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Results
            if (_hasSearched) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .searchResultsCount(_searchResults.length),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearSearchAndFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.close,
                                size: 14, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context)!.clear,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_searchResults.isEmpty && !_isSearching)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.noRidesFound,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final ride = _searchResults[index];
                    return _buildRideResultCard(
                      ride,
                      showOverlapBadge: true,
                    );
                  },
                ),
            ],

            // Active Trips Section (user's bookings)
            if (_activeBookings.isNotEmpty || _loadingBookings) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  AppLocalizations.of(context)!.yourActiveTrips,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_loadingBookings)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _activeBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _activeBookings[index];
                    return _buildActiveBookingCard(booking);
                  },
                ),
            ],

            // All Available Rides Section — only when no search/filter active
            if (!_hasSearched && !_hasActiveFilters) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.availableRides,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_loadingAllRides)
                      GestureDetector(
                        onTap: () {
                          setState(() => _loadingAllRides = true);
                          _loadAllRides();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context)!.refresh,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_loadingAllRides)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (_allRides.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.directions_car_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.noRidesAvailable,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context)!.beFirstToPost,
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _allRides.length,
                  itemBuilder: (context, index) {
                    final ride = _allRides[index];
                    return _buildRideResultCard(ride);
                  },
                ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRideResultCard(
    Map<String, dynamic> ride, {
    bool showOverlapBadge = false,
  }) {
    final posterName = ride['poster_name'] ?? 'Unknown';
    final posterGender = (ride['poster_gender'] ?? '').toString();
    final from = ride['from_location'] ?? '';
    final to = ride['to_location'] ?? '';
    final date = ride['ride_date'] ?? '';
    final time = ride['ride_time'] ?? '';
    final seats = ride['available_seats'] ?? 0;
    final price = (ride['price_per_seat'] as num?)?.toDouble() ?? 0;
    final overlapScoreRaw = ride['overlap_score'];
    final overlapScore = overlapScoreRaw is num
      ? overlapScoreRaw.toDouble()
      : double.tryParse(overlapScoreRaw?.toString() ?? '');
    final hasOverlapScore =
      showOverlapBadge && overlapScore != null && overlapScore > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.grey, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    posterName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasOverlapScore) ...[
                    _buildMatchBadge(overlapScore),
                    if (posterGender.isNotEmpty) const SizedBox(width: 8),
                  ],
                  if (posterGender.isNotEmpty)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: posterGender.toLowerCase() == 'female'
                            ? Colors.pink.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            posterGender.toLowerCase() == 'female'
                                ? Icons.female
                                : Icons.male,
                            size: 14,
                            color: posterGender.toLowerCase() == 'female'
                                ? Colors.pink
                                : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            posterGender[0].toUpperCase() +
                                posterGender.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: posterGender.toLowerCase() == 'female'
                                  ? Colors.pink
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            from,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Row(
            children: [
              Icon(Icons.arrow_downward,
                  size: 16, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 4),
            ],
          ),
          Text(
            to,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(date,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(time,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.event_seat, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.nSeats(seats),
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B25E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _bookRide(ride),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B25E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(AppLocalizations.of(context)!.bookRide,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchBadge(double? score) {
    final value = score ?? 0;
    final percent = value.clamp(0, 100).round();
    final isHigh = percent >= 80;
    final isMedium = percent >= 60;

    final color = isHigh
        ? const Color(0xFF00B25E)
        : (isMedium ? Colors.orange : Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Match $percent%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActiveBookingCard(Map<String, dynamic> booking) {
    final from = booking['from_location'] ?? 'Unknown';
    final to = booking['to_location'] ?? 'Unknown';
    final date = booking['ride_date'] ?? '';
    final time = booking['ride_time'] ?? '';
    final status = booking['status'] ?? 'pending';
    final posterName = booking['poster_name'] ?? '';
    final totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0;

    final isConfirmed = status == 'confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF00B25E).withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          isConfirmed ? const Color(0xFF00B25E) : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConfirmed
                        ? AppLocalizations.of(context)!.confirmed
                        : AppLocalizations.of(context)!.pending,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isConfirmed ? const Color(0xFF00B25E) : Colors.orange,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B25E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (posterName.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.postedBy(posterName),
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            '$from → $to',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (date.isNotEmpty) ...[
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(date,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 16),
              ],
              if (time.isNotEmpty) ...[
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(time,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ],
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  try {
                    await _rideService.cancelBooking(booking['booking_id']);
                    _loadUserBookings();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking cancelled'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.cancelBooking,
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.filterRides,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.genderPreference,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildGenderOption(
                        AppLocalizations.of(context)!.all, null, setModalState),
                    const SizedBox(width: 12),
                    _buildGenderOption(AppLocalizations.of(context)!.male,
                        'male', setModalState),
                    const SizedBox(width: 12),
                    _buildGenderOption(AppLocalizations.of(context)!.female,
                        'female', setModalState),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.priceRange,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${_priceRange.start.toInt()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      '₹${_priceRange.end.toInt()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 2000,
                  divisions: 20,
                  activeColor: const Color(0xFF00B25E),
                  inactiveColor: Colors.grey[300],
                  onChanged: (values) {
                    setModalState(() {
                      _priceRange = values;
                    });
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedGender = null;
                            _priceRange = const RangeValues(0, 2000);
                          });
                          Navigator.pop(context);
                          _clearSearchAndFilters();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.reset,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B25E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.applyFilters,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderOption(
      String label, String? value, StateSetter setModalState) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            _selectedGender = value;
          });
          setState(() {
            _selectedGender = value;
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
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
