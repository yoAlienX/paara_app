import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  List<ParticleData> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(8, (index) {
      return ParticleData(
        id: index,
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 1,
        opacity: random.nextDouble() * 0.3 + 0.1,
        duration: random.nextDouble() * 4 + 3,
        delay: random.nextDouble() * 2,
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return _buildNotLoggedInState();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle floating particles
          ..._buildFloatingParticles(),

          // Main content
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .collection('historyOfSpells')
                .orderBy('castedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(snapshot),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ..._buildFloatingParticles(),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.1),
                        child: Icon(
                          Icons.person_off_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: 48,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Authentication Required',
                    style: GoogleFonts.medievalSharp(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Access the grimoire of your past',
                    style: GoogleFonts.metamorphous(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingState();
    }

    if (snapshot.hasError) {
      return _buildErrorState();
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return _buildEmptyState();
    }

    var spellDocs = snapshot.data!.docs;
    return _buildSpellsList(spellDocs);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.2),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            'Summoning Archives...',
            style: GoogleFonts.metamorphous(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withOpacity(0.7),
            size: 48,
          ),
          SizedBox(height: 24),
          Text(
            'Connection Failed',
            style: GoogleFonts.medievalSharp(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The archives remain sealed',
            style: GoogleFonts.metamorphous(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 32),
          GestureDetector(
            onTap: () => setState(() {}),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3 + (_pulseController.value * 0.2)),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.metamorphous(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Icon(
                  Icons.auto_stories_outlined,
                  color: Colors.white.withOpacity(0.7),
                  size: 48,
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            'Empty Grimoire',
            style: GoogleFonts.medievalSharp(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'No spells have been cast\nBegin your journey into darkness',
            textAlign: TextAlign.center,
            style: GoogleFonts.metamorphous(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              letterSpacing: 0.8,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellsList(List<QueryDocumentSnapshot> spellDocs) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05),
                    child: Icon(
                      Icons.auto_stories_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  );
                },
              ),
              SizedBox(width: 12),
              Text(
                'GRIMOIRE',
                style: GoogleFonts.medievalSharp(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${spellDocs.length}',
                  style: GoogleFonts.metamorphous(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Spells list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: spellDocs.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 200 + (index * 100)),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildSpellCard(
                        spellDocs[index].data() as Map<String, dynamic>,
                        index,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpellCard(Map<String, dynamic> spellData, int index) {
    final String enemyName = spellData['enemyName'] ?? 'Unknown Target';
    final double intensity = (spellData['intensity'] ?? 1.0).toDouble();
    final Timestamp? castedAtTimestamp = spellData['castedAt'];
    final String spellName = spellData['spellName'] ?? 'Koodothram';
    final String? nakshathram = spellData['nakshathram'];
    final String? enemyEmail = spellData['enemyEmail'];

    String formattedDate = 'Unknown Time';
    if (castedAtTimestamp != null) {
      formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(castedAtTimestamp.toDate());
    }

    String intensityText = _getIntensityText(intensity);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.1 + (_pulseController.value * 0.05)),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spellName,
                          style: GoogleFonts.medievalSharp(
                            color: Colors.red[300],
                            fontSize: 18,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: GoogleFonts.metamorphous(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Target
                  _buildInfoRow(Icons.person_outline, 'Target', enemyName),

                  // Email if available
                  if (enemyEmail != null && enemyEmail.isNotEmpty) ...[
                    SizedBox(height: 14),
                    _buildInfoRow(Icons.email_outlined, null, enemyEmail),
                  ],

                  // Nakshathram if available
                  if (nakshathram != null && nakshathram.isNotEmpty) ...[
                    SizedBox(height: 14),
                    _buildInfoRow(Icons.star_outline, 'Star', nakshathram),
                  ],

                  SizedBox(height: 12),

                  // Intensity
                  Row(
                    children: [
                      Icon(
                        Icons.whatshot_outlined,
                        color: Colors.white.withOpacity(0.6),
                        size: 14,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Intensity ',
                        style: GoogleFonts.metamorphous(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${intensity.toInt()}/10',
                        style: GoogleFonts.medievalSharp(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '• $intensityText',
                        style: GoogleFonts.metamorphous(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Date footer
                  Container(
                    padding: EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          color: Colors.white.withOpacity(0.4),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: GoogleFonts.metamorphous(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow(IconData icon, String? label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.6),
          size: 14,
        ),
        SizedBox(width: 8),
        if (label != null) ...[
          Text(
            '$label ',
            style: GoogleFonts.metamorphous(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.medievalSharp(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final animatedValue = (_particleController.value + particle.delay) % 1.0;
          final floatOffset = math.sin(animatedValue * 2 * math.pi) * 15;

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

  String _getIntensityText(double intensity) {
    if (intensity <= 2) return 'Mild';
    if (intensity <= 4) return 'Moderate';
    if (intensity <= 6) return 'Strong';
    if (intensity <= 8) return 'Intense';
    return 'Ultimate';
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