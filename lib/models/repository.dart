import 'package:flutter/material.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//relevant people should update this to make it useful and test the code- KING
class Repository {
  //storage for all the data that we want to use in the app
  Admin? _admin;
  Student? _student;
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');
  //getters
  Admin? get admin => _admin;
  Student? get student => _student;

  //READ
  Future<void> getAdmin(Admin admin) async {
    try {
      final response = await adminClient
          .select()
          .eq('email', admin.email.toString())
          .single();

      if (response.isEmpty == false) {
        _admin = Admin(
          email: response['AdminEmail'],
          password: response['password'],
        );
      } else {
        Exceptionerror.SnackBarError;
      }
    } catch (e) {
      Exceptionerror.SnackBarError;
    }
  }

  Future<void> getStudent(Student student) async {
    try {
      final response = await studentClient
          .select()
          .eq(
            'email',
            student.studentEmail.toString(),
          ) // Use the object's email
          .single();

      if (response.isEmpty == false) {
        _student = Student(
          studentEmail: response['studentEmail'],
          password: response['password'],
        ); // Assuming a cast method
      } else {
        Exceptionerror.SnackBarError;
      }
    } catch (e) {
      Exceptionerror.SnackBarError;
    }
  }

  //CREATE
  void createAdmin(Admin admin) {
    _admin = admin;
  }

  void createStudent(Student student) {
    _student = student;
  }

  //UPDATE
  Future<Admin> updateAdmin(Admin admin) async {
    try {
      admin = await adminClient
          .update({
            'AdminEmail': admin.email,
            'password': admin.password,
            'FirstName': admin.FirstName,
            'Surname': admin.Surname,
          })
          .eq('AdminEmail', admin.email.toString());
      return admin;
    } catch (e) {
      Exceptionerror.SnackBarError;
      return admin;
    }
  }

  Future<Student> updateStudent(Student student) async {
    try {
      student = await studentClient
          .update({
            'studentEmail': student.studentEmail,
            'password': student.password,
            'FirstName': student.firstName,
            'Surname': student.Surname,
          })
          .eq('studentEmail', student.studentEmail.toString());
      return student;
    } catch (e) {
      Exceptionerror.AlertDialogError(e.toString() as BuildContext);
      return student;
    }
  }

  //DELETE
  Future<void> deleteAdmin(Admin admin) async {
    try {
      await adminClient.delete().eq('AdminEmail', admin.email.toString());
    } catch (e) {
      Exceptionerror.AlertDialogError(e.toString() as BuildContext);
    }
  }

  Future<void> deleteStudent(Student student) async {
    try {
      await studentClient.delete().eq(
        'studentEmail',
        student.studentEmail.toString(),
      );
    } catch (e) {
      Exceptionerror.AlertDialogError(e.toString() as BuildContext);
    }
  }
}
