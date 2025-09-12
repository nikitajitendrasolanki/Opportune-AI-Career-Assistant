import 'package:flutter/material.dart';
import 'dart:ui'; // for ImageFilter
import 'job_services.dart';
import 'resume_services.dart';
import 'job_apply_webview.dart';
import 'applied_job.dart';

class JobResultsScreen extends StatelessWidget {
  final String title;
  final String location;

  const JobResultsScreen({
    super.key,
    required this.title,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final jobs = fetchJobsByUserInput(title, location);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.blue, Colors.indigo],
          ).createShader(bounds),
          child: const Text(
            "Matching Jobs",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // important for gradient
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

          // 🔹 Job List with Glassmorphism effect
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.blue, Colors.indigo],
                          ).createShader(bounds),
                          child: Text(
                            "${job['title']} | ${job['company']}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // gradient base
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job['location'] ?? "",
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Apply Button styled like Save & Next
                        ElevatedButton.icon(
                          onPressed: () async {
                            final tailoredText = await tailorResume(
                              job['title']!,
                              getSavedResumeData(),
                            );
                            final pdfPath = await generateResumePDF(
                              tailoredText,
                              "tailored_resume_${job['company']}.pdf",
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobApplyWebview(
                                  applyUrl: job['applyLink']!,
                                  name: "User Name",
                                  email: "user@email.com",
                                  phone: "9999999999",
                                  resumePath: pdfPath,
                                ),
                              ),
                            );

                            saveAppliedJob(
                              job['title']!,
                              job['company']!,
                              job['location']!,
                              pdfPath,
                              "Pending",
                            );
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text(
                            "Apply",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
