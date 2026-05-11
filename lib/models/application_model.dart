class ApplicationModel {
  final String id;
  final String studentId;
  final int yearOfStudy;
  final String module1;
  final String? module2;
  final String? supportingDocumentUrl;
  final bool eligibilityConfirmed;
  final String submissionDate;
  final String status; // 'pending', 'approved', 'rejected'

  ApplicationModel({
    required this.id,
    required this.studentId,
    required this.yearOfStudy,
    required this.module1,
    this.module2,
    this.supportingDocumentUrl,
    required this.eligibilityConfirmed,
    required this.submissionDate,
    this.status = 'pending',
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      yearOfStudy: json['year_of_study'] as int,
      module1: json['module_1'].toString(),
      module2: json['module_2']?.toString(),
      supportingDocumentUrl: json['supporting_document_url']?.toString(),
      eligibilityConfirmed: json['eligibility_confirmed'] as bool? ?? false,
      submissionDate: json['submission_date'].toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'year_of_study': yearOfStudy,
      'module_1': module1,
      'module_2': module2,
      'supporting_document_url': supportingDocumentUrl,
      'eligibility_confirmed': eligibilityConfirmed,
      'submission_date': submissionDate,
      'status': status,
    };
  }

  // Used for editing — create a copy with updated fields
  ApplicationModel copyWith({
    String? id,
    String? studentId,
    int? yearOfStudy,
    String? module1,
    String? module2,
    String? supportingDocumentUrl,
    bool? eligibilityConfirmed,
    String? submissionDate,
    String? status,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1: module1 ?? this.module1,
      module2: module2 ?? this.module2,
      supportingDocumentUrl:
          supportingDocumentUrl ?? this.supportingDocumentUrl,
      eligibilityConfirmed: eligibilityConfirmed ?? this.eligibilityConfirmed,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
    );
  }
}
