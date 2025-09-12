import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class Language {
  final TextEditingController nameController;
  String proficiency;

  Language({required this.nameController, this.proficiency = "Beginner"});
}

class LanguagesSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback? onCancel;

  const LanguagesSection({Key? key, required this.onNext, this.onCancel})
      : super(key: key);

  @override
  _LanguagesSectionState createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends State<LanguagesSection> {
  List<Language> languages = [];
  final List<String> proficiencyLevels = ["Beginner", "Intermediate", "Advanced", "Fluent"];

  @override
  void initState() {
    super.initState();
    _addLanguage(); // Start with 1 language
  }

  void _addLanguage() {
    setState(() {
      languages.add(Language(nameController: TextEditingController()));
    });
  }

  void _removeLanguage(int index) {
    if (languages.length <= 1) return;
    setState(() {
      languages.removeAt(index);
    });
  }

  Future<void> _saveLanguages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, String>> payload = languages.map((lang) {
      return {
        "firebase_uid": user.uid,
        "language_name": lang.nameController.text.trim(),
        "proficiency_level": lang.proficiency,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.109:5000/languages/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"firebase_uid": user.uid, "languages": payload}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Languages saved successfully!")),
        );
        widget.onNext({"languages": payload});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend connection error")),
      );
    }
  }

  Widget _buildGradientText(String text, {double fontSize = 24}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLanguageInput(Language lang, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: lang.nameController,
                decoration: InputDecoration(
                  labelText: "Language",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            if (languages.length > 1)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _removeLanguage(index),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: lang.proficiency,
          decoration: InputDecoration(
            labelText: "Proficiency",
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: proficiencyLevels
              .map((level) => DropdownMenuItem(
            value: level,
            child: Text(level, style: const TextStyle(color: Colors.black87)),
          ))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => lang.proficiency = val);
          },
        ),
        const SizedBox(height: 16),
      ],
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
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGradientText("Languages"),
                    const SizedBox(height: 16),
                    ...languages.asMap().entries
                        .map((entry) => _buildLanguageInput(entry.value, entry.key)),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addLanguage,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Language"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26D0CE),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: _saveLanguages,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFF1A2980),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Save & Next"),
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
