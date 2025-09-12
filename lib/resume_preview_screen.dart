// resume_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'resume_pdf_generator.dart';

class ResumePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> resumeData;
  const ResumePreviewScreen({super.key, required this.resumeData});

  // 🔹 Gradient Section Titles
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white, // masked by gradient
        ),
      ),
    ),
  );

  Widget _divider() =>
      Divider(color: Colors.white.withOpacity(0.3), thickness: 1, height: 28);

  @override
  Widget build(BuildContext context) {
    final personalInfo = resumeData['personalInfo'] ?? {};
    final education =
    List<Map<String, dynamic>>.from(resumeData['education'] ?? []);
    final experience =
    List<Map<String, dynamic>>.from(resumeData['experience'] ?? []);
    final skills = List<Map<String, dynamic>>.from(resumeData['skills'] ?? []);
    final projects =
    List<Map<String, dynamic>>.from(resumeData['projects'] ?? []);
    final certifications =
    List<Map<String, dynamic>>.from(resumeData['certifications'] ?? []);
    final languages =
    List<Map<String, dynamic>>.from(resumeData['languages'] ?? []);

    // Normalize social links
    final dynamic socialRaw = resumeData['socialLinks'];
    final List<MapEntry<String, String>> socialEntries = [];
    if (socialRaw is Map) {
      socialEntries.addAll(
        socialRaw.entries
            .map((e) => MapEntry(e.key.toString(), e.value.toString()))
            .toList(),
      );
    } else if (socialRaw is List) {
      for (var item in socialRaw) {
        if (item is Map) {
          final label = (item['label'] ?? item['name'] ?? '').toString();
          final url = (item['url'] ?? item['link'] ?? '').toString();
          if (label.isNotEmpty && url.isNotEmpty) {
            socialEntries.add(MapEntry(label, url));
          }
        }
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            "Resume Preview",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => generateResumePDF(resumeData),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🔹 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 🔹 Frosted glass overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
          // 🔹 Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Personal Info
                    if (personalInfo.isNotEmpty) ...<Widget>[
                      Center(
                        child: Text(
                          personalInfo['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          "${personalInfo['email'] ?? ''} | ${personalInfo['phone'] ?? ''}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (socialEntries.isNotEmpty)
                        Center(
                          child: Wrap(
                            spacing: 12,
                            children: socialEntries
                                .map<Widget>(
                                  (entry) => InkWell(
                                onTap: () async {
                                  final url = Uri.tryParse(entry.value);
                                  if (url != null &&
                                      await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode:
                                        LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      _divider(),
                    ],

                    // Education
                    if (education.isNotEmpty) ...<Widget>[
                      _sectionTitle("Education"),
                      ...education.map<Widget>((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['institute'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "${e['degree']} - ${e['field'] ?? ''}",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                e['year'] ?? '',
                                style:
                                const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      _divider(),
                    ],

                    // Experience
                    if (experience.isNotEmpty) ...<Widget>[
                      _sectionTitle("Experience"),
                      ...experience.map<Widget>((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['job_title'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "${e['company_name'] ?? ''}, ${e['location'] ?? ''}",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      e['description'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white60),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${e['start_year'] ?? ''} - ${e['end_year'] ?? ''}",
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      _divider(),
                    ],

                    // Skills
                    if (skills.isNotEmpty) ...<Widget>[
                      _sectionTitle("Skills"),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: skills
                            .map<Widget>((s) => Chip(
                          label: Text(
                            s['skill_name'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor:
                          Colors.blueAccent.withOpacity(0.3),
                        ))
                            .toList(),
                      ),
                      _divider(),
                    ],

                    // Projects
                    if (projects.isNotEmpty) ...<Widget>[
                      _sectionTitle("Projects"),
                      ...projects.map<Widget>((p) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['project_title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(p['description'] ?? '',
                                  style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text("Tech: ${p['technologies_used'] ?? ''}",
                                  style:
                                  const TextStyle(color: Colors.white60)),
                              if ((p['project_link'] ?? '').isNotEmpty)
                                InkWell(
                                  onTap: () async {
                                    final url =
                                    Uri.tryParse(p['project_link']);
                                    if (url != null &&
                                        await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: const Text(
                                    "View Project",
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        decoration:
                                        TextDecoration.underline),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      _divider(),
                    ],

                    // Certifications
                    if (certifications.isNotEmpty) ...<Widget>[
                      _sectionTitle("Certifications"),
                      ...certifications.map<Widget>((c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "• ${c['certification_name']} - ${c['issuing_org']}",
                            style:
                            const TextStyle(color: Colors.white70),
                          ),
                        );
                      }).toList(),
                      _divider(),
                    ],

                    // Languages
                    if (languages.isNotEmpty) ...<Widget>[
                      _sectionTitle("Languages"),
                      ...languages.map<Widget>((l) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "• ${l['language_name']} - ${l['proficiency']}",
                            style:
                            const TextStyle(color: Colors.white70),
                          ),
                        );
                      }).toList(),
                    ],
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
