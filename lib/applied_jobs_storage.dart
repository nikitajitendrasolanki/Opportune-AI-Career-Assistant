import 'package:shared_preferences/shared_preferences.dart';

class AppliedJobsStorage {
  static const _key = 'applied_jobs';

  static Future<void> saveAppliedJob(String jobId, String jobTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (!data.contains('$jobId|$jobTitle')) {
      data.add('$jobId|$jobTitle');
      await prefs.setStringList(_key, data);
    }
  }

  static Future<List<Map<String, String>>> getAppliedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) {
      final parts = e.split('|');
      return {'id': parts[0], 'title': parts[1]};
    }).toList();
  }
}
