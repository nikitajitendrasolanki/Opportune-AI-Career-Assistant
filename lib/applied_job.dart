class AppliedJob {
  final String title;
  final String company;
  final String location;
  final String applyLink;
  final String resumePath;
  final String status; // Applied / Pending / Failed
  final DateTime timestamp;

  AppliedJob({
    required this.title,
    required this.company,
    required this.location,
    required this.applyLink,
    required this.resumePath,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'applyLink': applyLink,
      'resumePath': resumePath,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
