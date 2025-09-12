import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  final String baseUrl;

  DatabaseService({required this.baseUrl});

  // Get current Firebase UID
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Generic POST function
  Future<Map<String, dynamic>> postData(
      {required String endpoint, required Map<String, dynamic> payload}) async {
    if (uid == null) throw Exception("User not logged in");

    final body = jsonEncode({
      "firebase_uid": uid,
      ...payload,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to post data: ${response.statusCode} - ${response.body}");
    }
  }

  // Save Social Links
  Future<void> saveSocialLinks(Map<String, dynamic> links) async {
    await postData(endpoint: "social_links/upsert", payload: {"social_links": links});
  }

  // Save Experience
  Future<void> saveExperience(List<Map<String, dynamic>> experiences) async {
    await postData(endpoint: "experience/upsert", payload: {"experiences": experiences});
  }

  // Save Education
  Future<void> saveEducation(List<Map<String, dynamic>> education) async {
    await postData(endpoint: "education/upsert", payload: {"education": education});
  }

  // Save Projects
  Future<void> saveProjects(List<Map<String, dynamic>> projects) async {
    await postData(endpoint: "projects/upsert", payload: {"projects": projects});
  }

  // Save Certifications
  Future<void> saveCertifications(List<Map<String, dynamic>> certifications) async {
    await postData(endpoint: "certifications/upsert", payload: {"certifications": certifications});
  }

  // Save Languages
  Future<void> saveLanguages(List<Map<String, dynamic>> languages) async {
    await postData(endpoint: "languages/upsert", payload: {"languages": languages});
  }

  // Save Skills
  Future<void> saveSkills(List<String> skills) async {
    await postData(endpoint: "skills/upsert", payload: {"skills": skills});
  }

  // Fetch any data (example)
  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    if (uid == null) throw Exception("User not logged in");

    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint?firebase_uid=$uid"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to fetch data: ${response.statusCode} - ${response.body}");
    }
  }
}
