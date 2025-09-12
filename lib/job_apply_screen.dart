import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'job_list_screen.dart';

class JobApplyScreen extends StatefulWidget {
  const JobApplyScreen({super.key});

  @override
  State<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends State<JobApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  String jobTitle = '';
  String location = '';
  bool remote = false;
  bool fullTime = true;

  // ✅ Gradient Title Widget
  Widget _buildGradientTitle(String text) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // Dark blue gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: "Orbitron",
          color: Colors.white, // required for ShaderMask
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ✅ Glass effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    Center(child: _buildGradientTitle("Job Search & Apply")),
                    const SizedBox(height: 20),

                    // ✅ Job Title Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Job Title',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (val) =>
                        val!.isEmpty ? 'Enter job title' : null,
                        onSaved: (val) => jobTitle = val!.trim(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Location Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (val) =>
                        val!.isEmpty ? 'Enter location' : null,
                        onSaved: (val) => location = val!.trim(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Switches
                    SwitchListTile(
                      title: const Text('Remote',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      value: remote,
                      onChanged: (val) => setState(() => remote = val),
                      activeColor: Colors.deepPurpleAccent,
                    ),
                    SwitchListTile(
                      title: const Text('Full-Time',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      value: fullTime,
                      onChanged: (val) => setState(() => fullTime = val),
                      activeColor: Colors.deepPurpleAccent,
                    ),

                    const SizedBox(height: 20),

                    // ✅ Styled Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobListScreen(
                                  title: jobTitle,
                                  location: location,
                                  remote: remote,
                                  fullTime: fullTime,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          "Search Jobs",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
