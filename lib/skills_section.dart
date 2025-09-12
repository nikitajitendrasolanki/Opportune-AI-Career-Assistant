import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class Skill {
  final TextEditingController nameController;
  String proficiency;

  Skill({required this.nameController, required this.proficiency});
}

class SkillsSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback? onCancel;

  const SkillsSection({Key? key, required this.onNext, this.onCancel}) : super(key: key);

  @override
  _SkillsSectionState createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  List<Skill> skills = [];
  final List<String> proficiencyLevels = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

  @override
  void initState() {
    super.initState();
    _addSkill(); // Start with 1 skill
  }

  void _addSkill() {
    setState(() {
      skills.add(Skill(nameController: TextEditingController(), proficiency: proficiencyLevels[0]));
    });
  }

  void _removeSkill(int index) {
    if (skills.length <= 1) return;
    setState(() {
      skills.removeAt(index);
    });
  }

  Future<void> _saveSkills() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, String>> payload = skills.map((skill) {
      return {
        "firebase_uid": user.uid,
        "skill_name": skill.nameController.text.trim(),
        "proficiency_level": skill.proficiency,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.109:5000/skills/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"firebase_uid": user.uid, "skills": payload}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Skills saved successfully!")),
        );
        widget.onNext({"skills": payload});
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

  Widget _gradientText(String text, {double size = 16, FontWeight? weight}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: size, fontWeight: weight ?? FontWeight.normal),
      ),
    );
  }

  Widget _buildSkillInput(Skill skill, int index) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: skill.nameController,
              decoration: const InputDecoration(
                labelText: "Skill Name",
                filled: true,
                fillColor: Colors.white30,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: skill.proficiency,
              items: proficiencyLevels
                  .map((level) => DropdownMenuItem(
                value: level,
                child: Text(level, style: const TextStyle(color: Colors.black)),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  skill.proficiency = val!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Proficiency",
                filled: true,
                fillColor: Colors.white30,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (skills.length > 1)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _removeSkill(index),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/BG.png"), fit: BoxFit.cover),
            ),
          ),
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
                      _gradientText("Skills", size: 24, weight: FontWeight.bold),
                      const SizedBox(height: 20),
                      ...skills.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildSkillInput(entry.value, entry.key),
                      )),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _addSkill,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Skill"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade200,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: _saveSkills,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ),
    );
  }
}
