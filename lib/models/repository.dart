import 'package:flutter/material.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//relevant people should update this to make it useful and test the code- KING
class Repository {
<<<<<<< HEAD
  //Supabase table clients
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');

  //Local cache
=======
  //storage for all the data that we want to use in the app
>>>>>>> 4b24eceff9bab363ab8bc8ea257ccb1be2b340d7
  Admin? _admin;
  Student? _student;
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');
  //getters
  Admin? get admin => _admin;
  Student? get student => _student;

<<<<<<< HEAD
  //get applications for a student
  Future<List<ApplicationModel>> fetchApplications() async {
    try {
      final response = await applicationClient.select().order(
        'submission_date',
        ascending: false,
      );
      return (response as List)
          .map((e) => ApplicationModel.fromJson(e))
          .toList();
    } catch (e) {
      Exceptionerror.snackBarError('Error fetching applications: $e');
      return [];
    }
  }

  //-------------------------STUDENT------------------------
  //Returns all students
=======
>>>>>>> 4b24eceff9bab363ab8bc8ea257ccb1be2b340d7
  Future<Iterable<Student>> getStudents() async {
    try {
      final response = await studentClient.select();
      if (response.isEmpty != true) {
        return (response as List).map(
          (e) => Student(
<<<<<<< HEAD
            firstName: e['FirstName'],
            surname: e['Surname'],
=======
>>>>>>> 4b24eceff9bab363ab8bc8ea257ccb1be2b340d7
            studentEmail: e['studentEmail'],
            password: e['password'],
<<<<<<< HEAD
          ),
        );
      } else {
        Exceptionerror.snackBarError('No students found');
        return [];
      }
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while fetching students.');
=======
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
>>>>>>> 4b24eceff9bab363ab8bc8ea257ccb1be2b340d7
      return [];
    }
  }

<<<<<<< HEAD
  //Return one student
  Future<Student> getStudent(Student student) async {
    try {
      final response = await studentClient
          .select()
          .eq('email', student.studentEmail.toString())
          .single();
      if (response.isEmpty == false) {
        _student = Student(
          studentEmail: response['studentEmail'],
          password: response['password'],
          firstName: response['FirstName'],
          surname: response['Surname'],
          yearOfStudy: response['yearOfStudy'],
        );
      } else {
        Exceptionerror.snackBarError('Student not found.');
      }
      return student;
    } catch (e) {
      Exceptionerror.snackBarError('Error occured while fetching student.');
      return student;
    }
  }

  //Create student
  Future<Student> createStudent(Student student) async {
    try {
      await studentClient.insert({
        'studentEmail': student.studentEmail,
        'password': student.password,
        'FirstName': student.firstName,
        'Surname': student.surname,
      });
      _student = student;
      return student;
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
      return student;
    }
  }

  //Update student
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
      _student = student;
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
    }
  }

  //Delete student
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

  //-------------------------ADMIN-------------------------
  //Return 1 admin
=======
  //READ
>>>>>>> 4b24eceff9bab363ab8bc8ea257ccb1be2b340d7
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

<<<<<<< HEAD
  //-------------------------DOCUMENT STORAGE--------------------------
  final String bucketName = 'student-bucket';

  //Pick any file type (CV, ID copy, academic record, cover letter, etc.)
  Future<File?> pickStudentDocs() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  //upload a student document- preserves original file extension
  Future<String?> uploadStudentDocs(String studentId, File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$studentId/$fileName';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      //Return public URL to be stored in student_applications table
      return Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(path);
    } on StorageException catch (e) {
      Exceptionerror.snackBarError('Upload failed: ${e.message}');
      return null;
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while uploading documents.');
      return null;
    }
  }

  //Delete student document from storage
  Future<void> deleteStudentDocs(String filePath) async {
    try {
      await Supabase.instance.client.storage.from(bucketName).remove([
        filePath,
      ]);
    } on StorageException catch (e) {
      Exceptionerror.snackBarError('Delete failed: ${e.message}');
    } catch (e) {
      Exceptionerror.alertDialogError(
        'Error occurred while deleting documents.',
      );
    }
  }

  //Replace an existing document with a new one
  Future<String?> updateStudentDocs(String studentId, String oldPath) async {
    try {
      final newFile = await pickStudentDocs();
      if (newFile == null) return null;
      await deleteStudentDocs(oldPath);
      return await uploadStudentDocs(studentId, newFile);
    } catch (e) {
      Exceptionerror.snackBarError(
        'Error occurred while updating document URL.',
      );
      return null;
=======
  Future<void> deleteStudent(Student student) async {
    try {
      await studentClient.delete().eq(
        'studentEmail',
        student.studentEmail.toString(),
      );
    } catch (e) {
      Exceptionerror.AlertDialogError(e.toString() as BuildContext);
>>>>>>> 4b24eceff9bab363ab8bc8ea257ccb1be2b340d7
    }
  }
}
