// Data models for the Reports list and the Home "My uploads" list.

/// Whether a report has been opened by the patient yet.
enum ReportStatus { new_, viewed }

/// Which kind of test a row represents.
enum TestType { voice, drawing, mri, both }

/// A single row in the "Diagnostic Reports" list. Reports are written by a
/// doctor (on the  web portal) after reviewing an AI analysis —
/// one report can cover several of the patient's tests at once — then
/// synced back here via Firestore once the doctor submits it (see
/// lib/services/db_helper.dart's getReports()). A doctor's saved draft is
/// not shown here until they submit it.
class ReportModel {
  /// The report document's own id (used to mark it as viewed).
  final String id;

  /// Every test this report covers.
  final List<String> testIds;

  /// Display label for each covered test's modality (e.g. "Voice",
  /// "Spiral Drawing"), same order as [testIds].
  final List<String> testTypeLabels;

  final String title;
  final String doctorName;
  final ReportStatus status;
  final String clinicalNotes;
  final String recommendations;
  final String reportWrittenDate;

  const ReportModel({
    required this.id,
    required this.testIds,
    required this.testTypeLabels,
    required this.title,
    required this.doctorName,
    required this.status,
    required this.clinicalNotes,
    required this.recommendations,
    required this.reportWrittenDate,
  });
}

/// A single row in the Home / Upload "My uploads" list. Backed by
/// Firebase — one row per test the signed-in user has actually uploaded
/// (see lib/services/db_helper.dart).
class RecentTestModel {
  final String title;
  final String date;
  final TestType type;

  /// Link to the uploaded photo (spiral drawing) or mri, if one was saved —
  /// null for a voice test
  final String? fileUrl;

  const RecentTestModel({
    required this.title,
    required this.date,
    required this.type,
    this.fileUrl,
  });
}
