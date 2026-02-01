// screens/swaps_screen.dart
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Swaps',
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
                  'Browse or post swap requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTabButton('Browse Swaps', 0),
                    const SizedBox(width: 12),
                    _buildTabButton('Post Swap', 1),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseSwapsList(),
                const PostSwapTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
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
      ),
    );
  }

  Widget _buildBrowseSwapsList() {
    final swapOffers = [
      {
        'name': 'Arendra',
        'initials': 'A',
        'currentFrom': 'South Campus',
        'currentTo': 'North Campus',
        'currentDate': 'Feb 10, 2026',
        'currentTime': '9:00 AM',
        'currentSeats': 2,
        'wantedFrom': 'South Campus',
        'wantedTo': 'North Campus',
        'wantedDate': 'Feb 10, 2026',
        'wantedTime': '2:00 PM',
        'wantedSeats': 2,
        'postedDate': '2 days ago',
      },
      {
        'name': 'Gaurav',
        'initials': 'G',
        'currentFrom': 'Mandi',
        'currentTo': 'North Campus',
        'currentDate': 'Feb 11, 2026',
        'currentTime': '8:00 AM',
        'currentSeats': 1,
        'wantedFrom': 'Mandi',
        'wantedTo': 'North Campus',
        'wantedDate': 'Feb 11, 2026',
        'wantedTime': '10:00 AM',
        'wantedSeats': 1,
        'postedDate': '5 hours ago',
      },
      {
        'name': 'Raj',
        'initials': 'R',
        'currentFrom': 'Mandi',
        'currentTo': 'North Campus',
        'currentDate': 'Feb 12, 2026',
        'currentTime': '3:00 PM',
        'currentSeats': 3,
        'wantedFrom': 'Mandi',
        'wantedTo': 'North Campus',
        'wantedDate': 'Feb 12, 2026',
        'wantedTime': '11:00 AM',
        'wantedSeats': 3,
        'postedDate': '1 day ago',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: swapOffers.length,
      itemBuilder: (context, index) {
        final offer = swapOffers[index];
        return _buildSwapOfferCard(offer);
      },
    );
  }

  Widget _buildSwapOfferCard(Map<String, dynamic> offer) {
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
          // Owner Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    offer['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Text(
                offer['postedDate'],
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Has Ticket Section
          Text(
            'HAS TICKET',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Color(0xFF00B25E)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${offer['currentFrom']} → ${offer['currentTo']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${offer['currentDate']} • ${offer['currentTime']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${offer['currentSeats']} seat(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Swap Arrow
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(
                Icons.swap_vert,
                color: Color(0xFF00B25E),
                size: 24,
              ),
            ),
          ),

          // Wants Ticket Section
          Text(
            'WANTS TICKET',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${offer['wantedFrom']} → ${offer['wantedTo']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${offer['wantedDate']} • ${offer['wantedTime']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${offer['wantedSeats']} seat(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Request Swap Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Swap request sent!'),
                    backgroundColor: Color(0xFF00B25E),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B25E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Request Swap',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Post Swap Tab
class PostSwapTab extends StatefulWidget {
  const PostSwapTab({super.key});

  @override
  State<PostSwapTab> createState() => _PostSwapTabState();
}

class _PostSwapTabState extends State<PostSwapTab> {
  // Current ticket controllers
  final _currentFromController = TextEditingController();
  final _currentToController = TextEditingController();
  final _currentDateController = TextEditingController();
  final _currentTimeController = TextEditingController();
  int _currentSeats = 1;

  // Wanted ticket controllers
  final _wantedFromController = TextEditingController();
  final _wantedToController = TextEditingController();
  final _wantedDateController = TextEditingController();
  final _wantedTimeController = TextEditingController();
  int _wantedSeats = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post your swap request',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),

          // Current Ticket Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00B25E).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B25E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'I HAVE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00B25E),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _currentFromController,
                  hint: 'Enter pickup location',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                Text(
                  'To',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _currentToController,
                  hint: 'Enter destination',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDateField(_currentDateController),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTimeField(_currentTimeController),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Seats',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSeatsSelector(_currentSeats, (value) {
                  setState(() => _currentSeats = value);
                }),
              ],
            ),
          ),

          // Swap Arrow
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(
                Icons.swap_vert,
                color: Color(0xFF00B25E),
                size: 32,
              ),
            ),
          ),

          // Wanted Ticket Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'I WANT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _wantedFromController,
                  hint: 'Enter pickup location',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                Text(
                  'To',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _wantedToController,
                  hint: 'Enter destination',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDateField(_wantedDateController),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTimeField(_wantedTimeController),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Seats',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSeatsSelector(_wantedSeats, (value) {
                  setState(() => _wantedSeats = value);
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Post Swap Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Swap request posted successfully!'),
                    backgroundColor: Color(0xFF00B25E),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B25E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Post Swap Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey),
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
          borderSide: const BorderSide(color: Color(0xFF00B25E), width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          controller.text =
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
          borderSide: const BorderSide(color: Color(0xFF00B25E), width: 2),
        ),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          controller.text = time.format(context);
        }
      },
      decoration: InputDecoration(
        hintText: '--:--',
        hintStyle: TextStyle(color: Colors.grey[400]),
        suffixIcon: const Icon(Icons.access_time, color: Colors.grey, size: 20),
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
          borderSide: const BorderSide(color: Color(0xFF00B25E), width: 2),
        ),
      ),
    );
  }

  Widget _buildSeatsSelector(int selectedSeats, Function(int) onChanged) {
    return Row(
      children: [1, 2, 3, 4].map((seats) {
        final isSelected = selectedSeats == seats;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(seats),
            child: Container(
              margin: EdgeInsets.only(right: seats < 4 ? 8 : 0),
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
                '$seats',
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
      }).toList(),
    );
  }

  @override
  void dispose() {
    _currentFromController.dispose();
    _currentToController.dispose();
    _currentDateController.dispose();
    _currentTimeController.dispose();
    _wantedFromController.dispose();
    _wantedToController.dispose();
    _wantedDateController.dispose();
    _wantedTimeController.dispose();
    super.dispose();
  }
}
