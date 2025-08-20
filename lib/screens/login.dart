import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // Add this import
import '../services/firebase_auth_service.dart';
import 'homeScreen.dart';
import 'registration.dart';

class PaaraLoginPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? toggleTheme;

  const PaaraLoginPage({
    Key? key,
    this.isDarkMode = false,
    this.toggleTheme,
  }) : super(key: key);

  @override
  _PaaraLoginPageState createState() => _PaaraLoginPageState();
}

class _PaaraLoginPageState extends State<PaaraLoginPage>
    with TickerProviderStateMixin {
  bool hidePass = true;
  bool isLoading = false;
  bool _isVisible = false;
  List<ParticleData> _particles = [];

  final GlobalKey<FormState> formKey = GlobalKey();
  final AuthService _authService = AuthService();

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _buttonHoverController;
  late AnimationController _borderController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _buttonGlowAnimation;

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
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _buttonHoverController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _borderController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _buttonGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonHoverController, curve: Curves.easeInOut),
    );
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(15, (index) {
      return ParticleData(
        id: index,
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        opacity: random.nextDouble() * 0.4 + 0.1,
        duration: random.nextDouble() * 4 + 3,
        delay: random.nextDouble() * 2,
      );
    });
  }

  void _startAnimations() {
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        _isVisible = true;
      });
      _entranceController.forward();
    });
  }

  // Play welcome sound
  Future<void> _playWelcomeSound() async {
    try {
      // Replace with your actual sound file path
      await _audioPlayer.play(AssetSource('sounds/welcome.mp3'));
      print('Welcome sound played successfully');
    } catch (e) {
      print('Error playing welcome sound: $e');
      // You can add a fallback or handle the error gracefully
    }
  }

  // Stop any playing sounds
  Future<void> _stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _buttonHoverController.dispose();
    _borderController.dispose();
    _audioPlayer.dispose(); // Dispose audio player
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
                    const SizedBox(height: 80),

                    // Mystical title
                    _buildMysticalTitle(),
                    const SizedBox(height: 60),

                    // Form fields with mystical styling
                    _buildMysticalForm(),
                    const SizedBox(height: 40),

                    // Mystical sign in button
                    _buildMysticalSignInButton(),
                    const SizedBox(height: 30),

                    // Mystical divider
                    _buildMysticalDivider(),
                    const SizedBox(height: 30),

                    // Create account button
                    _buildCreateAccountButton(),
                    const SizedBox(height: 30),
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

  // Enhanced welcome dialog with sound and better animations
  void _navigateToHome(Map<String, dynamic> userData) {
    // Play welcome sound immediately
    _playWelcomeSound();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button during welcome
        child: AnimatedContainer(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: AlertDialog(
            backgroundColor: Colors.grey[900]?.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            elevation: 20,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon with pulsing effect
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    0.3 + (_glowController.value * 0.3),
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(
                                      0.2 * _glowController.value,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Welcome title with typewriter effect
                  TweenAnimationBuilder<int>(
                    duration: Duration(milliseconds: 1500),
                    tween: IntTween(begin: 0, end: 'Portal Invoked!'.length),
                    builder: (context, value, child) {
                      return Text(
                        'Portal Invoked!'.substring(0, value),
                        style: GoogleFonts.medievalSharp(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 10,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  SizedBox(height: 16),

                  // User name with fade in effect
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 2000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'Welcome, ${userData['name']}',
                          style: GoogleFonts.metamorphous(
                            fontSize: 16,
                            color: Colors.grey[300],
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12),

                  // Description with staggered fade in
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 2500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'The darkness welcomes you.\nEnter the realm of shadows...',
                          style: GoogleFonts.metamorphous(
                            fontSize: 12,
                            color: Colors.grey[400],
                            letterSpacing: 0.5,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32),

                  // Sound indicator with visual feedback
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Icon(
                            Icons.volume_up_outlined,
                            color: Colors.white.withOpacity(
                              0.5 + (_glowController.value * 0.3),
                            ),
                            size: 16,
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Playing Welcome Ritual',
                        style: GoogleFonts.metamorphous(
                          fontSize: 10,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Enter button with glow effect
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 3000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    0.3 + (_glowController.value * 0.2),
                                  ),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(
                                      0.1 * _glowController.value,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _stopSound(); // Stop sound before navigation
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          ParaHomeScreen(),
                                      transitionDuration: Duration(milliseconds: 800),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset(0.0, 0.1),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'ENTER THE REALM',
                                  style: GoogleFonts.medievalSharp(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Auto-dismiss after 8 seconds if user doesn't interact
    Timer(Duration(seconds: 8), () {
      if (Navigator.of(context).canPop()) {
        _stopSound();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParaHomeScreen()),
        );
      }
    });
  }

  // Rest of your existing methods remain the same...
  // (Include all the other methods from your original code here)

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final animatedValue = (_particleController.value + particle.delay) % 1.0;
          final floatOffset = math.sin(animatedValue * 2 * math.pi) * 30;
          final fadeOffset = math.cos(animatedValue * math.pi) * 0.5 + 0.5;

          return Positioned(
            left: MediaQuery.of(context).size.width * particle.x,
            top: MediaQuery.of(context).size.height * particle.y + floatOffset,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(particle.opacity * fadeOffset),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: particle.size * 2,
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
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[800]!.withOpacity(0.2 * _borderController.value),
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
                  'ENTER THE',
                  style: GoogleFonts.medievalSharp(
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400],
                      letterSpacing: 0.1 * 24,
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
                  'DARKNESS',
                  style: GoogleFonts.medievalSharp(
                    textStyle: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.1 * 36,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 20,
                          color: Colors.white.withOpacity(_glowAnimation.value * 0.5),
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

  // Add your remaining methods here (_buildMysticalForm, _buildMysticalTextField, etc.)
  // I'm including the essential login handling method:

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      AuthResult result = await _authService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.success) {
          _showSnackbar(result.message, Colors.green);
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted && result.userData != null) {
            _navigateToHome(result.userData!);
          }
        } else {
          _showSnackbar(result.message, Colors.red);
        }
      }
    } catch (e) {
      print('Login exception: $e');
      if (mounted) {
        _showSnackbar('The dark forces rejected your request. Try again.', Colors.red);
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
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildMysticalForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Email field
          _buildMysticalTextField(
            controller: _emailController,
            label: "Soul's Identifier",
            hint: "your.name@duk.ac.in",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'The darkness requires your soul\'s identifier';
              }
              if (!value.trim().toLowerCase().endsWith('@duk.ac.in')) {
                return 'Only blessed souls from the sacred realm (@duk.ac.in)';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                return 'The format of your soul\'s mark is invalid';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Password field
          _buildMysticalTextField(
            controller: _passwordController,
            label: "Sacred Incantation",
            hint: "Whisper your secret spell",
            icon: Icons.lock_outline,
            obscureText: hidePass,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  hidePass = !hidePass;
                });
              },
              icon: Icon(
                hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey[400],
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'The sacred incantation is required';
              }
              if (value.length < 6) {
                return 'Your spell must be at least 6 runes long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Forgot password
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton(
          //     onPressed: isLoading ? null : _showForgotPasswordDialog,
          //     child: Text(
          //       'Forgotten Incantation?',
          //       style: GoogleFonts.metamorphous(
          //         color: Colors.grey[500],
          //         fontSize: 12,
          //         fontWeight: FontWeight.w400,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
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
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05 * _glowAnimation.value),
                blurRadius: 10,
                spreadRadius: 1,
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
                fontSize: 14,
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
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[700]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[700]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red[400]!,
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[900]!.withOpacity(0.3),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: validator,
          ),
        );
      },
    );
  }

  Widget _buildMysticalSignInButton() {
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
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[700]!,
                    Colors.grey[800]!,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2 + (_glowAnimation.value * 0.3)),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  if (_buttonGlowAnimation.value > 0)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3 * _buttonGlowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? _buildMysticalLoader()
                    : Text(
                  "INVOKE THE PORTAL",
                  style: GoogleFonts.medievalSharp(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.05 * 16,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
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
          "Summoning...",
          style: GoogleFonts.metamorphous(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMysticalDivider() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey[600]!.withOpacity(0.5 + (_glowAnimation.value * 0.3)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "OR",
                  style: GoogleFonts.metamorphous(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey[600]!.withOpacity(0.5 + (_glowAnimation.value * 0.3)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isLoading ? null : _navigateToRegister,
          child: Text(
            "JOIN THE COVENANT",
            style: GoogleFonts.medievalSharp(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05 * 14,
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _handleLogin() async {
  //   if (!formKey.currentState!.validate()) {
  //     return;
  //   }
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     AuthResult result = await _authService.loginUser(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text,
  //     );
  //
  //     if (mounted) {
  //       if (result.success) {
  //         _showSnackbar(result.message, Colors.green);
  //         await Future.delayed(const Duration(milliseconds: 500));
  //
  //         if (mounted && result.userData != null) {
  //           _navigateToHome(result.userData!);
  //         }
  //       } else {
  //         _showSnackbar(result.message, Colors.red);
  //       }
  //     }
  //   } catch (e) {
  //     print('Login exception: $e');
  //     if (mounted) {
  //       _showSnackbar('The dark forces rejected your request. Try again.', Colors.red);
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  // void _showSnackbar(String message, Color backgroundColor) {
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             Icon(
  //               backgroundColor == Colors.green ? Icons.check_circle : Icons.error,
  //               color: Colors.white,
  //               size: 20,
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Text(
  //                 message,
  //                 style: GoogleFonts.metamorphous(
  //                   fontWeight: FontWeight.w400,
  //                   fontSize: 13,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         backgroundColor: backgroundColor.withOpacity(0.9),
  //         duration: const Duration(seconds: 3),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         margin: const EdgeInsets.all(16),
  //       ),
  //     );
  //   }
  // }

  // void _navigateToHome(Map<String, dynamic> userData) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     barrierColor: Colors.black.withOpacity(0.8),
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.grey[900],
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //         side: BorderSide(color: Colors.grey[700]!, width: 1),
  //       ),
  //       title: Row(
  //         children: [
  //           Icon(Icons.star, color: Colors.white, size: 28),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Text(
  //               'Welcome, ${userData['name']}',
  //               style: GoogleFonts.medievalSharp(
  //                 fontSize: 18,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: Text(
  //         'The portal has been successfully invoked. Enter the realm.',
  //         style: GoogleFonts.metamorphous(
  //           fontSize: 14,
  //           color: Colors.grey[300],
  //         ),
  //       ),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => ParaHomeScreen(),
  //               ),
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.grey[800],
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: Text(
  //             'ENTER',
  //             style: GoogleFonts.medievalSharp(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildBottomImageSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
          minHeight: 200,
        ),
        child: Stack(
          children: [
            // Full image display
            Container(
              decoration: BoxDecoration(

              ),
              child: Image.asset(
                'assets/images/potti.png',
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
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaaraRegisterPage(
          isDarkMode: widget.isDarkMode,
          toggleTheme: widget.toggleTheme,
        ),
      ),
    );
  }

  // void _showForgotPasswordDialog() {
  //   final TextEditingController emailController = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.black.withOpacity(0.8),
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.grey[900],
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //         side: BorderSide(color: Colors.grey[700]!, width: 1),
  //       ),
  //       title: Text(
  //         'Restore Forgotten Spell',
  //         style: GoogleFonts.medievalSharp(
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //           color: Colors.white,
  //         ),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Provide your soul\'s identifier to receive restoration instructions.',
  //             style: GoogleFonts.metamorphous(
  //               fontSize: 13,
  //               color: Colors.grey[300],
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           TextField(
  //             controller: emailController,
  //             keyboardType: TextInputType.emailAddress,
  //             style: TextStyle(color: Colors.white),
  //             decoration: InputDecoration(
  //               hintText: 'your.name@duk.ac.in',
  //               hintStyle: TextStyle(color: Colors.grey[500]),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //                 borderSide: BorderSide(color: Colors.grey[700]!),
  //               ),
  //               enabledBorder: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //                 borderSide: BorderSide(color: Colors.grey[700]!),
  //               ),
  //               focusedBorder: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //                 borderSide: BorderSide(color: Colors.white, width: 2),
  //               ),
  //               filled: true,
  //               fillColor: Colors.grey[800],
  //               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Cancel',
  //             style: GoogleFonts.metamorphous(
  //               color: Colors.grey[400],
  //               fontSize: 14,
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             String email = emailController.text.trim();
  //             if (email.isNotEmpty) {
  //               try {
  //                 AuthResult result = await _authService.resetPassword(email);
  //                 if (mounted) {
  //                   Navigator.pop(context);
  //                   _showSnackbar(
  //                     result.message,
  //                     result.success ? Colors.green : Colors.red,
  //                   );
  //                 }
  //               } catch (e) {
  //                 if (mounted) {
  //                   _showSnackbar(
  //                     'The ritual failed. Please try again.',
  //                     Colors.red,
  //                   );
  //                 }
  //               }
  //             } else {
  //               _showSnackbar('Your soul\'s identifier is required', Colors.red);
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.grey[800],
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: Text(
  //             'Send Restoration',
  //             style: GoogleFonts.metamorphous(fontSize: 12),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
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