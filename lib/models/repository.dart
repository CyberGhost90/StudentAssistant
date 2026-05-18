import 'package:flutter/material.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//relevant people should update this to make it useful and test the code- KING
class Repository {
  //Supabase table clients
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');

  //Local cache
  Admin? _admin;
  Student? _student;
  final adminClient = Supabase.instance.client.from('admin');
  final studentClient = Supabase.instance.client.from('student');
  //getters
  Admin? get admin => _admin;
  Student? get student => _student;

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
  Future<Iterable<Student>> getStudents() async {
    try {
      final response = await studentClient.select();
      if (response.isEmpty != true) {
        return (response as List).map(
          (e)=>Student(
            firstName: e['FirstName'],
            surname: e['Surname'],
            studentEmail: e['studentEmail'],
            yearOfStudy: e['yearOfStudy'],
            password: e['password'],
          )
        );
      }else{
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

  //Return one student
  Future<Student> getStudent(Student student) async{
    try
    {
      final response = await studentClient.select().eq('email',student.studentEmail.toString()).single();
      if(response.isEmpty ==false)
      {
        _student= Student(
          studentEmail: response['studentEmail'],
          password: response['password'],
          firstName: response['FirstName'],
          surname: response['Surname'],
          yearOfStudy: response['yearOfStudy'],
        );
      }else{
        Exceptionerror.snackBarError('Student not found.');
      }
      return student;
    }catch (e){
      Exceptionerror.snackBarError('Error occured while fetching student.');
      return student;
    }
  }

  //Create student
  Future<Student> createStudent(Student student) async
  {
    try{
      await studentClient.insert({
        'studentEmail' : student.studentEmail,
        'password' : student.password,
        'FirstName' : student.firstName,
        'Surname' : student.surname,
      });
      _student=student;
      return student;
    }catch (e){
      Exceptionerror.alertDialogError(e.toString());
      return student;
    }
  }

  //Update student
  Future<void> updateStudent(Student student) async
  {
    try{
      await studentClient.update({
        'studentEmail' : student.studentEmail,
        'password' : student.password,
        'FirstName' : student.firstName,
        'Surname' : student.surname,
      }).eq('studentEmail', student.studentEmail.toString());
      _student=student;
    }catch (e){
      Exceptionerror.alertDialogError(e.toString());
    }
  }

  //Delete student
  Future<void> deleteStudent(Student student) async
  {
    try{
      await studentClient.delete().eq('studentEmail', student.studentEmail.toString());
    }catch (e){
      Exceptionerror.alertDialogError(e.toString());
    }
  }

  //-------------------------ADMIN-------------------------
  //Return 1 admin
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

  //Create admin
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

  //Update admin
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
      Exceptionerror.snackBarError('Error occurred while updating admin.');
    }
  }

  //Delete admin
  Future<void> deleteAdmin(Admin admin) async {
    try {
      await adminClient.delete().eq('AdminEmail', admin.email.toString());
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
    }
  }

  //-------------------------APPLICATION--------------------------

  //Get all applications for one student (scoped by userId)
  Future<List<ApplicationModel>> getApplicationForStudent(String studentId) async
  {
    try
    {
      final response= await applicationClient.select().eq('student_id', studentId).order('submission_date',ascending: false);
      return (response as List).map((e)=>ApplicationModel.fromJson(e)).toList();
    }on PostgrestException catch (e){
      Exceptionerror.snackBarError('Failed to load applications: ${e.message}.');
      return [];
    }catch (e){
      Exceptionerror.snackBarError('Unexpected error loading applications.');
      return [];
    }
  }

  //Get all applications (admin use only)
  Future<List<ApplicationModel>> getAllApplications(String studentId) async
  {
    try
    {
      final response= await applicationClient.select().order('submission_date',ascending: false);
      return (response as List).map((e)=>ApplicationModel.fromJson(e)).toList();
    }on PostgrestException catch (e){
      Exceptionerror.snackBarError('Failed to load applications: ${e.message}.');
      return [];
    }catch (e){
      Exceptionerror.snackBarError('Unexpected error loading applications.');
      return [];
    }
  }

  //Check if student already has an application
  Future<bool> studentHasApplication(String studentId) async
  {
    try
    {
      final response= await applicationClient.select().eq('student_id', studentId).limit(1);
      return (response as List).isNotEmpty;
    }catch (e){
      Exceptionerror.snackBarError('Unexpected error loading applications.');
      return false;
    }
  }

  //Create- submit a new application (no file storage)
  Future<bool> createApplication({required String studentId, required int yearOfStudy, required String module1, String? module2, required bool eligibilityConfirmed, String? documentUrl}) async
  {
    try
    {
      await applicationClient.insert({
        'student_id': studentId,
        'year_of_Study': yearOfStudy,
        'module_1': module1,
        'module_2': module2,
        'eligibility_confirmed': eligibilityConfirmed,
        'supporting_document_url' : documentUrl,
        'submission_date': DateTime.now().toIso8601String(),
        'status': 'pending'
      });
      return true;
    }on PostgrestException catch (e){
      Exceptionerror.snackBarError('Submission failed: ${e.message}.');
      return false;
    }catch (e){
      Exceptionerror.snackBarError('Unexpected error during submission.');
      return false;
    }
  }

  //Edit a pending application's fields
  Future<bool> updateApplication({required String applicationId, required int? yearOfStudy, required String? module1, String? module2, required bool? eligibilityConfirmed, String? documentUrl}) async
  {
    try
    {
      final Map<String, dynamic> updates= {};
      if(yearOfStudy!=null) updates['year_of_study'];
      if(module1!=null) updates['module_1'];
      updates['module_2'] = module2;
      if(eligibilityConfirmed!=null) updates['eligibility_confirmed']=eligibilityConfirmed;
      if(documentUrl !=null) updates['supporting_document_url'] = documentUrl;
      
      await applicationClient.update(updates).eq('id', applicationId);
      return true;
    }on PostgrestException catch (e){
      Exceptionerror.snackBarError('Update failed: ${e.message}.');
      return false;
    }catch (e){
      Exceptionerror.snackBarError('Unexpected error during update.');
      return false;
    }
  }

  //Change application status(admin only)
  Future<bool> updateApplicationStatus({required String applicationId, required String newStatus}) async
  {
    try
    {
      await applicationClient.update({'status': newStatus}).eq('id',applicationId);
      return true;
    }on PostgrestException catch (e)
    {
      Exceptionerror.snackBarError('Status update failed: ${e.message}.');
      return false;
    }catch (e)
    {
      Exceptionerror.snackBarError('Unexpected error updating status.');
      return false;
    }
    
  }

  //Delete an application record
  Future<bool> deleteApplication(String applicationId) async
  {
    try
    {
      await applicationClient.delete().eq('id',applicationId);
      return true;
    }on PostgrestException catch (e)
    {
      Exceptionerror.snackBarError('Delete failed: ${e.message}.');
      return false;
    }catch (e)
    {
      Exceptionerror.snackBarError('Unexpected error updating delete.');
      return false;
    }
    
  }

  //-------------------------DOCUMENT STORAGE--------------------------
  final String bucketName='student-bucket';

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
      final fileName ='${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$studentId/$fileName';
    
      await Supabase.instance.client.storage.from(bucketName).upload(path,file,fileOptions: const FileOptions(upsert: true));
      
      //Return public URL to be stored in student_applications table
      return Supabase.instance.client.storage.from(bucketName).getPublicUrl(path);
    } on StorageException catch (e) {
     Exceptionerror.snackBarError('Upload failed: ${e.message}');
     return null;
    }catch (e){
       Exceptionerror.snackBarError('Error occurred while uploading documents.');
      return null;
    }
  }

  //Delete student document from storage
  Future<void> deleteStudentDocs(String filePath) async {
    try {
      await Supabase.instance.client.storage.from(bucketName).remove([filePath]);
    }on StorageException catch (e) {
     Exceptionerror.snackBarError('Delete failed: ${e.message}');
    }catch (e) {
      Exceptionerror.alertDialogError('Error occurred while deleting documents.',
      );
    }
  }

  //Replace an existing document with a new one
  Future<String?> updateStudentDocs(String studentId, String oldPath) async {
    try {
      final newFile = await pickStudentDocs();
      if (newFile == null) return null;
      await deleteStudentDocs(oldPath);
      return await uploadStudentDocs(studentId,newFile);
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while updating document URL.',);
      return null;
    }
  }
}
