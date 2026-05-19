import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Repository {
  // Supabase table clients
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');
  final String bucketName = 'student-bucket';
  

  // Local cache
  Admin? _admin;
  Student? _student;

  // Getters
  Admin? get admin => _admin;
  Student? get student => _student;

  //-------------------------STUDENT------------------------

  // Returns all students
  Future<Iterable<Student>> getStudents() async {
    try {
      final response = await studentClient.select();

      if (response.isNotEmpty) {
        return (response as List)
            .map(
              (e) => Student(
                firstName: e['FirstName'],
                surname: e['Surname'],
                studentEmail: e['studentEmail'],
                yearOfStudy: e['yearOfStudy'],
                password: e['password'],
              ),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Return one student
  Future<Student?> getStudent(Student student) async {
    try {
      final response = await studentClient
          .select()
          .eq('studentEmail', student.studentEmail.toString())
          .single();

      _student = Student(
        studentEmail: response['studentEmail'],
        password: response['password'],
        firstName: response['FirstName'],
        surname: response['Surname'],
        yearOfStudy: response['yearOfStudy'],
      );

      return _student;
    } catch (e) {
      return null;
    }
  }

  // Create student
  Future<Student?> createStudent(Student student) async {
    try {
      await studentClient.insert({
        'studentEmail': student.studentEmail,
        'password': student.password,
        'FirstName': student.firstName,
        'Surname': student.surname,
        'yearOfStudy': student.yearOfStudy,
      });

      _student = student;

      return student;
    } catch (e) {
      return null;
    }
  }

  // Update student
  Future<bool> updateStudent(Student student) async {
    try {
      await studentClient
          .update({
            'studentEmail': student.studentEmail,
            'password': student.password,
            'FirstName': student.firstName,
            'Surname': student.surname,
            'yearOfStudy': student.yearOfStudy,
          })
          .eq('studentEmail', student.studentEmail.toString());

      _student = student;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete student
  Future<bool> deleteStudent(Student student) async {
    try {
      await studentClient
          .delete()
          .eq('studentEmail', student.studentEmail.toString());

      return true;
    } catch (e) {
      return false;
    }
  }

  //-------------------------ADMIN-------------------------

  // Return one admin
  Future<Admin?> getAdmin(Admin admin) async {
    try {
      final response = await adminClient
          .select()
          .eq('AdminEmail', admin.email.toString())
          .single();

      _admin = Admin(
        email: response['AdminEmail'],
        password: response['password'],
        firstName: response['FirstName'],
        surname: response['Surname'],
      );

      return _admin;
    } catch (e) {
      return null;
    }
  }

  // Create admin
  Future<Admin?> createAdmin(Admin admin) async {
    try {
      await adminClient.insert({
        'AdminEmail': admin.email,
        'password': admin.password,
        'FirstName': admin.firstName,
        'Surname': admin.surname,
      });

      _admin = admin;

      return admin;
    } catch (e) {
      return null;
    }
  }

  // Update admin
  Future<bool> updateAdmin(Admin admin) async {
    try {
      await adminClient
          .update({
            'AdminEmail': admin.email,
            'password': admin.password,
            'FirstName': admin.firstName,
            'Surname': admin.surname,
          })
          .eq('AdminEmail', admin.email.toString());

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete admin
  Future<bool> deleteAdmin(Admin admin) async {
    try {
      await adminClient
          .delete()
          .eq('AdminEmail', admin.email.toString());

      return true;
    } catch (e) {
      return false;
    }
  }
  //-------------------------DOCUMENT STORAGE--------------------------
  // Pick document
  Future<File?> pickStudentDocs() async {
    FilePickerResult? result = await FilePicker.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
    } else {
      Exceptionerror.SnackBarError('User cancelled document selection');
    }
  }

  // Upload document
  Future<String?> uploadStudentDocs(
    String studentId,
    File file,
  ) async {
    try {
      final ext = file.path.split('.').last;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$ext';

      final path = '$studentId/$fileName';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      return Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  // Delete document
  Future<bool> deleteStudentDocs(String filePath) async {
    try {
      await Supabase.instance.client.storage
          .from(bucketName)
          .remove([filePath]);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Replace document
  Future<String?> updateStudentDocs(
    String studentId,
    String oldPath,
  ) async {
    try {
      final newFile = await pickStudentDocs();

      if (newFile == null) return null;

      await deleteStudentDocs(oldPath);

      return await uploadStudentDocs(
        studentId,
        newFile,
      );
    } catch (e) {
      return null;
    }
  }
}