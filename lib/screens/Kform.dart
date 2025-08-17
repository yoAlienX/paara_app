import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'outputScreen.dart';

class KoodothramForm extends StatefulWidget {
  @override
  _KoodothramFormState createState() => _KoodothramFormState();
}

class _KoodothramFormState extends State<KoodothramForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nakshathramController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? _selectedDate;
  double _intensity = 1.0;

  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _smokeController;

  List<ParticleData> _particles = [];
  bool _isFormVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimations();
  }

  void _initializeAnimations() {
    _particleController = AnimationController(
      duration: Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _smokeController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(15, (index) {
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

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isFormVisible = true;
      });
    });
  }

  String _getIntensityEmoji() {
    if (_intensity <= 2) return '😈';
    if (_intensity <= 4) return '👹';
    if (_intensity <= 6) return '💀';
    if (_intensity <= 8) return '⚰️';
    return '☠️';
  }

  String _getIntensityText() {
    if (_intensity <= 2) return 'Mild Curse';
    if (_intensity <= 4) return 'Dark Wish';
    if (_intensity <= 6) return 'Deadly Curse';
    if (_intensity <= 8) return 'Ancient Hex';
    return 'Ultimate Doom';
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      // Navigate to egg animation page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CurseEggPage(
            enemyName: _nameController.text,
            intensity: _intensity,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 1000),
        ),
      );
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Incomplete Ritual',
          style: GoogleFonts.medievalSharp(color: Colors.white),
        ),
        content: Text(
          'All fields must be filled to complete the curse ritual.',
          style: GoogleFonts.metamorphous(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    _glowController.dispose();
    _smokeController.dispose();
    _nameController.dispose();
    _nakshathramController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Particles
          ..._buildParticles(),

          // Smoke effects
          _buildSmokeEffects(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 40),

                    // Title
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Text(
                          'CURSE RITUAL',
                          style: GoogleFonts.medievalSharp(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.05 * 32,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.8),
                              ),
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 15,
                                color: Colors.red.withOpacity(_glowController.value * 0.5),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 10),

                    Text(
                      'കൂടോത്രം',
                      style: GoogleFonts.metamorphous(
                        fontSize: 12,
                        color: Colors.grey[400],
                        letterSpacing: 0.1 * 18,
                      ),
                    ),

                    SizedBox(height: 40),

                    // Form
                    AnimatedOpacity(
                      opacity: _isFormVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 1500),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormField(
                              label: 'Enemy Name *',
                              controller: _nameController,
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Target name is required';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20),

                            _buildFormField(
                              label: 'Nakshathram (Optional)',
                              controller: _nakshathramController,
                              icon: Icons.star,
                            ),

                            SizedBox(height: 20),

                            _buildFormField(
                              label: 'Email *',
                              controller: _emailController,
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20),

                            // Date of Birth
                            _buildDateField(),

                            SizedBox(height: 30),

                            // Intensity Slider
                            _buildIntensitySlider(),

                            SizedBox(height: 40),

                            // Submit Button
                            _buildSubmitButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.metamorphous(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.metamorphous(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white),
            filled: true,
            fillColor: Colors.grey[900]!.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[600]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth *',
          style: GoogleFonts.metamorphous(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDate == null ? Colors.red[600]! : Colors.grey[700]!,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? 'Select Date of Birth'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: GoogleFonts.metamorphous(
                    color: _selectedDate == null ? Colors.grey[500] : Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Curse Intensity',
              style: GoogleFonts.metamorphous(
                color: Colors.grey[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10),
            Text(
              _getIntensityEmoji(),
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getIntensityText(),
                    style: GoogleFonts.metamorphous(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_intensity.toInt()}/10',
                    style: GoogleFonts.metamorphous(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.red[600],
                  inactiveTrackColor: Colors.grey[700],
                  thumbColor: Colors.white,
                  overlayColor: Colors.red.withOpacity(0.2),
                ),
                child: Slider(
                  value: _intensity,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() {
                      _intensity = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(_glowController.value * 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'CAST CURSE',
                  style: GoogleFonts.medievalSharp(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1 * 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles() {
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
                color: Colors.red.withOpacity(particle.opacity),
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
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.2,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[800]!.withOpacity(0.1 * _smokeController.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              right: MediaQuery.of(context).size.width * 0.15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[700]!.withOpacity(0.15 * _smokeController.value),
                  shape: BoxShape.circle,
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