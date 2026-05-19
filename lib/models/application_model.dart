class ApplicationModel {
  String? id;
  String? studentId;
  int? yearOfStudy;
  String? module1;
  String? module2;
  bool? eligibilityConfirmed;
  String? supportingDocumentUrl;
  String? status;
  DateTime? submissionDate;

  ApplicationModel({
    this.id,
    this.studentId,
    this.yearOfStudy,
    this.module1,
    this.module2,
    this.eligibilityConfirmed,
    this.supportingDocumentUrl,
    this.status,
    this.submissionDate,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      studentId: json['student_id'],
      yearOfStudy: json['year_of_study'],
      module1: json['module_1'],
      module2: json['module_2'],
      eligibilityConfirmed: json['eligibility_confirmed'],
      supportingDocumentUrl: json['supporting_document_url'],
      status: json['status'],
      submissionDate: json['submission_date'] != null
          ? DateTime.parse(json['submission_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'year_of_study': yearOfStudy,
      'module_1': module1,
      'module_2': module2,
      'eligibility_confirmed': eligibilityConfirmed,
      'supporting_document_url': supportingDocumentUrl,
      'status': status,
      'submission_date': submissionDate?.toIso8601String(),
    };
  }
}