import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'homeScreen.dart';
import 'login.dart';

class ParaSplashScreen extends StatefulWidget {
  @override
  _ParaSplashScreenState createState() => _ParaSplashScreenState();
}

class _ParaSplashScreenState extends State<ParaSplashScreen>
    with TickerProviderStateMixin {
  bool _isVisible = false;
  bool _textGlow = false;
  List<ParticleData> _particles = [];

  late AnimationController _entranceController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _smokeController;
  late AnimationController _loadingController;
  late AnimationController _borderController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  Timer? _glowTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimations();
    _setupGlowEffect();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound();
    });
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // Wait for 5 seconds
    Timer(const Duration(seconds: 5), () {
      // Check if the widget is still mounted before navigating
      if (!mounted) return;

      // Check the current Firebase user
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If user is not logged in, go to the Login Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaaraLoginPage()),
        );
      } else {
        // If user is logged in, go to the Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParaHomeScreen()),
        );
      }
    });
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _smokeController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _loadingController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    )..repeat();

    _borderController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(20, (index) {
      return ParticleData(
        id: index,
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.5 + 0.2,
        duration: random.nextDouble() * 3 + 2,
        delay: random.nextDouble() * 2,
      );
    });
  }

  void _startAnimations() {
    Timer(Duration(milliseconds: 100), () {
      setState(() {
        _isVisible = true;
      });
      _entranceController.forward();
    });
  }

  void _setupGlowEffect() {
    _glowTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _textGlow = !_textGlow;
      });
      if (_textGlow) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    });
  }
  final player = AudioPlayer();

  Future<void> _playSound() async {
    try {
      await player.play(AssetSource('sounds/dark_ambient.mp3'));
      // await player.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _smokeController.dispose();
    _loadingController.dispose();
    _borderController.dispose();
    _glowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated particles
          ..._buildParticles(),

          // Mystical smoke effects
          _buildSmokeEffects(),

          // Main content
          _buildMainContent(),

          // Bottom image with gradient
          _buildBottomImageWithGradient(),

          // Pulsing border effect
          _buildPulsingBorder(),
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
          final floatOffset = math.sin(animatedValue * 2 * math.pi) * 20;

          return Positioned(
            left: MediaQuery.of(context).size.width * particle.x,
            top: MediaQuery.of(context).size.height * particle.y + floatOffset,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(particle.opacity),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildSmokeEffects() {
    return AnimatedBuilder(
      animation: _smokeController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.grey[800]!.withOpacity(0.1 * _smokeController.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.grey[700]!.withOpacity(0.15 * _smokeController.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.75,
              left: MediaQuery.of(context).size.width * 0.33,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[600]!.withOpacity(0.2 * _smokeController.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App title with dramatic entrance
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Text(
                    'PARA',
                    style: GoogleFonts.medievalSharp(
                      textStyle: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.1 * 72,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.8),
                          ),
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 20,
                            color: Colors.white.withOpacity(_textGlow ? _glowAnimation.value : 0.3),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 16),

          // Malayalam text
          AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _isVisible ? 0 : 5),
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 2000),
                  child: Text(
                    'പാരാ',
                    style: GoogleFonts.metamorphous(
                      textStyle: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[300],
                        letterSpacing: 0.05 * 36,
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
                ),
              );
            },
          ),

          SizedBox(height: 64),

          // Mystical loading indicator
          AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 2000),
                child: Column(
                  children: [
                    // Bouncing dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBouncingDot(0),
                        SizedBox(width: 8),
                        _buildBouncingDot(200),
                        SizedBox(width: 8),
                        _buildBouncingDot(400),
                      ],
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Awakening the Darkness...',
                      style: GoogleFonts.metamorphous(
                        color: Colors.grey[400],
                        fontSize: 14,
                        letterSpacing: 0.1 * 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBouncingDot(int delay) {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        final value = (_loadingController.value * 1000 + delay) % 1000 / 1000;
        final bounce = math.sin(value * math.pi).abs();

        return Transform.translate(
          offset: Offset(0, -bounce * 10),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomImageWithGradient() {
    return Positioned(
      bottom: 0,
      left: 0,
      child: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _isVisible ? 0 : 10),
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 3000),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Image container
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 200,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix([
                        0.7, 0, 0, 0, 0, // Red
                        0, 0.7, 0, 0, 0, // Green
                        0, 0, 0.7, 0, 0, // Blue
                        0, 0, 0, 1.2, 0, // Alpha (contrast)
                      ]),
                      child: Image.asset(
                        'assets/images/para1.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomRight,

                      ),
                    ),
                  ),

                  // Gradient overlay
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulsingBorder() {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[800]!.withOpacity(0.3 * _borderController.value),
                width: 1,
              ),
            ),
          ),
        );
      },
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

