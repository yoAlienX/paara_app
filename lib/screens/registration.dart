import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart'; // Import the auth service

class PaaraRegisterPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? toggleTheme;

  const PaaraRegisterPage({
    Key? key,
    this.isDarkMode = false,
    this.toggleTheme,
  }) : super(key: key);

  @override
  _PaaraRegisterPageState createState() => _PaaraRegisterPageState();
}

class _PaaraRegisterPageState extends State<PaaraRegisterPage> {
  bool showPass1 = true;
  bool showPass2 = true;
  bool isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey();
  final AuthService _authService = AuthService();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  "Register to Paara!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Create your account to get started",
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 50),

                // Full Name Field
                _buildTextFormField(
                  controller: _nameController,
                  label: "Full Name",
                  hint: "Enter your full name",
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                      return 'Name can only contain letters and spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email Field
                _buildTextFormField(
                  controller: _emailController,
                  label: "College Email",
                  hint: "your.name@duk.ac.in",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your college email';
                    }
                    if (!value.trim().toLowerCase().endsWith('@duk.ac.in')) {
                      return 'Please enter a valid college email (@duk.ac.in)';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                      return 'Please enter a valid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildTextFormField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter a strong password",
                  icon: Icons.lock_outline,
                  obscureText: showPass1,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPass1 = !showPass1;
                      });
                    },
                    icon: Icon(
                      showPass1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
                      return 'Password must contain at least one letter and one number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildTextFormField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Re-enter your password",
                  icon: Icons.lock_outline,
                  obscureText: showPass2,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPass2 = !showPass2;
                      });
                    },
                    icon: Icon(
                      showPass2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: isLoading ? null : _handleRegistration,
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Link
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                        children: const [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      obscuringCharacter: "•",
      style: TextStyle(
        color: widget.isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Future<void> _handleRegistration() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      AuthResult result = await _authService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.success) {
          _showSnackbar(result.message, Colors.green);

          // Wait a moment before navigation
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            _showSuccessDialog();
          }
        } else {
          _showSnackbar(result.message, Colors.red);
        }
      }
    } catch (e) {
      print('Registration exception: $e');
      if (mounted) {
        _showSnackbar('An unexpected error occurred. Please try again.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                backgroundColor == Colors.green ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Welcome to Paara!'),
          ],
        ),
        content: const Text(
          'Your account has been created successfully! You can now start using the app.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to login
              // Or navigate to home page:
              // Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}