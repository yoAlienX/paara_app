import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../services/email_service.dart';
import 'homeScreen.dart'; // Import the home screen for navigation

class CurseEggPage extends StatefulWidget {
  final String enemyName;
  final String enemyEmail;
  final double intensity;

  const CurseEggPage({
    Key? key,
    required this.enemyName,
    required this.enemyEmail,
    required this.intensity,
  }) : super(key: key);

  @override
  _CurseEggPageState createState() => _CurseEggPageState();
}

class _CurseEggPageState extends State<CurseEggPage>
    with TickerProviderStateMixin {
  late AnimationController _eggController;
  late AnimationController _pulseController;
  late AnimationController _nameController;
  late AnimationController _glowController;
  late AnimationController _textWriteController;
  late AnimationController _textFlickerController;

  late Animation<double> _eggScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _nameAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textWriteAnimation;
  late Animation<double> _textFlickerAnimation;

  bool _showEgg = false;
  bool _showName = false;
  bool _ritualComplete = false;

  late AudioPlayer _audioPlayer;


  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAnimations();
    _startRitual();
  }

  void _initializeAnimations() {
    _eggController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _nameController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _textWriteController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );

    _textFlickerController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    )..repeat(reverse: true);

    _eggScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _eggController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _nameAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _nameController, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _textWriteAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textWriteController, curve: Curves.easeInOut),
    );

    _textFlickerAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _textFlickerController, curve: Curves.easeInOut),
    );
  }

  void _startRitual() async {

    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _showEgg = true;
      });
      _eggController.forward();
      _playSound('egg_appear');
    });

    // Phase 2: Name writing begins
    Future.delayed(Duration(milliseconds: 3000), () {
      setState(() {
        _showName = true;
      });
      _nameController.forward();
      _textWriteController.forward();
      _playSound('writing_sound');
    });

    // Phase 3: Text flicker effect after writing
    Future.delayed(Duration(milliseconds: 5500), () {
      _textFlickerController.forward();
    });

    // Phase 4: Ritual complete and send email
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        _ritualComplete = true;
      });
      _textFlickerController.stop();
      _playSound('ritual_complete'); // Placeholder for completion sound

      // Send the confirmation email
      final EmailService emailService = EmailService();
      emailService.sendSpellCastEmail(
        enemyName: widget.enemyName,
        enemyEmail: widget.enemyEmail,
        intensity: widget.intensity,
        spellName: "Koodothram",
      );
    });
  }

  void _playSound(String soundName) {
    // Placeholder for sound effects
    // Uncomment and implement when adding sound package

    switch (soundName) {
      case 'egg_appear':
        _audioPlayer.play(AssetSource('sounds/dark_ambient.mp3'));
        break;

      case 'writing_sound':
        _audioPlayer.play(AssetSource('sounds/jamba.mp3'));
        break;
    }

    print('Playing sound: $soundName'); // Debug placeholder
  }

  Color _getIntensityColor() {
    if (widget.intensity <= 3) return Color(0xFFFF6B35); // Orange
    if (widget.intensity <= 6) return Color(0xFFDC143C); // Crimson
    if (widget.intensity <= 8) return Color(0xFF8B008B); // Dark Magenta
    return Color(0xFF2F1B69); // Dark Purple
  }

  Color _getTextColorForEgg() {
    // Colors that blend well with the egg's surface
    if (widget.intensity <= 3) return Color(0xFFFF6B35); // Dark red
    if (widget.intensity <= 6) return Color(0xFFFF6B35); // Darker red
    if (widget.intensity <= 8) return Color(0xFFFF6B35); // Dark purple
    return Color(0xFFFF6B35); // Very dark purple
  }

  @override
  void dispose() {
    _eggController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _glowController.dispose();
    _textWriteController.dispose();
    _textFlickerController.dispose();
    // _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status text
            AnimatedOpacity(
              opacity: _ritualComplete ? 1.0 : 0.6,
              duration: Duration(milliseconds: 1000),
              child: Text(
                _ritualComplete ? 'CURSE SEALED' : 'CASTING...',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  color: _ritualComplete
                      ? _getIntensityColor()
                      : Colors.grey[500],
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            SizedBox(height: 40),

            // The Cursed Egg with name overlay
            if (_showEgg)
              AnimatedBuilder(
                animation: Listenable.merge([
                  _eggController,
                  _pulseController,
                  _glowController,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _eggScaleAnimation.value * _pulseAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: 280,
                          height: 340,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(140),
                            boxShadow: [
                              BoxShadow(
                                color: _getIntensityColor().withOpacity(
                                  _glowAnimation.value * 0.4,
                                ),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),

                        // Egg container
                        Container(
                          width: 220,
                          height: 270,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Egg image
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(110),
                                  bottom: Radius.circular(90),
                                ),
                                child: Image.asset(
                                  'assets/images/egg.png',
                                  width: 220,
                                  height: 270,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Name written on egg surface
                              if (_showName)
                                Positioned(
                                  top: 170,
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge([
                                      _nameAnimation,
                                      _textWriteAnimation,
                                      _textFlickerAnimation,
                                      _pulseController,
                                    ]),
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _nameAnimation.value *
                                            _pulseAnimation.value,
                                        child: Container(
                                          width: 180,
                                          child: CustomPaint(
                                            painter: HandwrittenTextPainter(
                                              text: widget.enemyName,
                                              progress: _textWriteAnimation.value,
                                              color: _getTextColorForEgg(),
                                              flicker: _ritualComplete ? 1.0 : _textFlickerAnimation.value,
                                              intensity: widget.intensity,
                                            ),
                                            size: Size(100, 20),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              // Orbiting particles
                              ...List.generate(4, (index) {
                                return AnimatedBuilder(
                                  animation: _glowController,
                                  builder: (context, child) {
                                    final angle =
                                        (index * math.pi * 2 / 4) +
                                            (_glowController.value * math.pi * 2);
                                    final radius =
                                        140 +
                                            math.sin(
                                              _glowController.value * 3 + index,
                                            ) *
                                                10;

                                    return Positioned(
                                      left: 110 + math.cos(angle) * radius,
                                      top: 135 + math.sin(angle) * radius * 0.8,
                                      child: Container(
                                        width: 3,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: _getIntensityColor()
                                              .withOpacity(0.6),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getIntensityColor()
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            SizedBox(height: 80),

            // Bottom info and actions
            if (_ritualComplete)
              Column(
                children: [
                  Text(
                    'Intensity: ${widget.intensity.toInt()}/10',
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Elegant return button - UPDATED
                  GestureDetector(
                    onTap: () {
                      // Navigate back to the home screen, clearing previous routes
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const ParaHomeScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _getIntensityColor().withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Return to Sanctum', // Updated Text
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          color: _getIntensityColor(),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class HandwrittenTextPainter extends CustomPainter {
  final String text;
  final double progress;
  final Color color;
  final double flicker;
  final double intensity;

  HandwrittenTextPainter({
    required this.text,
    required this.progress,
    required this.color,
    required this.flicker,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create handwritten effect with Mynerve font style simulation
    final paint = Paint()
      ..color = color.withOpacity(0.8 * flicker)
      ..strokeWidth = 1.5 + (intensity / 10) * 0.5
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Shadow effect for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3 * flicker)
      ..strokeWidth = paint.strokeWidth
      ..style = PaintingStyle.fill;

    final textStyle = GoogleFonts.mynerve(

      fontSize: 24 + (intensity / 10) * 4,
      color: color.withOpacity(0.9 * flicker),
      fontWeight: FontWeight.w400,
      shadows: [
        Shadow(
          offset: Offset(1, 1),
          blurRadius: 2,
          color: Colors.black.withOpacity(0.4),
        ),
        Shadow(
          offset: Offset(0, 0),
          blurRadius: 4,
          color: color.withOpacity(0.3),
        ),
      ],
    );

    final textSpan = TextSpan(
      text: text.substring(0, (text.length * progress).round()),
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: size.width);

    // Add subtle curve to text to follow egg surface
    canvas.save();

    // Apply slight curve transformation
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Create a subtle arc effect
    canvas.translate(centerX, centerY);
    canvas.transform(Float64List.fromList([
      1.0, 0.0, 0.0, 0.0,
      0.1 * math.sin(progress * math.pi), 0.95, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0,
    ]));
    canvas.translate(-centerX, -centerY);

    // Draw text with writing animation effect
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);

    // Add writing cursor effect
    if (progress < 1.0 && flicker > 0.5) {
      final cursorPaint = Paint()
        ..color = color.withOpacity(0.7)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      final cursorX = offset.dx + textPainter.width;
      final cursorY = offset.dy + textPainter.height / 2;

      canvas.drawLine(
        Offset(cursorX, cursorY - 8),
        Offset(cursorX, cursorY + 8),
        cursorPaint,
      );
    }

    canvas.restore();

    // Add mystical particles around text
    if (progress > 0.5) {
      final particlePaint = Paint()
        ..color = color.withOpacity(0.4 * flicker)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 3; i++) {
        final angle = (i * 2 * math.pi / 3) + (progress * math.pi * 2);
        final radius = 15 + math.sin(progress * 4 + i) * 5;
        final x = centerX + math.cos(angle) * radius;
        final y = centerY + math.sin(angle) * radius;

        canvas.drawCircle(
          Offset(x, y),
          1 + math.sin(progress * 6 + i) * 0.5,
          particlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ElegantCracksPainter extends CustomPainter {
  final double progress;
  final double intensity;
  final Color color;

  ElegantCracksPainter({
    required this.progress,
    required this.intensity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Create elegant, organic crack patterns
    final numCracks = math.min(6, (intensity / 2).ceil() + 1);

    for (int i = 0; i < numCracks; i++) {
      final baseAngle = (i * 2 * math.pi / numCracks) + (progress * 0.1);
      final length = progress * (30 + intensity * 4);

      // Main crack with slight curve
      final path = Path();
      path.moveTo(centerX, centerY);

      final segments = 8;
      for (int j = 1; j <= segments; j++) {
        final t = j / segments;
        final angle = baseAngle + math.sin(t * math.pi) * 0.3; // Slight curve
        final currentLength = length * t;

        final x = centerX + math.cos(angle) * currentLength;
        final y = centerY + math.sin(angle) * currentLength;

        if (j == 1) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);

      // Subtle branch cracks
      if (progress > 0.6 && i % 2 == 0) {
        final branchLength = length * 0.4;
        final branchX = centerX + math.cos(baseAngle) * length * 0.7;
        final branchY = centerY + math.sin(baseAngle) * length * 0.7;

        final branchPath = Path();
        branchPath.moveTo(branchX, branchY);
        branchPath.lineTo(
          branchX + math.cos(baseAngle + 0.8) * branchLength,
          branchY + math.sin(baseAngle + 0.8) * branchLength,
        );

        canvas.drawPath(branchPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
