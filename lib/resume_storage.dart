import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResumeStorage {
  static const _key = "resume_data";

  static Future<void> saveResume(Map<String, dynamic> resumeData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(resumeData));
  }

  static Future<Map<String, dynamic>> loadResume() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return {};
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> clearResume() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
