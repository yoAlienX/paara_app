import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paara_app_duk/screens/splashScreen.dart';

// Global variable to track if user has exited once
bool _hasExitedOnce = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paara App',
      debugShowCheckedModeBanner: false,
      home: ParaSplashScreen(),
    );
  }
}

/// Mixin to handle exit functionality - apply this to any screen
mixin ExitHandlerMixin<T extends StatefulWidget> on State<T> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: buildScreen(context),
    );
  }

  // Override this method in your screen
  Widget buildScreen(BuildContext context);

  Future<void> _handleBackPress() async {
    if (_hasExitedOnce) {
      SystemNavigator.pop();
      return;
    }

    if (_isDialogShowing) return;

    _isDialogShowing = true;
    await _showExitDialog();
    _isDialogShowing = false;
  }

  Future<void> _showExitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ExitDialog(audioPlayer: _audioPlayer);
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class ExitDialog extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const ExitDialog({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  State<ExitDialog> createState() => _ExitDialogState();
}

class _ExitDialogState extends State<ExitDialog>
    with TickerProviderStateMixin {
  bool _showConfirmation = true;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulseAnimation() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: -5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: _showConfirmation
                    ? _buildConfirmationContent()
                    : _buildExitContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title with mystical glow
        Text(
          'Exit Realm?',
          style: GoogleFonts.medievalSharp(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.grey[600]!.withOpacity(0.8),
                blurRadius: 15,
                offset: Offset(0, 0),
              ),
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Message
        Text(
          'Are you sure you want to abandon your dark ritual?',
          style: GoogleFonts.metamorphous(
            fontSize: 14,
            color: Colors.grey[400],
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              'No',
              Colors.white.withOpacity(0.2),
              Colors.white,
                  () => Navigator.of(context).pop(),
            ),
            _buildActionButton(
              'Yes',
              Colors.red.withOpacity(0.8),
              Colors.white,
              _onExitConfirmed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExitContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 700,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Image.asset(
              "assets/images/potti.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
        const Text(
          "you don't have permission to go ☠️",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }



  Widget _buildActionButton(
      String text,
      Color backgroundColor,
      Color textColor,
      VoidCallback onPressed
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _onExitConfirmed() async {
    setState(() {
      _showConfirmation = false;
    });

    _startPulseAnimation();

    try {
      // Play the audio
      await widget.audioPlayer.play(AssetSource("sounds/anuvadham.mp3"));

      // Listen for audio completion
      widget.audioPlayer.onPlayerComplete.listen((event) async {
        _stopPulseAnimation();

        // Close dialog
        if (mounted) {
          Navigator.of(context).pop();

          // Navigate to splash screen
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ParaSplashScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
                (route) => false,
          );

          // Set the flag so next time they can exit directly
          _hasExitedOnce = true;
        }
      });

    } catch (e) {
      // If audio fails, still proceed with the flow
      print('Audio playback failed: $e');
      _stopPulseAnimation();

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ParaSplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
              (route) => false,
        );
        _hasExitedOnce = true;
      }
    }
  }
}

// Example of how to use the mixin in your screens
class ExampleScreen extends StatefulWidget {
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> with ExitHandlerMixin {
  @override
  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Screen'),
        backgroundColor: Colors.pink,
      ),
      backgroundColor: Colors.pink,
      body: Center(
        child: GradientText(
          'Try pressing back button!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          colors: const [
            Colors.white,
            Colors.blue,
          ],
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}