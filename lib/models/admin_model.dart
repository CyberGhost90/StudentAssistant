class Admin {
  String? email;
  String? firstName;
  String? surname;
  String? password;
  String? status;

  Admin({this.email, this.firstName, this.surname, this.password, this.status});

  // Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'AdminEmail': email,
      'FirstName': firstName,
      'Surname': surname,
      'password': password,
      'status': status,
    };
  }

  // Factory to create from Supabase response
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      email: json['AdminEmail'],
      firstName: json['FirstName'],
      surname: json['Surname'],
      password: json['password'],
      status: json['status'], // Assuming this field exists
    );
  }

  Admin copyWith({
    String? email,
    String? firstName,
    String? surname,
    String? password,
    String? status,
  }) {
    return Admin(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }
}
