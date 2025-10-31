import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class SocialLinksSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback? onCancel;

  const SocialLinksSection({Key? key, required this.onNext, this.onCancel}) : super(key: key);

  @override
  _SocialLinksSectionState createState() => _SocialLinksSectionState();
}

class _SocialLinksSectionState extends State<SocialLinksSection> {
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();

  Future<void> _saveSocialLinks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final payload = {
      "firebase_uid": user.uid,
      "linkedin": _linkedinController.text.trim(),
      "github": _githubController.text.trim(),
      "twitter": _twitterController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.59.252.17:5000/social_links/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"firebase_uid": user.uid, "social_links": payload}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("✅ Social links saved!")));
        widget.onNext(payload);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error saving social links: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("⚠️ Backend connection error")));
    }
  }

  Widget _gradientText(String text, {double size = 18, FontWeight? weight}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight ?? FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/BG.png"), fit: BoxFit.cover),
          ),
        ),
        // Glass overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.white.withOpacity(0.1)),
        ),
        // Content
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _gradientText("Social Links", size: 24, weight: FontWeight.bold),
                    const SizedBox(height: 20),
                    _buildTextField(_linkedinController, "LinkedIn URL"),
                    const SizedBox(height: 12),
                    _buildTextField(_githubController, "GitHub URL"),
                    const SizedBox(height: 12),
                    _buildTextField(_twitterController, "Twitter URL (optional)"),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: widget.onCancel ?? () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: _saveSocialLinks,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Save & Next →"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
