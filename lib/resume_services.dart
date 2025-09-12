import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:pdf/pdf.dart';

Future<String> tailorResume(String jobDescription, Map<String, dynamic> resumeData) async {
  final response = await http.post(
    Uri.parse("https://api.groq.com/tailor-resume"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer YOUR_GROQ_API_KEY",
    },
    body: jsonEncode({
      "job_description": jobDescription,
      "resume_data": resumeData,
    }),
  );

  final data = jsonDecode(response.body);
  return data['tailored_resume_text'];
}

Future<String> generateResumePDF(String resumeText, String fileName) async {
  final pdf = pw.Document();
  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Text(resumeText);
    },
  ));

  final file = File(fileName);
  await file.writeAsBytes(await pdf.save());
  return file.path;
}

Map<String, dynamic> getSavedResumeData() {
  // TODO: Fetch saved resume data from app database
  return {
    "name": "User Name",
    "skills": ["Flutter", "Dart", "Firebase"],
    "experience": ["2 years at TechCorp"],
    "education": ["B.Tech in CS"],
  };
}
