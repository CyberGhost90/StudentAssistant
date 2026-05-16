// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/exception_error.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//relevant people should update this to make it useful and test the code- KING
class Repository {
  //Supabase table clients
  final adminClient=Supabase.instance.client.from('admin');
  final studentClient=Supabase.instance.client.from('student');
  final applicationClient=Supabase.instance.client.from('student_applications');

  //Local cache
  Admin? _admin;
  Student? _student;

  //getters
  Admin? get admin => _admin;
  Student? get student => _student;

  //STUDENT
  //Returns all students
  Future<Iterable<Student>> getStudents() async
  {
    try{
      final response=await studentClient.select();
      if(response.isEmpty !=true)
      {
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
    }catch (e){
      Exceptionerror.snackBarError('Error occurred while fetching students.');
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

  //ADMIN
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
        Exceptionerror.snackBarError('Admin not found.');
      }
      return admin;
    } catch (e) {
      Exceptionerror.snackBarError('Error occurred while fetching admin.');
      return admin;
    }
  }

  //Create admin
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

  //Update admin
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

  //Delete admin
  Future<void> deleteAdmin(Admin admin) async {
    try {
      await adminClient.delete().eq('AdminEmail', admin.email.toString());
    } catch (e) {
      Exceptionerror.alertDialogError(e.toString());
    }
  }

  //APPLICATION
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
  Future<bool> createApplication({required String studentId, required int yearOfStudy, required String module1, String? module2, required bool eligibilityConfirmed}) async
  {
    try
    {
      await applicationClient.insert({
        'student_id': studentId,
        'year_Of_Study': yearOfStudy,
        'module_1': module1,
        'module_2': module2,
        'eligibility_Confirmed': eligibilityConfirmed,
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
  Future<bool> updateApplication({required String applicationId, required int yearOfStudy, required String module1, String? module2, required bool eligibilityConfirmed}) async
  {
    try
    {
      final Map<String, dynamic> updates= {};
      if(yearOfStudy!=null) updates['year_Of_Study'];
      if(module1!=null) updates['module_1'];
      updates['module_2'] = module2;
      if(eligibilityConfirmed!=null)
      {
        updates['eligibility_Confirmed']=eligibilityConfirmed;
      }
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
  
  final String? bucketName = 'student-bucket';
  

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
}

  

  
       

  