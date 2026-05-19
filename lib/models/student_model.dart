//please do not touch!!!
class Student {
  String? studentEmail;
  String? firstName;
  String? surname;
  String? password;
  DateTime? yearOfStudy;
  String? firstModule;
  String? secondModule;
  String? photoUrl;
  String? status;

  Student({
    this.studentEmail,
    this.firstName,
    this.surname,
    this.password,
    this.yearOfStudy,
    this.firstModule,
    this.secondModule,
    this.photoUrl,
    this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentEmail: json['studentEmail'],
      firstName: json['FirstName'],
      surname: json['Surname'],
      password: json['password'],
      yearOfStudy: json['yearOfStudy'],
      firstModule: json['firstModule'],
      secondModule: json['secondModule'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentEmail': studentEmail,
      'FirstName': firstName,
      'Surname': surname,
      'password': password,
      'yearOfStudy': yearOfStudy,
      'firstModule': firstModule,
      'secondModule': secondModule,
      'photoUrl': photoUrl,
    };
  }

  Student copyWith({
    String? studentEmail,
    String? firstName,
    String? surname,
    String? password,
    DateTime? yearOfStudy,
    String? firstModule,
    String? secondModule,
    String? photoUrl,
    String? status,
  }) {
    return Student(
      studentEmail: studentEmail ?? this.studentEmail,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      password: password ?? this.password,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      firstModule: firstModule ?? this.firstModule,
      secondModule: secondModule ?? this.secondModule,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
    );
  }
}
