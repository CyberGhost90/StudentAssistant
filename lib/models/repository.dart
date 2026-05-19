import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Repository {
  // Supabase table clients
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');
  final applicationClient =
      Supabase.instance.client.from('applications');

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

  //-------------------------APPLICATION--------------------------

  // Get all applications for one student
  Future<List<ApplicationModel>> getApplicationForStudent(
    String studentId,
  ) async {
    try {
      final response = await applicationClient
          .select()
          .eq('student_id', studentId)
          .order(
            'submission_date',
            ascending: false,
          );

      return (response as List)
          .map((e) => ApplicationModel.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get all applications (admin)
  Future<List<ApplicationModel>> getAllApplications() async {
    try {
      final response = await applicationClient.select().order(
            'submission_date',
            ascending: false,
          );

      return (response as List)
          .map((e) => ApplicationModel.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Check if student already applied
  Future<bool> studentHasApplication(String studentId) async {
    try {
      final response = await applicationClient
          .select()
          .eq('student_id', studentId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Create application
  Future<bool> createApplication({
    required String studentId,
    required int yearOfStudy,
    required String module1,
    String? module2,
    required bool eligibilityConfirmed,
    String? documentUrl,
  }) async {
    try {
      await applicationClient.insert({
        'student_id': studentId,
        'year_of_study': yearOfStudy,
        'module_1': module1,
        'module_2': module2,
        'eligibility_confirmed': eligibilityConfirmed,
        'supporting_document_url': documentUrl,
        'submission_date': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update application
  Future<bool> updateApplication({
    required String applicationId,
    int? yearOfStudy,
    String? module1,
    String? module2,
    bool? eligibilityConfirmed,
    String? documentUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (yearOfStudy != null) {
        updates['year_of_study'] = yearOfStudy;
      }

      if (module1 != null) {
        updates['module_1'] = module1;
      }

      if (module2 != null) {
        updates['module_2'] = module2;
      }

      if (eligibilityConfirmed != null) {
        updates['eligibility_confirmed'] = eligibilityConfirmed;
      }

      if (documentUrl != null) {
        updates['supporting_document_url'] = documentUrl;
      }

      await applicationClient
          .update(updates)
          .eq('id', applicationId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update application status
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
  }) async {
    try {
      await applicationClient.update({
        'status': newStatus,
      }).eq('id', applicationId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete application
  Future<bool> deleteApplication(String applicationId) async {
    try {
      await applicationClient
          .delete()
          .eq('id', applicationId);

      return true;
    } catch (e) {
      return false;
    }
  }

  //-------------------------DOCUMENT STORAGE--------------------------

  final String bucketName = 'student-bucket';

  // Pick document
  Future<File?> pickStudentDocs() async {
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
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