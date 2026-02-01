// screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Driver-specific controllers
  final _driverEmailController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  bool _isLoading = false;
  String? _selectedGender;
  String _selectedRole = 'student'; // 'student' or 'driver'

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Passwords do not match'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create email for authentication
      String authEmail = _selectedRole == 'student'
          ? _emailController.text.trim()
          : _driverEmailController.text.trim();

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: authEmail,
        password: _passwordController.text,
      );

      // Store in appropriate collection based on role
      if (_selectedRole == 'student') {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(userCredential.user!.uid)
            .set({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'student',
          if (_selectedGender != null) 'gender': _selectedGender,
          'rating': 5.0,
          'totalRides': 0,
          'moneySaved': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Driver
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(userCredential.user!.uid)
            .set({
          'fullName': _nameController.text.trim(),
          'email': _driverEmailController.text.trim(),
          'licenseNumber': _licenseNumberController.text.trim(),
          'vehicleModel': _vehicleModelController.text.trim(),
          'vehicleNumber': _vehicleNumberController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'driver',
          if (_selectedGender != null) 'gender': _selectedGender,
          'rating': 5.0,
          'totalRides': 0,
          'seatsAvailable': 4,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        // Redirect based on role
        if (_selectedRole == 'student') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/driver-home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for this email/phone';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B25E), Color(0xFF66D395)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.group,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your account and start sharing rides',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Role Selection
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedRole = 'student'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'student'
                                          ? const Color(0xFF00B25E)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.school,
                                          color: _selectedRole == 'student'
                                              ? Colors.white
                                              : Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Student',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedRole == 'student'
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedRole = 'driver'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'driver'
                                          ? const Color(0xFF00B25E)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.local_taxi,
                                          color: _selectedRole == 'driver'
                                              ? Colors.white
                                              : Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Driver',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedRole == 'driver'
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'John Doe',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Gender selector (optional)
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Male'),
                                ),
                                selected: _selectedGender == 'Male',
                                onSelected: (s) => setState(
                                    () => _selectedGender = s ? 'Male' : null),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Female'),
                                ),
                                selected: _selectedGender == 'Female',
                                onSelected: (s) => setState(() =>
                                    _selectedGender = s ? 'Female' : null),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Other'),
                                ),
                                selected: _selectedGender == 'Other',
                                onSelected: (s) => setState(
                                    () => _selectedGender = s ? 'Other' : null),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Conditional fields based on role
                        if (_selectedRole == 'student') ...[
                          _buildTextField(
                            controller: _emailController,
                            label: 'Student Email',
                            hint: 'your.email@iitmandi.ac.in',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              if (!value
                                      .toLowerCase()
                                      .endsWith('@students.iitmandi.ac.in') &&
                                  !value
                                      .toLowerCase()
                                      .endsWith('@iitmandi.ac.in')) {
                                return 'Only iitmandi.ac.in emails are allowed';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _studentIdController,
                            label: 'Student ID',
                            hint: 'B20001',
                            icon: Icons.badge,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your student ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_selectedRole == 'driver') ...[
                          _buildTextField(
                            controller: _driverEmailController,
                            label: 'Email',
                            hint: 'your.email@example.com',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _licenseNumberController,
                            label: 'License Number',
                            hint: 'DL-1234567890',
                            icon: Icons.credit_card,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your license number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _vehicleModelController,
                            label: 'Vehicle Model',
                            hint: 'Toyota Camry 2020',
                            icon: Icons.directions_car,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your vehicle model';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _vehicleNumberController,
                            label: 'Vehicle Number',
                            hint: 'ABC-1234',
                            icon: Icons.confirmation_number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your vehicle number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+1 234 567 8900',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00B25E),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B25E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFF00B25E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00B25E),
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _driverEmailController.dispose();
    _licenseNumberController.dispose();
    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }
}
