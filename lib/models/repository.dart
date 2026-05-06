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

  Future<Iterable<Student>> getStudents() async {
    try {
      final response = await studentClient.select();
      if (response.isEmpty != true) {
        return (response as List).map(
          (e) => Student(
            studentEmail: e['studentEmail'],
            password: e['password'],
            firstName: e['FirstName'],
            Surname: e['Surname'],
          ),
        );
      } else {
        Exceptionerror.SnackBarError;
        return [];
      }
    } catch (e) {
      Exceptionerror.SnackBarError;
      return [];
    }
  }

  //READ
  Future<Admin> getAdmin(Admin admin) async {
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
      return admin;
    } catch (e) {
      Exceptionerror.SnackBarError;
      return admin;
    }
  }

  Future<Student> getStudent(Student student) async {
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
      return student;
    } catch (e) {
      Exceptionerror.SnackBarError;
      return student;
    }
  }

  //CREATE
  Future<Admin> createAdmin(Admin admin) async {
    try {
      admin = await adminClient.insert({
        'AdminEmail': admin.email,
        'password': admin.password,
        'FirstName': admin.FirstName,
        'Surname': admin.Surname,
      });
      // Update the local admin variable after successful insertion
      _admin = admin;
      return admin;
    } catch (e) {
      Exceptionerror.AlertDialogError(e.toString() as BuildContext);
      return admin; // Return the original admin object in case of an error
    }
  }

  Future<Student> createStudent(Student student) async {
    try {
      student = await studentClient.insert({
        'studentEmail': student.studentEmail,
        'password': student.password,
        'FirstName': student.firstName,
        'Surname': student.Surname,
      });
      // Update the local student variable after successful insertion
      _student = student;
      return student;
    } catch (e) {
      Exceptionerror.AlertDialogError(e.toString() as BuildContext);
      return student; // Return the original student object in case of an error
    }
  }

  //UPDATE
  Future<void> updateAdmin(Admin admin) async {
    try {
      await adminClient
          .update({
            'AdminEmail': admin.email,
            'password': admin.password,
            'FirstName': admin.FirstName,
            'Surname': admin.Surname,
          })
          .eq('AdminEmail', admin.email.toString());
    } catch (e) {
      Exceptionerror.SnackBarError;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await studentClient
          .update({
            'studentEmail': student.studentEmail,
            'password': student.password,
            'FirstName': student.firstName,
            'Surname': student.Surname,
          })
          .eq('studentEmail', student.studentEmail.toString());
    } catch (e) {
      Exceptionerror.AlertDialogError(e.toString() as BuildContext);
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
