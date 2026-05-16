import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/routes/route_manager.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';

class ApplicationFormScreen extends StatefulWidget {
  final ApplicationModel? applicationToEdit;

  const ApplicationFormScreen({super.key,this.applicationToEdit});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode=>widget.applicationToEdit !=null;

  final List<int> _yearsOfStudy = [1, 2, 3];
  final Map<int, List<String>> _modulesByYear = {
    1: [
      'IT 1st Year Modules',
      'Computer Literacy Modules',
      'IT Extended Programme (ECP)',
      'Higher Certificate in IT',
      'Open Lab',
    ],
    2: [
      'IT 2nd Year Modules',
      'Computer Literacy Modules',
      'IT Extended Programme (ECP)',
      'Higher Certificate in IT',
      'Open Lab',
    ],
    3: [
      'IT 1st Year Modules',
      'IT 2nd Year Modules',
      'Computer Literacy Modules',
      'IT Extended Programme (ECP)',
      'Higher Certificate in IT',
      'Open Lab',
    ],
  };

  @override
  void initState() {
    super.initState();
    // Pre-populate fields when editing
    if (_isEditMode) {
      final app = widget.applicationToEdit!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<StudentViewModel>();
        vm.setYearOfStudy(app.yearOfStudy);
        vm.setModule1(app.module1);
        vm.setModule2(app.module2);
        vm.setEligibilityConfirmed(app.eligibilityConfirmed);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode? 'Edit Application' : 'Student Assistant Application'),backgroundColor: Colors.indigo,foregroundColor: Colors.white,),
      body: Consumer<StudentViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Personal Information
                  _SectionCard(
                    title: 'Personal Information',
                    child: DropdownButtonFormField<int>(
                      initialValue: viewModel.yearOfStudy,
                      decoration: const InputDecoration(
                        labelText: 'Year of Study *',
                        border: OutlineInputBorder(),
                      ),
                      items: _yearsOfStudy
                          .map((y) => DropdownMenuItem(
                              value: y, child: Text('Year $y')))
                          .toList(),
                      onChanged: (v) {
                        viewModel.setYearOfStudy(v);
                        viewModel.setModule1(null);
                        viewModel.setModule2(null);
                      },
                      validator: viewModel.validateYearOfStudy,
                    ),
                  ),
                  //Module 1
                  _SectionCard(
                    title: 'First Module Selection *',
                    child: DropdownButtonFormField<String>(
                      initialValue: viewModel.module1,
                      decoration: const InputDecoration(
                        labelText: 'Module 1',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.yearOfStudy != null
                          ? (_modulesByYear[viewModel.yearOfStudy] ?? [])
                              .map((m) => DropdownMenuItem(
                                  value: m, child: Text(m)))
                              .toList()
                          : [],
                      onChanged: viewModel.setModule1,
                      validator: viewModel.validateModule1,
                      hint: viewModel.yearOfStudy == null
                          ? const Text('Select year of study first')
                          : null,
                    ),
                  ),
                  //Module 2(optional)
                  _SectionCard(
                    title: 'Second Module (Optional)',
                    child: ExpansionTile(
                      title: const Text('Add a second module'),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: viewModel.module2,
                          decoration: const InputDecoration(
                            labelText: 'Module 2',
                            border: OutlineInputBorder(),
                          ),
                          items: viewModel.yearOfStudy != null
                              ? (_modulesByYear[viewModel.yearOfStudy] ?? [])
                                  .where((m) => m != viewModel.module1)
                                  .map((m) => DropdownMenuItem(
                                      value: m, child: Text(m)))
                                  .toList()
                              : [],
                          onChanged: viewModel.setModule2,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  //Eligibility and Documentation
                   _SectionCard(
                    title: 'Eligibility & Documentation',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Required documents from the 2026 vacancy notice:\n'
                          '• CV  • Certified ID  • Grade 12 Certificate\n'
                          '• Academic Record  • Proof of Registration\n'
                          '• Cover Letter  • Not appointed at CUT/IT',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),

                        FormField<bool>(
                          initialValue: viewModel.eligibilityConfirmed,
                          validator: viewModel.validateEligibility,
                          builder: (field) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                value: field.value ?? false,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (val) {
                                  field.didChange(val);
                                  viewModel
                                      .setEligibilityConfirmed(val ?? false);
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: const Text(
                                  'I confirm I meet the eligibility requirements *',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              if (field.errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(field.errorText!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12)),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );
                            if (result != null && result.files.single.path != null) {
                              viewModel.setSupportingDocument(
                                  File(result.files.single.path!));
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            viewModel.supportingDocument != null
                                ? '✓ ${viewModel.supportingDocument!.path.split('/').last}'
                                : 'Upload Supporting Documents (PDF)',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                viewModel.supportingDocument != null
                                    ? Colors.green
                                    : Colors.indigo,
                            side: BorderSide(
                              color: viewModel.supportingDocument != null
                                  ? Colors.green
                                  : Colors.indigo,
                            ),
                          ),
                        ),

                        if (viewModel.supportingDocument == null &&
                            viewModel.eligibilityConfirmed)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Please upload your supporting documents.',
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  //Error message

                  if (viewModel.errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                    //Submit/ update button
                    SizedBox(
                      width:double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () async {
                          if (!_formKey.currentState!.validate()) return;
                          bool success; 
                          if (_isEditMode) 
                          {
                            success=await viewModel.updateApplication(
                              widget.applicationToEdit!.id,
                              yearOfStudy: viewModel.yearOfStudy,
                              module1: viewModel.module1,
                              module2: viewModel.module2,
                              eligibilityConfirmed: viewModel.eligibilityConfirmed
                              );
                          } else {
                            success=await viewModel.submitApplication();
                          }

                          if(!mounted) return;
                          if(success){
                            viewModel.resetForm();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isEditMode ? 'Application updated successfully!' : 'Application submitted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacementNamed(context,RouteManager.studHome);
                          }else if(viewModel.errorMessage != null)
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(viewModel.errorMessage!),
                                backgroundColor: Colors.red,
                              )
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: viewModel.isLoading
                          ? const SizedBox(
                            height: 20, 
                            width:20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth:2))
                          : Text(
                            _isEditMode
                            ? 'Update Application'
                            : 'Submit Application',
                            style: const TextStyle(fontSize:16)),
                    ),
                  ),
                  const SizedBox(height:24)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
