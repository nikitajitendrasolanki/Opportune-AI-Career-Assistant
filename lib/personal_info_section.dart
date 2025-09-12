import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInfoSection extends StatefulWidget {
  final Function(Map<String,dynamic>) onNext;
  final VoidCallback? onCancel;

  const PersonalInfoSection({
    Key? key,
    required this.onNext,
    this.onCancel
  }) : super(key: key);

  @override
  _PersonalInfoSectionState createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _phoneC = TextEditingController();
  final TextEditingController _summaryC = TextEditingController();
  final TextEditingController _linkedinC = TextEditingController();
  final TextEditingController _githubC = TextEditingController();

  Future<void> _saveToBackend() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final payload = {
      "firebase_uid": user.uid,
      "full_name": _nameC.text.trim(),
      "email": _emailC.text.trim(),
      "phone": _phoneC.text.trim(),
      "summary": _summaryC.text.trim(),
      "linkedin_url": _linkedinC.text.trim(),
      "github_url": _githubC.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.109:5000/users/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firebase_uid": user.uid,
          "users": {
            "full_name": payload["full_name"],
            "email": payload["email"],
            "phone": payload["phone"],
          }
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Personal info saved")),
        );
        widget.onNext({
          'name': _nameC.text,
          'email': _emailC.text,
          'phone': _phoneC.text,
          'summary': _summaryC.text,
          'linkedin_url': _linkedinC.text,
          'github_url': _githubC.text,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: ${response.body}")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Error connecting to backend")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.05)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Personal Info",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Orbitron',
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: <Color>[Colors.indigo.shade900, Colors.blue.shade900],
                                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameC,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  labelText: "Full Name",
                                  labelStyle: TextStyle(color: Colors.grey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black87),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailC,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.grey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black87),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _phoneC,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  labelText: "Phone",
                                  labelStyle: TextStyle(color: Colors.grey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black87),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _summaryC,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  labelText: "Professional Summary",
                                  labelStyle: TextStyle(color: Colors.grey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black87),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _linkedinC,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  labelText: "LinkedIn URL",
                                  labelStyle: TextStyle(color: Colors.grey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _githubC,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  labelText: "GitHub URL",
                                  labelStyle: TextStyle(color: Colors.grey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _saveToBackend,
                                icon: const Icon(Icons.save, color: Colors.white),
                                label: const Text(
                                  "Save & Next",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}