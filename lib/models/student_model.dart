class Student {
  String? studentEmail;
  String? firstName;
  String? surname;
  String? password;
  int? yearOfStudy;

  Student({
    this.studentEmail,
    this.firstName,
    this.surname,
    this.password,
    this.yearOfStudy
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentEmail: json['studentEmail'],
      firstName: json['FirstName'],
      surname: json['Surname'],
      password: json['password'],
      yearOfStudy: json['yearOfStudy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentEmail': studentEmail,
      'FirstName': firstName,
      'Surname': surname,
      'password': password,
      'yearOfStudy': yearOfStudy,
    };
  }
}
