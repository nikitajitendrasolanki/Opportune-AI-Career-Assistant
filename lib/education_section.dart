import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class EducationSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback? onCancel;

  const EducationSection({
    Key? key,
    required this.onNext,
    required this.onCancel,
  }) : super(key: key);

  @override
  _EducationSectionState createState() => _EducationSectionState();
}

class _EducationSectionState extends State<EducationSection> {
  List<Map<String, TextEditingController>> educations = [];

  @override
  void initState() {
    super.initState();
    _addEducation();
  }

  void _addEducation() {
    setState(() {
      educations.add({
        "institution": TextEditingController(),
        "degree": TextEditingController(),
        "field": TextEditingController(),
        "start_date": TextEditingController(),
        "end_date": TextEditingController(),
      });
    });
  }

  void _removeEducation(int index) {
    setState(() {
      educations.removeAt(index);
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _saveAndNext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, String>> payload = educations.map((edu) {
      return {
        "institution_name": edu["institution"]!.text,
        "degree": edu["degree"]!.text,
        "field_of_study": edu["field"]!.text,
        "start_year": edu["start_date"]!.text,
        "end_year": edu["end_date"]!.text,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("http://10.59.252.17:5000/education/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"firebase_uid": user.uid, "educations": payload}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Educations saved")),
          );
          widget.onNext({"education": payload});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error saving: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Backend connection error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // Glass overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 600,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading
                          Text(
                            "Education",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Orbitron",
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 200, 70),
                                ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Education fields
                          ...educations.asMap().entries.map((entry) {
                            int index = entry.key;
                            var edu = entry.value;

                            return Column(
                              children: [
                                TextField(
                                  controller: edu["institution"],
                                  decoration: const InputDecoration(
                                      labelText: "Institution Name"),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: edu["degree"],
                                  decoration:
                                  const InputDecoration(labelText: "Degree"),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: edu["field"],
                                  decoration: const InputDecoration(
                                      labelText: "Field of Study"),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: edu["start_date"],
                                        readOnly: true,
                                        onTap: () =>
                                            _pickDate(edu["start_date"]!),
                                        decoration: const InputDecoration(
                                            labelText: "Start Date"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: edu["end_date"],
                                        readOnly: true,
                                        onTap: () =>
                                            _pickDate(edu["end_date"]!),
                                        decoration: const InputDecoration(
                                            labelText: "End Date"),
                                      ),
                                    ),
                                  ],
                                ),
                                if (educations.length > 1)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeEducation(index),
                                    ),
                                  ),
                                const Divider(height: 30, thickness: 0.6),
                              ],
                            );
                          }),

                          // Add Education button
                          ElevatedButton.icon(
                            onPressed: _addEducation,
                            icon: const Icon(Icons.add),
                            label: const Text("Add Education"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: widget.onCancel,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton.icon(
                                onPressed: _saveAndNext,
                                icon: const Icon(Icons.save,
                                    color: Colors.white),
                                label: const Text("Save & Next"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
