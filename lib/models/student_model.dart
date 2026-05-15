class Student {
  String? studentEmail;
  String? firstName;
  String? surname;
  String? password;
  String? module1;
  String? module2;
  String? supportingDocumentUrl;
  String? status;
  DateTime? submissionDate;
  int? yearOfStudy;

  Student({
    this.studentEmail,
    this.firstName,
    this.surname,
    this.password,
    this.module1,
    this.module2,
    this.supportingDocumentUrl,
    this.status,
    this.submissionDate,
    this.yearOfStudy,
  });
  // Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'studentEmail': studentEmail,
      'firstName': firstName,
      'surname': surname,
      'password': password,
      'module1': module1,
      'module2': module2,
      'supportingDocumentUrl': supportingDocumentUrl,
      'submission_date': submissionDate?.toIso8601String(),
      'yearOfStudy': yearOfStudy,
    };
  }

  // Factory to create from Supabase response
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentEmail: json['studentEmail'],
      firstName: json['firstName'],
      surname: json['surname'],
      password: json['password'],
      module1: json['module1'],
      module2: json['module2'],
      supportingDocumentUrl: json['supportingDocumentUrl'],
      submissionDate: DateTime.parse(json['submission_date']),
      yearOfStudy: json['yearOfStudy'], // Assuming this field exists
    );
  }

  Student copyWith({
    String? studentEmail,
    String? firstName,
    String? surname,
    String? password,
    String? module1,
    String? module2,
    String? supportingDocumentUrl,
    String? status,
    DateTime? submissionDate,
    int? yearOfStudy,
  }) {
    return Student(
      studentEmail: studentEmail ?? this.studentEmail,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      password: password ?? this.password,
      module1: module1 ?? this.module1,
      module2: module2 ?? this.module2,
      supportingDocumentUrl:
          supportingDocumentUrl ?? this.supportingDocumentUrl,
      status: status ?? this.status,
      submissionDate: submissionDate ?? this.submissionDate,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
    );
  }
}
