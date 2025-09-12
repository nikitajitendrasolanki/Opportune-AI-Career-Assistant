import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'main_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId = "";
  bool otpSent = false;
  bool isLoading = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void sendOTP() async {
    setState(() => isLoading = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text.trim()}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _navigateToMain();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          otpSent = true;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  void verifyOTP() async {
    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      _navigateToMain();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Slight glass overlay
          Container(color: Colors.white.withOpacity(0.05)),
          // Rotating subtle sphere
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.4),
                      Colors.purpleAccent.withOpacity(0.3),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Glass card with inputs
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Heading
                      _gradientText("Phone Login",
                          [Colors.deepPurple, Colors.purpleAccent, Colors.black87],
                          26,
                          FontWeight.bold),
                      const SizedBox(height: 30),
                      // Phone / OTP fields
                      if (!otpSent)
                        _inputField(phoneController, "Enter Phone Number", prefix: "+91 "),
                      if (otpSent) _inputField(otpController, "Enter OTP", prefix: ""),
                      const SizedBox(height: 24),
                      // Action button
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: otpSent ? verifyOTP : sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.deepPurple.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          otpSent ? "Verify OTP" : "Send OTP",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label,
      {String prefix = ""}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        prefixText: prefix,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Gradient Text Widget
  Widget _gradientText(String text, List<Color> colors, double fontSize,
      FontWeight fontWeight) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: colors).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white, // shader will override
          fontFamily: 'Orbitron',
        ),
      ),
    );
  }
}
