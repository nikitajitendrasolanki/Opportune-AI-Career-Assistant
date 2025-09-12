import 'package:flutter/material.dart';
import 'dart:ui'; // for ImageFilter
import 'job_results_screen.dart';

class JobSearchForm extends StatefulWidget {
  const JobSearchForm({super.key});

  @override
  State<JobSearchForm> createState() => _JobSearchFormState();
}

class _JobSearchFormState extends State<JobSearchForm> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.blue, Colors.indigo],
          ).createShader(bounds),
          child: const Text(
            "Find Jobs",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // needed for gradient mask
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/BG.png",
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Glassmorphic form card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔹 Job Title Field
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Job Title",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Location Field
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: "Location",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🔹 Search Button styled like Save & Next
                      ElevatedButton.icon(
                        onPressed: () {
                          final title = _titleController.text.trim();
                          final location = _locationController.text.trim();
                          if (title.isNotEmpty && location.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobResultsScreen(
                                  title: title,
                                  location: location,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text(
                          "Search Jobs",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
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
        ],
      ),
    );
  }
}
