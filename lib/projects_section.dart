import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class Project {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController techController;
  final TextEditingController linkController;

  Project({
    required this.titleController,
    required this.descriptionController,
    required this.techController,
    required this.linkController,
  });
}

class ProjectsSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback? onCancel;

  const ProjectsSection({Key? key, required this.onNext, this.onCancel}) : super(key: key);

  @override
  _ProjectsSectionState createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  List<Project> projects = [];

  @override
  void initState() {
    super.initState();
    _addProject(); // Start with 1 project
  }

  void _addProject() {
    setState(() {
      projects.add(Project(
        titleController: TextEditingController(),
        descriptionController: TextEditingController(),
        techController: TextEditingController(),
        linkController: TextEditingController(),
      ));
    });
  }

  void _removeProject(int index) {
    if (projects.length <= 1) return;
    setState(() {
      projects.removeAt(index);
    });
  }

  Future<void> _saveProjects() async {
    final user = FirebaseAuth.instance.currentUser  ;
    if (user == null) return;

    List<Map<String, String>> payload = projects.map((proj) {
      return {
        "firebase_uid": user.uid,
        "project_title": proj.titleController.text.trim(),
        "project_description": proj.descriptionController.text.trim(),
        "technologies_used": proj.techController.text.trim(),
        "project_link": proj.linkController.text.trim(),
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.109:5000/projects/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"firebase_uid": user.uid, "projects": payload}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Projects saved successfully!")),
        );
        widget.onNext({"projects": payload});
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

  Widget _buildGradientText(String text) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProjectInput(Project proj, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(proj.titleController, "Project Title")),
            if (projects.length > 1)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _removeProject(index),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(proj.descriptionController, "Project Description"),
        const SizedBox(height: 12),
        _buildTextField(proj.techController, "Technologies Used"),
        const SizedBox(height: 12),
        _buildTextField(proj.linkController, "Project Link"),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/BG.png"), fit: BoxFit.cover),
            ),
          ),
          // Single Glass Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGradientText("Projects"),
                      const SizedBox(height: 16),

                      // All project inputs
                      ...projects.asMap().entries.map((entry) => _buildProjectInput(entry.value, entry.key)),

                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _addProject,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Project"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF26D0CE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Cancel + Save & Next
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
                            onPressed: _saveProjects,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }
}