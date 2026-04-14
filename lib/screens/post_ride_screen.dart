// screens/post_ride_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/ride_service.dart';
import '../utils/user_helper.dart';
import '../widgets/location_autocomplete_field.dart';

class PostRideScreen extends StatefulWidget {
  const PostRideScreen({super.key});

  @override
  State<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends State<PostRideScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  int _selectedSeats = 1;
  String _passengerPreference = 'Any';
  bool _isPosting = false;
  final RideService _rideService = RideService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _fromLat;
  double? _fromLng;
  double? _toLat;
  double? _toLng;

  // User's posted rides
  List<Map<String, dynamic>> _myRides = [];
  bool _loadingRides = true;

  @override
  void initState() {
    super.initState();
    _loadMyRides();
  }

  Future<void> _loadMyRides() async {
    try {
      final userInfo = await UserHelper.getCurrentSupabaseUser();
      final userId = userInfo['user_id'] as String;
      final rides = await _rideService.getUserRides(userId);
      if (mounted) {
        setState(() {
          _myRides = rides;
          _loadingRides = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRides = false);
    }
  }

  Future<void> _postRide() async {
    if (_fromController.text.trim().isEmpty ||
        _toController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.enterFromToLocations),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.selectDateAndTime),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_fromLat == null || _fromLng == null || _toLat == null || _toLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both locations from suggestions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.enterPricePerSeat),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final userInfo = await UserHelper.getCurrentSupabaseUser();
      final userId = userInfo['user_id'] as String;

      await _rideService.createRide(
        postedBy: userId,
        fromLocation: _fromController.text.trim(),
        toLocation: _toController.text.trim(),
        rideDate: _selectedDate!.toIso8601String().split('T')[0],
        rideTime: _selectedTime!.format(context),
        availableSeats: _selectedSeats,
        pricePerSeat: double.tryParse(_priceController.text.trim()) ?? 0,
        genderPreference: _passengerPreference.toLowerCase(),
        sourceLat: _fromLat,
        sourceLng: _fromLng,
        destLat: _toLat,
        destLng: _toLng,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ridePostedSuccess),
            backgroundColor: const Color(0xFF00B25E),
          ),
        );
        // Reset form
        _fromController.clear();
        _toController.clear();
        _dateController.clear();
        _timeController.clear();
        _priceController.clear();
        setState(() {
          _selectedSeats = 1;
          _passengerPreference = 'Any';
          _selectedDate = null;
          _selectedTime = null;
          _fromLat = null;
          _fromLng = null;
          _toLat = null;
          _toLng = null;
        });
        _loadMyRides();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to post ride: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
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
          AppLocalizations.of(context)!.postRide,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.shareYourJourney,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.from,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            LocationAutocompleteField(
              controller: _fromController,
              hintText: AppLocalizations.of(context)!.enterPickupLocation,
              onLocationSelected: (displayName, lat, lng) {
                _fromController.text = displayName;
                _fromLat = lat;
                _fromLng = lng;
              },
              onCleared: () {
                _fromLat = null;
                _fromLng = null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.to,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            LocationAutocompleteField(
              controller: _toController,
              hintText: AppLocalizations.of(context)!.enterDestination,
              onLocationSelected: (displayName, lat, lng) {
                _toController.text = displayName;
                _toLat = lat;
                _toLng = lng;
              },
              onCleared: () {
                _toLat = null;
                _toLng = null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.date,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            _selectedDate = date;
                            _dateController.text =
                                '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'dd-mm-yyyy',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: const Icon(Icons.calendar_today_outlined,
                              color: Colors.grey, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF00B25E), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.time,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            _selectedTime = time;
                            _timeController.text = time.format(context);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '--:--',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: const Icon(Icons.access_time,
                              color: Colors.grey, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF00B25E), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.availableSeats,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedSeats,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF00B25E), width: 2),
                          ),
                        ),
                        items: [1, 2, 3, 4, 5, 6].map((seats) {
                          return DropdownMenuItem(
                            value: seats,
                            child: Text('$seats'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSeats = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.pricePerSeatLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF00B25E), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.passengerPreference,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPreferenceButton('Any'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPreferenceButton('Male'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPreferenceButton('Female'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B25E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        AppLocalizations.of(context)!.postRide,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            // My Posted Rides
            Text(
              AppLocalizations.of(context)!.myPostedRides,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            if (_loadingRides)
              const Center(child: CircularProgressIndicator())
            else if (_myRides.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.of(context)!.noRidesPostedYet,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),
              )
            else
              ...List.generate(_myRides.length, (index) {
                final ride = _myRides[index];
                final status = ride['status'] ?? 'active';
                final isActive = status == 'active';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF00B25E).withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF00B25E).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? const Color(0xFF00B25E)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          if (isActive)
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined,
                                  color: Colors.red, size: 20),
                              onPressed: () async {
                                try {
                                  await _rideService.updateRideStatus(
                                      ride['ride_id'], 'cancelled');
                                  _loadMyRides();
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
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${ride['from_location']} → ${ride['to_location']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ride['ride_date']} • ${ride['ride_time']} • ${ride['available_seats']} seats • ₹${ride['price_per_seat']}',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceButton(String preference) {
    final isSelected = _passengerPreference == preference;
    return InkWell(
      onTap: () {
        setState(() {
          _passengerPreference = preference;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B25E) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B25E) : Theme.of(context).dividerColor,
            width: 1.5,
          ),
        ),
        child: Text(
          preference,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
