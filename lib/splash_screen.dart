import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _speechStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSpeechQuick();
    });
  }

  Future<void> _startSpeechQuick() async {
    if (_speechStarted) return;
    _speechStarted = true;

    // Delay reduce kiya -> sirf 0.5 sec
    await Future.delayed(const Duration(milliseconds: 500));

    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setPitch(1.2);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.awaitSpeakCompletion(true);

    _audioPlayer.play(AssetSource("sounds/startup.mp3"));

    await _flutterTts.speak("Hi, Welcome to Career Assistant.");

    // Keep splash visible thoda kam -> 1.5 sec
    await Future.delayed(const Duration(milliseconds: 1500));

    _navigateToMain();
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          Lottie.asset(
            "assets/animations/purple-bg.json",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/robot.json', height: 170),
                const SizedBox(height: 20),
                Text(
                  "Hi, Welcome to Career Assistant",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
