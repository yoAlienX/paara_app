import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

import 'Kform.dart';

class ParaHomeScreen extends StatefulWidget {
  final String username;

  const ParaHomeScreen({Key? key, this.username = "Practitioner"}) : super(key: key);

  @override
  _ParaHomeScreenState createState() => _ParaHomeScreenState();
}

class _ParaHomeScreenState extends State<ParaHomeScreen>
    with TickerProviderStateMixin {
  List<ParticleData> _particles = [];
  int _selectedTabIndex = 0;
  bool _isLoaded = false;

  late AnimationController _particleController;
  late AnimationController _smokeController;
  late AnimationController _glowController;
  late AnimationController _breathingController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimations();
  }

  void _initializeAnimations() {
    _particleController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _smokeController = AnimationController(
      duration: Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _breathingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(15, (index) {
      return ParticleData(
        id: index,
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 1,
        opacity: random.nextDouble() * 0.3 + 0.1,
        duration: random.nextDouble() * 4 + 3,
        delay: random.nextDouble() * 2,
      );
    });
  }

  void _startAnimations() {
    Timer(Duration(milliseconds: 200), () {
      setState(() {
        _isLoaded = true;
      });
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _smokeController.dispose();
    _glowController.dispose();
    _breathingController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background particles
          ..._buildBackgroundEffects(),

          // Main content
          Column(
            children: [
              // Custom App Bar with blend effect
              _buildCustomAppBar(),

              // Tab content
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),

          // Bottom image section - positioned at the very bottom
          _buildBottomImageSection(),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundEffects() {
    return [
      // Animated particles
      ..._particles.map((particle) {
        return AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            final animatedValue = (_particleController.value + particle.delay) % 1.0;
            final floatOffset = math.sin(animatedValue * 2 * math.pi) * 30;
            final rotationOffset = animatedValue * 2 * math.pi;

            return Positioned(
              left: MediaQuery.of(context).size.width * particle.x,
              top: MediaQuery.of(context).size.height * particle.y + floatOffset,
              child: Transform.rotate(
                angle: rotationOffset,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(particle.opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),

      // Smoke effects
      AnimatedBuilder(
        animation: _smokeController,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top: 100,
                left: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[900]!.withOpacity(0.2 * _smokeController.value),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15 * _smokeController.value),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ];
  }

  Widget _buildCustomAppBar() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _isLoaded ? 0 : -50),
          child: AnimatedOpacity(
            opacity: _isLoaded ? 1.0 : 0.0,
            duration: Duration(milliseconds: 1500),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey[900]!.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Greeting section
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [

                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HI, ${widget.username.toUpperCase()}',
                                  style: GoogleFonts.medievalSharp(
                                    color: Colors.white,
                                    fontSize: 24,

                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 10,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab Bar
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 1),

                      child: TabBar(
                        controller: TabController(length: 3, vsync: this),
                        onTap: (index) => setState(() => _selectedTabIndex = index),
                        indicator: BoxDecoration(



                        ),


                        unselectedLabelColor: Colors.grey[500],
                        labelStyle: GoogleFonts.metamorphous(

                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: 'HOME'),
                          Tab(text: 'ACTIVE'),
                          Tab(text: 'HISTORY'),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _isLoaded ? 0 : 30),
          child: AnimatedOpacity(
            opacity: _isLoaded ? 1.0 : 0.0,
            duration: Duration(milliseconds: 2000),
            child: _selectedTabIndex == 0 ? _buildHomeContent() : _buildOtherTabContent(),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 280), // Add bottom padding to avoid overlap with image
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App description
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.98 + 0.02 * _breathingAnimation.value,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[900]!.withOpacity(0.8),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Channel the ancient art of koodothram through digital means. Create powerful curses, bind negative energies, and manifest your darkest intentions through mystical algorithms.',
                          style: GoogleFonts.metamorphous(
                            color: Colors.grey[300],
                            fontSize: 12,
                            height: 1.5,
                            letterSpacing: 0.5,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 40),

            // Dark minimalistic action button
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  // Subtle dark pulsing effect - very minimal
                  final darkPulse = 0.02 + 0.01 * math.sin(_pulseController.value * 2 * math.pi);
                  final shadowIntensity = 0.1 + 0.05 * math.sin(_pulseController.value * 2 * math.pi);

                  return GestureDetector(
                    onTap: () {
                      _showMysticalDialog();
                    },
                    child: Container(
                      width: 200,
                      height: 55,
                      decoration: BoxDecoration(
                        // Very dark, almost black background
                        color: Colors.grey[900]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        // Subtle dark border that barely glows
                        border: Border.all(
                          color: Colors.grey[800]!.withOpacity(0.6 + darkPulse),
                          width: 1,
                        ),
                        // Minimal dark shadow effect
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(shadowIntensity),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                          // Inner shadow effect for depth
                          BoxShadow(
                            color: Colors.grey[700]!.withOpacity(0.1 * shadowIntensity),
                            blurRadius: 4,
                            spreadRadius: -1,
                            offset: Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Subtle dark gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                ],
                              ),
                            ),
                          ),

                          // Minimal dark symbols in corners
                          Positioned(
                            left: 12,
                            top: 12,
                            child: Container(
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.grey[600]!.withOpacity(0.4 + darkPulse * 10),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.grey[600]!.withOpacity(0.4 + darkPulse * 10),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.grey[600]!.withOpacity(0.4 + darkPulse * 10),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.grey[600]!.withOpacity(0.4 + darkPulse * 10),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // Main button content
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'INVOKE CURSE',
                                  style: GoogleFonts.medievalSharp(
                                    color: Colors.grey[300]!.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Container(
                                  width: 40,
                                  height: 1,
                                  color: Colors.grey[700]!.withOpacity(0.5 + darkPulse * 5),
                                ),
                              ],
                            ),
                          ),

                          // Subtle scanning line effect
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Positioned(
                                top: 55 * _pulseController.value - 1,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.grey[700]!.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // New bottom image section that sticks to the bottom
  Widget _buildBottomImageSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 250,
        child: Stack(
          children: [
            // The image at the very bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    height: 200, // Fixed height for the image
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1 * _glowController.value),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/para2.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    ),
                  );
                },
              ),
            ),

            // Gradient overlay from top to create smooth transition
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),

            // Optional mystical overlay symbols on the image
            Positioned(
              bottom: 40,
              left: 30,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.3 + 0.2 * _glowController.value,
                    child: Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 60,
              right: 40,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.2 + 0.3 * _glowController.value,
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 20,
                        shadows: [
                          Shadow(
                            color: Colors.purple.withOpacity(0.8),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherTabContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            color: Colors.grey[600],
            size: 64,
          ),
          SizedBox(height: 20),
          Text(
            'Coming Soon...',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
              fontFamily: 'Mystery Quest',
            ),
          ),
          Text(
            'Dark features in development',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontFamily: 'Metamorphous',
            ),
          ),
        ],
      ),
    );
  }

  void _showMysticalDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          title: Text(
            'Enter the Void?',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'UnifrakturCook',
              fontSize: 20,
            ),
          ),
          content: Text(
            'Are you prepared to channel dark energies and create a digital koodothram? This action cannot be undone.',
            style: TextStyle(
              color: Colors.grey[300],
              fontFamily: 'Metamorphous',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Retreat',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => KoodothramForm()),
                );
              },
              child: Text(
                'Proceed',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'UnifrakturCook',
                ),
              ),
            ),
          ],
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

// Usage:
// ParaHomeScreen(username: "Your Name")