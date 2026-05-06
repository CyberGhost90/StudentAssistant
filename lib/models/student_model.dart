class StudentModel {
  String? id;
  String studentId;
  int yearOfStudy;
  String module1;
  String? module2;
  String? supportingDocumentUrl;
  bool eligibilityConfirmed;
  DateTime submissionDate;

  StudentModel({
    this.id,
    required this.studentId,
    required this.yearOfStudy,
    required this.module1,
    this.module2,
    this.supportingDocumentUrl,
    required this.eligibilityConfirmed,
    required this.submissionDate,
  });
}
