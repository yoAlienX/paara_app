import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:async';
import '../services/firebase_auth_service.dart';

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

class _PaaraRegisterPageState extends State<PaaraRegisterPage>
    with TickerProviderStateMixin {
  bool showPass1 = true;
  bool showPass2 = true;
  bool isLoading = false;
  bool _isVisible = false;
  List<ParticleData> _particles = [];

  final GlobalKey<FormState> formKey = GlobalKey();
  final AuthService _authService = AuthService();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _buttonHoverController;
  late AnimationController _borderController;
  late AnimationController _formController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _buttonGlowAnimation;
  late Animation<double> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimations();
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _buttonHoverController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _borderController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _buttonGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonHoverController, curve: Curves.easeInOut),
    );

    _formSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(18, (index) {
      return ParticleData(
        id: index,
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.5 + 0.5,
        opacity: random.nextDouble() * 0.3 + 0.1,
        duration: random.nextDouble() * 5 + 4,
        delay: random.nextDouble() * 3,
      );
    });
  }

  void _startAnimations() {
    Timer(Duration(milliseconds: 200), () {
      setState(() {
        _isVisible = true;
      });
      _entranceController.forward();
    });

    Timer(Duration(milliseconds: 800), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _entranceController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _buttonHoverController.dispose();
    _borderController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated particles background
          ..._buildParticles(),

          // Mystical border effect
          _buildMysticalBorder(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Mystical title
                    _buildMysticalTitle(),
                    const SizedBox(height: 50),

                    // Form fields with mystical styling
                    _buildMysticalForm(),
                    const SizedBox(height: 30),

                    // Mystical register button
                    _buildMysticalRegisterButton(),
                    const SizedBox(height: 30),

                    // Back to login link
                    _buildBackToLoginLink(),
                    const SizedBox(height: 20),

                    _buildBottomImageSection()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final animatedValue = (_particleController.value + particle.delay) % 1.0;
          final floatOffset = math.sin(animatedValue * 2 * math.pi) * 35;
          final fadeOffset = (math.cos(animatedValue * math.pi * 1.5) * 0.3 + 0.7).clamp(0.0, 1.0);
          final driftOffset = math.cos(animatedValue * math.pi) * 15;
          final finalOpacity = (particle.opacity * fadeOffset).clamp(0.0, 1.0);

          return Positioned(
            left: MediaQuery.of(context).size.width * particle.x + driftOffset,
            top: MediaQuery.of(context).size.height * particle.y + floatOffset,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(finalOpacity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity((0.1 * fadeOffset).clamp(0.0, 1.0)),
                    blurRadius: particle.size * 3,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildMysticalBorder() {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        final borderOpacity = (0.3 * _borderController.value).clamp(0.0, 1.0);
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[700]!.withOpacity(borderOpacity),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMysticalTitle() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Text(
                  'JOIN THE',
                  style: GoogleFonts.medievalSharp(
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400],
                      letterSpacing: 0.1 * 22,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'COVENANT',
                  style: GoogleFonts.medievalSharp(
                    textStyle: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.1 * 34,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 25,
                          color: Colors.white.withOpacity((_glowAnimation.value * 0.4).clamp(0.0, 1.0)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bind your soul to the eternal darkness',
                  style: GoogleFonts.metamorphous(
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      letterSpacing: 0.05 * 12,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMysticalForm() {
    return AnimatedBuilder(
      animation: _formSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _formSlideAnimation.value) * 20),
          child: Opacity(
            opacity: _formSlideAnimation.value,
            child: Column(
              children: [
                // Name field
                _buildMysticalTextField(
                  controller: _nameController,
                  label: "Chosen Name",
                  hint: "What shall you be called?",
                  icon: Icons.person_outline,
                  delay: 0,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'The darkness requires your chosen name';
                    }
                    if (value.trim().length < 2) {
                      return 'Your name must be at least 2 sacred runes';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                      return 'Only ancient letters and spaces are permitted';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email field
                _buildMysticalTextField(
                  controller: _emailController,
                  label: "Soul's Vessel",
                  hint: "your.name@duk.ac.in",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  delay: 200,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Your soul\'s vessel must be provided';
                    }
                    if (!value.trim().toLowerCase().endsWith('@duk.ac.in')) {
                      return 'Only vessels from the sacred realm (@duk.ac.in)';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                      return 'The vessel\'s marking is malformed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                _buildMysticalTextField(
                  controller: _passwordController,
                  label: "Sacred Binding",
                  hint: "Forge your protective spell",
                  icon: Icons.lock_outline,
                  obscureText: showPass1,
                  delay: 400,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPass1 = !showPass1;
                      });
                    },
                    icon: Icon(
                      showPass1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[400],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A sacred binding is required for protection';
                    }
                    if (value.length < 6) {
                      return 'Your binding must be at least 6 runes strong';
                    }
                    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
                      return 'Binding must contain ancient letters and mystic numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm password field
                _buildMysticalTextField(
                  controller: _confirmPasswordController,
                  label: "Seal the Binding",
                  hint: "Confirm your protective spell",
                  icon: Icons.enhanced_encryption_outlined,
                  obscureText: showPass2,
                  delay: 600,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPass2 = !showPass2;
                      });
                    },
                    icon: Icon(
                      showPass2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[400],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You must seal your sacred binding';
                    }
                    if (value != _passwordController.text) {
                      return 'The binding seals do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMysticalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity((0.03 * _glowAnimation.value).clamp(0.0, 1.0)),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            obscuringCharacter: "•",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.metamorphous(
                color: Colors.grey[400],
                fontSize: 13,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey[400],
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.grey[700] ?? Colors.grey.shade700,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: (Colors.grey[700] ?? Colors.grey.shade700).withOpacity((0.6 + (_glowAnimation.value * 0.4)).clamp(0.0, 1.0)),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.red[400] ?? Colors.red.shade400,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.red[300] ?? Colors.red.shade300,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[900]?.withOpacity(0.4) ?? Colors.black.withOpacity(0.4),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            validator: validator,
          ),
        );
      },
    );
  }

  Widget _buildMysticalRegisterButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTapDown: (_) => _buttonHoverController.forward(),
        onTapUp: (_) => _buttonHoverController.reverse(),
        onTapCancel: () => _buttonHoverController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_glowAnimation, _buttonGlowAnimation]),
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[850] ?? Colors.grey.shade800,
                    Colors.grey[750] ?? Colors.grey.shade700,
                    Colors.grey[850] ?? Colors.grey.shade800,
                  ],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity((0.15 + (_glowAnimation.value * 0.25)).clamp(0.0, 1.0)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity((0.08 * _glowAnimation.value).clamp(0.0, 1.0)),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                  if (_buttonGlowAnimation.value > 0)
                    BoxShadow(
                      color: Colors.white.withOpacity((0.2 * _buttonGlowAnimation.value).clamp(0.0, 1.0)),
                      blurRadius: 35,
                      spreadRadius: 6,
                    ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: isLoading ? null : _handleRegistration,
                child: isLoading
                    ? _buildMysticalLoader()
                    : Text(
                  "BIND MY SOUL",
                  style: GoogleFonts.medievalSharp(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.08 * 16,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMysticalLoader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 12),
        Text(
          "Binding Soul...",
          style: GoogleFonts.metamorphous(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBackToLoginLink() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: TextButton(
          onPressed: isLoading ? null : () {
            Navigator.pop(context);
          },
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.metamorphous(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              children: [
                TextSpan(text: "Already bound to the covenant? "),
                TextSpan(
                  text: "Enter the Portal",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildBottomImageSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3, // 40% of screen height
          minHeight: 180,
        ),
        child: Stack(
          children: [
            // Full image display
            Container(
              decoration: BoxDecoration(

              ),
              child: Image.asset(
                'assets/images/Screenshot 2025-08-20 151933.png',
                fit: BoxFit.contain, // This will show the full image without cropping
                width: double.infinity,
                color: Colors.black.withOpacity(0.2), // Lighter overlay
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // Gradient overlay (optional)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.3, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        _showSnackbar('The binding ritual failed. Dark forces intervened.', Colors.red);
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
                  style: GoogleFonts.metamorphous(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor.withOpacity(0.9),
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
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900] ?? Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[700] ?? Colors.grey.shade700, width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Soul Bound Successfully',
                style: GoogleFonts.medievalSharp(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your essence has been bound to the eternal covenant. The darkness welcomes you.',
              style: GoogleFonts.metamorphous(
                fontSize: 14,
                color: Colors.grey[300],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (Colors.grey[800] ?? Colors.grey.shade800).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700] ?? Colors.grey.shade700, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Return to the portal to begin your journey.',
                      style: GoogleFonts.metamorphous(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800] ?? Colors.grey.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'RETURN TO PORTAL',
                style: GoogleFonts.medievalSharp(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05 * 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticleData {
  final int id;
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double duration;
  final double delay;

  ParticleData({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.duration,
    required this.delay,
  });
}