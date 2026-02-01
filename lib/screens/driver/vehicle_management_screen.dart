// screens/driver/vehicle_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleModelController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _seatsController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVehicleInfo();
  }

  Future<void> _loadVehicleInfo() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _vehicleModelController.text = data['vehicleModel'] ?? '';
          _vehicleNumberController.text = data['vehicleNumber'] ?? '';
          _licenseNumberController.text = data['licenseNumber'] ?? '';
          _seatsController.text = (data['seatsAvailable'] ?? 4).toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicle info: $e')),
        );
      }
    }
  }

  Future<void> _saveVehicleInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(currentUser.uid)
          .update({
        'vehicleModel': _vehicleModelController.text.trim(),
        'vehicleNumber': _vehicleNumberController.text.trim(),
        'licenseNumber': _licenseNumberController.text.trim(),
        'seatsAvailable': int.parse(_seatsController.text),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle information updated successfully!'),
            backgroundColor: Color(0xFF00B25E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Management'),
        backgroundColor: const Color(0xFF00B25E),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B25E), Color(0xFF66D395)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Vehicle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Keep your vehicle information up to date',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Vehicle Details
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vehicleModelController,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Model',
                        hintText: 'Toyota Camry 2020',
                        prefixIcon: const Icon(Icons.directions_car,
                            color: Color(0xFF00B25E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B25E), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter vehicle model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Number
                    TextFormField(
                      controller: _vehicleNumberController,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Number',
                        hintText: 'ABC-1234',
                        prefixIcon: const Icon(Icons.confirmation_number,
                            color: Color(0xFF00B25E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B25E), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter vehicle number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // License Number
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: InputDecoration(
                        labelText: 'License Number',
                        hintText: 'DL-1234567890',
                        prefixIcon: const Icon(Icons.credit_card,
                            color: Color(0xFF00B25E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B25E), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter license number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Available Seats
                    TextFormField(
                      controller: _seatsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Available Seats',
                        hintText: 'Number of seats',
                        prefixIcon: const Icon(Icons.event_seat,
                            color: Color(0xFF00B25E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF00B25E), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of seats';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 1) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Make sure your vehicle information is accurate. It will be displayed to passengers.',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveVehicleInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B25E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    _licenseNumberController.dispose();
    _seatsController.dispose();
    super.dispose();
  }
}
