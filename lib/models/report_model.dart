enum ReportStatus { new_, viewed }

enum TestType { voice, drawing, both }

/// A single row in the "Diagnostic Reports" list.
class ReportModel {
  final String title;
  final String doctorName;
  final String date;
  final ReportStatus status;
  final TestType testType;

  // Detail fields (shown on the Report Detail screen).
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

  static List<ReportModel> mockList() {
    return [
      const ReportModel(
        title: 'Report — Voice + Drawing',
        doctorName: 'Dr. Ahmed',
        date: 'Apr 24, 2026',
        status: ReportStatus.new_,
        testType: TestType.both,
        diagnosisResult: 'No PD Detected',
        riskLevel: 'Low',
        reportWrittenDate: 'Apr 25, 2026',
        recommendations: [
          'Continue monitoring every 3 months',
          'Maintain exercise & physical activity',
          'Voice therapy sessions (2x per week)',
          'Follow-up drawing test in 3 months',
        ],
      ),
      const ReportModel(
        title: 'Report — Voice Analysis',
        doctorName: 'Dr. Ahmed',
        date: 'Apr 10, 2026',
        status: ReportStatus.viewed,
        testType: TestType.voice,
        diagnosisResult: 'No PD Detected',
        riskLevel: 'Low',
        reportWrittenDate: 'Apr 11, 2026',
        recommendations: [
          'Continue monitoring every 3 months',
          'Voice therapy sessions (2x per week)',
        ],
      ),
      const ReportModel(
        title: 'Report — Drawing Test',
        doctorName: 'Dr. Ahmed',
        date: 'Mar 26, 2026',
        status: ReportStatus.viewed,
        testType: TestType.drawing,
        diagnosisResult: 'No PD Detected',
        riskLevel: 'Low',
        reportWrittenDate: 'Mar 27, 2026',
        recommendations: [
          'Maintain exercise & physical activity',
          'Follow-up drawing test in 3 months',
        ],
      ),
      const ReportModel(
        title: 'Report — Voice Analysis',
        doctorName: 'Dr. Ahmed',
        date: 'Mar 10, 2026',
        status: ReportStatus.viewed,
        testType: TestType.voice,
        diagnosisResult: 'No PD Detected',
        riskLevel: 'Low',
        reportWrittenDate: 'Mar 11, 2026',
        recommendations: [
          'Continue monitoring every 3 months',
          'Voice therapy sessions (2x per week)',
        ],
      ),
    ];
  }
}

/// A single row in the Home "Recent Tests" list.
class RecentTestModel {
  final String title;
  final String date;
  final TestType type;

  const RecentTestModel({required this.title, required this.date, required this.type});

  static List<RecentTestModel> mockList() {
    return const [
      RecentTestModel(title: 'Voice Analysis', date: 'Apr 24, 2026', type: TestType.voice),
      RecentTestModel(title: 'Drawing Test', date: 'Apr 24, 2026', type: TestType.drawing),
      RecentTestModel(title: 'Voice Analysis', date: 'Apr 15, 2026', type: TestType.voice),
    ];
  }
}