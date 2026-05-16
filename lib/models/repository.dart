import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/exception_error.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//relevant people should update this to make it useful and test the code- KING
class Repository {
  //storage for all the data that we want to use in the app
  Admin? _admin;
  Student? _student;
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');
  final String? bucketName = 'student-bucket';
  //getters
  Admin? get admin => _admin;
  Student? get student => _student;

  //calling the file picker
  Future<File?> pickStudentDocs() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      _student!.supportingDocumentUrl = result.files.single.path!;
      return File(result.files.single.path!);
    }
    return null;
  }

  //upload a student documents to the bucket
  Future<File?> uploadStudentDocs(String studentEmail, File imageFile) async {
    final pickedDocs = DateTime.now().millisecondsSinceEpoch.toString();
    File? result = await pickStudentDocs();
    final ext = result!.path.split('.').last;

    try {
      final response = await Supabase.instance.client.storage
          .from(bucketName!)
          .upload('$studentEmail/$pickedDocs/$ext', imageFile);
      _student!.supportingDocumentUrl = response;
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while uploading documents.');
      return null;
    }
    return null;
  }

  //Delete stduent docs from the bucket
  Future<void> deleteStudentDocs(String studentEmail) async {
    try {
      await Supabase.instance.client.storage.from(bucketName!).remove([
        _student!.supportingDocumentUrl!,
      ]);
    } catch (e) {
      Exceptionerror.alertDialogError(
        'Error occurred while deleting documents.',
      );
    }
  }

  //update the student documents in the bucket
  Future<void> updateStudentDocs(String studentEmail) async {
    try {
      File? newDocs = await pickStudentDocs();
      if (newDocs != null) {
        await Supabase.instance.client.storage
            .from(bucketName!)
            .update(
              '$studentEmail/${_student!.supportingDocumentUrl!.split('/').last}',
              newDocs,
            );
        _student!.supportingDocumentUrl = newDocs.path;
      }
    } catch (e) {
      Exceptionerror.snackBarError(
        'Error occurred while updating document URL.',
      );
    }
  }

  //READ
  //returns all students
  Future<Iterable<Student>> getStudents() async {
    try {
      final response = await studentClient.select();
      if (response.isEmpty != true) {
        return (response as List).map(
          (e) => Student(
            studentEmail: e['studentEmail'],
            password: e['password'],
            firstName: e['FirstName'],
            surname: e['Surname'],
            yearOfStudy: e['yearOfStudy'],
          ),
        );
      } else {
        Exceptionerror.snackBarError('No students found.');
        return [];
      }
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while fetching students.');
      return [];
    }
  }

  //READ
  //returns 1 admin
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
        Exceptionerror.snackBarError('Admin not found.');
      }
      return admin;
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while fetching admin.');
      return admin;
    }
  }

  //returns 1 student
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
          firstName: response['FirstName'],
          surname: response['Surname'],
          yearOfStudy: response['yearOfStudy'], // Assuming this field exists
        ); // Assuming a cast method
      } else {
        Exceptionerror.snackBarError('Student not found.');
      }
      return student;
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while fetching student.');
      return student;
    }
  }

  //CREATE
  Future<Admin> createAdmin(Admin admin) async {
    try {
      admin = await adminClient.insert({
        'AdminEmail': admin.email,
        'password': admin.password,
        'FirstName': admin.firstName,
        'Surname': admin.surname,
      });
      // Update the local admin variable after successful insertion
      _admin = admin;
      return admin;
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
      return admin; // Return the original admin object in case of an error
    }
  }

  Future<Student> createStudent(Student student) async {
    try {
      student = await studentClient.insert({
        'studentEmail': student.studentEmail,
        'password': student.password,
        'FirstName': student.firstName,
        'Surname': student.surname,
      });
      // Update the local student variable after successful insertion
      _student = student;
      return student;
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
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
            'FirstName': admin.firstName,
            'Surname': admin.surname,
          })
          .eq('AdminEmail', admin.email.toString());
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while updating admin.');
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await studentClient
          .update({
            'studentEmail': student.studentEmail,
            'password': student.password,
            'FirstName': student.firstName,
            'Surname': student.surname,
          })
          .eq('studentEmail', student.studentEmail.toString());
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
    }
  }

  //DELETE
  Future<void> deleteAdmin(Admin admin) async {
    try {
      await adminClient.delete().eq('AdminEmail', admin.email.toString());
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
    }
  }

  Future<void> deleteStudent(Student student) async {
    try {
      await studentClient.delete().eq(
        'studentEmail',
        student.studentEmail.toString(),
      );
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
    }
  }
}
