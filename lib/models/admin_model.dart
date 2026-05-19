//please do not touch!!!
class Admin {
  String? email;
  String? firstName;
  String? surname;
  String? password;
  String? status;

  Admin({
    this.email, 
    this.firstName, 
    this.surname, 
    this.password, 
    this.status
    });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      email: json['AdminEmail'],
      firstName: json['FirstName'],
      surname: json['Surname'],
      password: json['password'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AdminEmail': email,
      'FirstName': firstName,
      'Surname': surname,
      'password': password,
      'status': status,
    };
  }
}
