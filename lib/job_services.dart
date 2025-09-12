List<Map<String, String>> fetchJobsByUserInput(String title, String location) {
  // TODO: Replace with actual job portal fetch API or scraping
  return [
    {
      "title": title,
      "company": "TechCorp",
      "location": location,
      "applyLink": "https://jobportal.com/apply/123"
    },
    {
      "title": title,
      "company": "InnovateX",
      "location": location,
      "applyLink": "https://jobportal.com/apply/456"
    },
  ];
}

void saveAppliedJob(String title, String company, String location, String resumePath, String status) {
  // TODO: Save in Firestore or SQLite
}
