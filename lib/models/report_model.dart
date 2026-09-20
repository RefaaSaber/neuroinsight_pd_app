enum ReportStatus { new_, viewed }

enum TestType { voice, drawing, both }

/// A single row in the "Diagnostic Reports" list. Reports are written by a
/// doctor after reviewing an AI analysis of a test — this app doesn't wire
/// up that analysis/report-writing backend yet, so a new account simply has
/// none until that piece exists.
class ReportModel {
  final String title;
  final String doctorName;
  final String date;
  final ReportStatus status;
  final TestType testType;
  final String diagnosisResult;
  final String riskLevel;
  final String reportWrittenDate;
  final List<String> recommendations;

  const ReportModel({
    required this.title,
    required this.doctorName,
    required this.date,
    required this.status,
    required this.testType,
    required this.diagnosisResult,
    required this.riskLevel,
    required this.reportWrittenDate,
    required this.recommendations,
  });
}

/// A single row in the Home / Upload "Recent Tests" list. Backed by
/// Firebase — one row per test the signed-in user has actually uploaded
/// (see lib/services/db_helper.dart).
class RecentTestModel {
  final String title;
  final String date;
  final TestType type;

  const RecentTestModel({required this.title, required this.date, required this.type});
}