import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'job_apply_webview.dart';
import 'dart:ui';


class JobListScreen extends StatefulWidget {
  final String title;
  final String location;
  final bool remote;
  final bool fullTime;

  const JobListScreen({
    super.key,
    required this.title,
    required this.location,
    required this.remote,
    required this.fullTime,
  });

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List jobs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    setState(() => loading = true);
    List combinedJobs = [];

    // -------------------- RemoteOK API --------------------
    try {
      final queryTitle = Uri.encodeComponent(widget.title);
      final queryLocation = Uri.encodeComponent(widget.location);
      final urlRemote = Uri.parse(
          'https://remoteok.io/api?tags=developer&search=$queryTitle+$queryLocation');

      final responseRemote = await http.get(urlRemote, headers: {
        "Accept": "application/json",
        "User-Agent": "FlutterApp"
      });

      if (responseRemote.statusCode == 200) {
        final data = json.decode(responseRemote.body);
        if (data.isNotEmpty) data.removeAt(0); // remove metadata
        combinedJobs.addAll(data.map((job) => {
          'source': 'RemoteOK',
          'title': job['position'] ?? 'Unknown',
          'company': job['company'] ?? '',
          'location': job['location'] ?? '',
          'url': job['url'] ?? ''
        }));
      }
    } catch (e) {
      print('RemoteOK fetch error: $e');
    }

    // -------------------- Adzuna India API --------------------
    try {
      final clientId = dotenv.env['ADZUNA_APP_ID'] ?? '';
      final clientKey = dotenv.env['ADZUNA_APP_KEY'] ?? '';
      final query = Uri.encodeComponent(widget.title);
      final locationQuery = Uri.encodeComponent(widget.location);

      final urlAdzuna = Uri.parse(
          'https://api.adzuna.com/v1/api/jobs/in/search/1?app_id=$clientId&app_key=$clientKey&what=$query&where=$locationQuery&results_per_page=20');

      final responseAdzuna = await http.get(urlAdzuna);
      if (responseAdzuna.statusCode == 200) {
        final data = json.decode(responseAdzuna.body);
        if (data['results'] != null) {
          combinedJobs.addAll(data['results'].map((job) => {
            'source': 'Adzuna',
            'title': job['title'] ?? 'Unknown',
            'company': job['company']['display_name'] ?? '',
            'location': job['location']['display_name'] ?? '',
            'url': job['redirect_url'] ?? ''
          }));
        }
      }
    } catch (e) {
      print('Adzuna fetch error: $e');
    }

    setState(() {
      jobs = combinedJobs;
      loading = false;
    });
  }

  Future<void> saveAppliedJob(String jobTitle, String applyUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final appliedJobs = prefs.getStringList('appliedJobs') ?? [];
    appliedJobs.add('$jobTitle|$applyUrl');
    await prefs.setStringList('appliedJobs', appliedJobs);
  }

  // Gradient Text
  Widget _gradientText(String text,
      {double fontSize = 18, FontWeight fontWeight = FontWeight.bold}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // dark blue shades
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: _gradientText("Jobs: ${widget.title}", fontSize: 22),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/BG.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : jobs.isEmpty
            ? Center(
          child: _gradientText("No jobs found",
              fontSize: 20, fontWeight: FontWeight.w600),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            final jobTitle = job['title'] ?? 'Unknown';
            final company = job['company'] ?? '';
            final location = job['location'] ?? '';
            final applyUrl = job['url'] ?? '';
            final source = job['source'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gradientText(jobTitle, fontSize: 20),
                        const SizedBox(height: 6),
                        Text(
                          "$company • $location",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Source: $source",
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.pinkAccent.shade100,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              elevation: 4,
                            ),
                            child: const Text("Apply"),
                            onPressed: () async {
                              if (applyUrl.isEmpty) return;
                              await saveAppliedJob(
                                  jobTitle, applyUrl);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => JobApplyWebview(
                                      applyUrl: applyUrl,
                                      name: 'Your Name',
                                      email: 'email@example.com',
                                      phone: '9999999999',
                                      resumePath: '',
                                    )),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
