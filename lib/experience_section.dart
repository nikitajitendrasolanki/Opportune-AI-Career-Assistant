import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ExperienceForm extends StatefulWidget {
  final Function(Map<String,dynamic>) onNext;
  final VoidCallback? onCancel;
  const ExperienceForm({
    Key? key,
    required this.onNext,
    this.onCancel,
  }) : super(key: key);

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  List<Map<String, dynamic>> experiences = [];

  @override
  void initState() {
    super.initState();
    _addExperience(); // start with 1 form
  }

  void _addExperience() {
    setState(() {
      experiences.add({
        "id": null,
        "role": TextEditingController(),
        "company": TextEditingController(),
        "location": TextEditingController(),
        "start": null, // DateTime
        "end": null,   // DateTime
        "currentlyWorking": false,
        "description": TextEditingController(),
      });
    });
  }

  void _removeExperience(int index) {
    setState(() {
      experiences.removeAt(index);
    });
  }

  Future<void> _selectDate(int index, bool isStart) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1950);
    DateTime lastDate = DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (experiences[index]["start"] ?? initialDate)
          : (experiences[index]["end"] ?? initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          experiences[index]["start"] = pickedDate;
        } else {
          experiences[index]["end"] = pickedDate;
        }
      });
    }
  }

  Future<void> _saveExperiences() async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) return;

    List<Map<String, dynamic>> payload = experiences.map((exp) {
      return {
        "id": exp["id"],
        "job_title": exp["role"].text,
        "company_name": exp["company"].text,
        "location": exp["location"].text.isNotEmpty ? exp["location"].text : null,
        "start_date": exp["start"] != null ? exp["start"].toIso8601String().split('T')[0] : null,
        "end_date": exp["currentlyWorking"] ? null : exp["end"] != null ? exp["end"].toIso8601String().split('T')[0] : null,
        "currently_working": exp["currentlyWorking"] ? 1 : 0,
        "description": exp["description"].text,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("http://10.59.252.17:5000/experience/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firebase_uid": user.uid,
          "experiences": payload,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Experiences saved ✅")),
        );
        widget.onNext({"experiences": payload});
      } else {
        print("Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving experiences ❌: ${response.body}")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend connection error 🚨")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🔹 Experience heading with blue gradient
                            Text(
                              "Experience",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Orbitron',
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: <Color>[Colors.blue, Colors.lightBlueAccent],
                                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            ...experiences.asMap().entries.map((entry) {
                              int index = entry.key;
                              var exp = entry.value;

                              return Card(
                                color: Colors.white.withOpacity(0.1), // pastel glass effect
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: exp["role"],
                                        decoration: InputDecoration(
                                          labelText: "Job Title",
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.15),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: exp["company"],
                                        decoration: InputDecoration(
                                          labelText: "Company Name",
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.15),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: exp["location"],
                                        decoration: InputDecoration(
                                          labelText: "Location",
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.15),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => _selectDate(index, true),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: "Start Date",
                                                  filled: true,
                                                  fillColor: Colors.white.withOpacity(0.15),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  exp["start"] != null
                                                      ? "${exp["start"].toLocal()}".split(' ')[0]
                                                      : "Select Date",
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: InkWell(
                                              onTap: exp["currentlyWorking"] ? null : () => _selectDate(index, false),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: "End Date",
                                                  filled: true,
                                                  fillColor: Colors.white.withOpacity(0.15),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  exp["currentlyWorking"]
                                                      ? "Currently Working"
                                                      : exp["end"] != null
                                                      ? "${exp["end"].toLocal()}".split(' ')[0]
                                                      : "Select Date",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: exp["currentlyWorking"],
                                            onChanged: (val) {
                                              setState(() {
                                                exp["currentlyWorking"] = val ?? false;
                                                if (exp["currentlyWorking"]) exp["end"] = null;
                                              });
                                            },
                                          ),
                                          const Text("Currently Working"),
                                        ],
                                      ),
                                      TextField(
                                        controller: exp["description"],
                                        decoration: InputDecoration(
                                          labelText: "Description",
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.15),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        maxLines: 2,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _removeExperience(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _addExperience,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                "Add More Experience",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _saveExperiences,
                              child: const Text(
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
        ],
      ),
    );
  }
}