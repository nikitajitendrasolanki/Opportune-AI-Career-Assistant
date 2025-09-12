// resume_pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

String _safe(dynamic v) => v == null ? '' : v.toString();

String _formatDate(Map<String, dynamic> item,
    {String startKey = 'start_year', String endKey = 'end_year'}) {
  final s = _safe(item[startKey]);
  final e = _safe(item[endKey]);
  if (s.isEmpty && e.isEmpty) return '';
  if (s.isEmpty) return e;
  if (e.isEmpty) return '$s - Present';
  return '$s - $e';
}

Future<void> generateResumePDF(Map<String, dynamic> resumeData) async {
  final pdf = pw.Document();

  final personal = resumeData['personalInfo'] ?? {};
  final education =
  List<Map<String, dynamic>>.from(resumeData['education'] ?? []);
  final experience =
  List<Map<String, dynamic>>.from(resumeData['experience'] ?? []);
  final projects =
  List<Map<String, dynamic>>.from(resumeData['projects'] ?? []);
  final skills = List<Map<String, dynamic>>.from(resumeData['skills'] ?? []);
  final certifications =
  List<Map<String, dynamic>>.from(resumeData['certifications'] ?? []);
  final languages =
  List<Map<String, dynamic>>.from(resumeData['languages'] ?? []);

  // Normalize socialLinks similarly
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

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => <pw.Widget>[
        // Header
        pw.Center(
          child: pw.Text(_safe(personal['name']),
              style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black)),
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            "${_safe(personal['phone'])} | ${_safe(personal['email'])}",
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ),
        if (socialEntries.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Wrap(
              spacing: 12,
              children: socialEntries
                  .map<pw.Widget>((entry) => pw.UrlLink(
                destination: entry.value,
                child:
                pw.Text(entry.key, style: pw.TextStyle(color: PdfColors.blue)),
              ))
                  .toList(),
            ),
          ),
        ],
        pw.Divider(),

        // Education
        if (education.isNotEmpty) ...[
          pw.Text("Education",
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue)),
          pw.SizedBox(height: 6),
          ...education.map<pw.Widget>((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(_safe(e['institute']),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("${_safe(e['degree'])}, ${_safe(e['field'])}"),
                    ],
                  ),
                ),
                pw.Text(_safe(e['year']),
                    style: pw.TextStyle(color: PdfColors.grey700)),
              ],
            ),
          )).toList(),
          pw.Divider(),
        ],

        // Experience
        if (experience.isNotEmpty) ...[
          pw.Text("Experience",
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue)),
          pw.SizedBox(height: 6),
          ...experience.map<pw.Widget>((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(_safe(e['job_title']),
                          style:
                          pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("${_safe(e['company_name'])}, ${_safe(e['location'])}"),
                      if (_safe(e['description']).isNotEmpty)
                        pw.Text(_safe(e['description'])),
                    ],
                  ),
                ),
                pw.Text(_formatDate(e),
                    style: pw.TextStyle(color: PdfColors.grey700)),
              ],
            ),
          )).toList(),
          pw.Divider(),
        ],

        // Projects
        if (projects.isNotEmpty) ...[
          pw.Text("Projects",
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue)),
          pw.SizedBox(height: 6),
          ...projects.map<pw.Widget>((p) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_safe(p['project_title']),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (_safe(p['project_link']).isNotEmpty)
                  pw.UrlLink(
                    destination: p['project_link'],
                    child: pw.Text(_safe(p['project_link']),
                        style: pw.TextStyle(color: PdfColors.blue)),
                  ),
                if (_safe(p['description']).isNotEmpty)
                  pw.Text(_safe(p['description'])),
                pw.Text("Tech: ${_safe(p['technologies_used'])}"),
              ],
            ),
          )).toList(),
          pw.Divider(),
        ],

        // Skills
        if (skills.isNotEmpty) ...[
          pw.Text("Skills",
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue)),
          pw.SizedBox(height: 4),
          pw.Wrap(
            spacing: 10,
            runSpacing: 6,
            children: skills
                .map<pw.Widget>((s) => pw.Container(
              padding:
              const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Text(_safe(s['skill_name']),
                  style: pw.TextStyle(color: PdfColors.blue900)),
            ))
                .toList(),
          ),
          pw.Divider(),
        ],

        // Certifications
        if (certifications.isNotEmpty) ...[
          pw.Text("Certifications",
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue)),
          pw.SizedBox(height: 4),
          ...certifications
              .map<pw.Widget>((c) => pw.Text(
              "• ${_safe(c['certification_name'])} - ${_safe(c['issuing_org'])}"))
              .toList(),
          pw.Divider(),
        ],

        // Languages
        if (languages.isNotEmpty) ...[
          pw.Text("Languages",
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue)),
          pw.SizedBox(height: 4),
          ...languages
              .map<pw.Widget>((l) => pw.Text(
              "• ${_safe(l['language_name'])} - ${_safe(l['proficiency'])}"))
              .toList(),
        ],
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
