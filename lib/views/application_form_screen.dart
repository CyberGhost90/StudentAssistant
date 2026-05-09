import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:student_assistant/viewmodels/student_view_model.dart'; // Updated import

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<int> _yearsOfStudy = [1, 2, 3];
  final Map<int, List<String>> _modulesByYear = {
    1: ['Introduction to Programming', 'Database Fundamentals'],
    2: ['Object-Oriented Design', 'Web Development Basics'],
    3: ['Advanced Algorithms', 'Mobile Application Development'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Assistant Application')),
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
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16.0),
                          DropdownButtonFormField<int>(
                            value: viewModel.yearOfStudy,
                            decoration: const InputDecoration(
                              labelText: 'Year of Study',
                              border: OutlineInputBorder(),
                            ),
                            items: _yearsOfStudy.map((year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text('Year $year'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              viewModel.setYearOfStudy(value);
                              viewModel.setModule1(null);
                              viewModel.setModule2(null);
                            },
                            validator: viewModel.validateYearOfStudy,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'First Module Selection',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16.0),
                          DropdownButtonFormField<String>(
                            value: viewModel.module1,
                            decoration: const InputDecoration(
                              labelText: 'Module 1',
                              border: OutlineInputBorder(),
                            ),
                            items: viewModel.yearOfStudy != null
                                ? _modulesByYear[viewModel.yearOfStudy]!.map((
                                    module,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: module,
                                      child: Text(module),
                                    );
                                  }).toList()
                                : [],
                            onChanged: viewModel.setModule1,
                            validator: viewModel.validateModule1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ExpansionTile(
                        title: const Text('Second Module Selection (Optional)'),
                        children: [
                          DropdownButtonFormField<String>(
                            value: viewModel.module2,
                            decoration: const InputDecoration(
                              labelText: 'Module 2',
                              border: OutlineInputBorder(),
                            ),
                            items: viewModel.yearOfStudy != null
                                ? _modulesByYear[viewModel.yearOfStudy]!.map((
                                    module,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: module,
                                      child: Text(module),
                                    );
                                  }).toList()
                                : [],
                            onChanged: viewModel.setModule2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Eligibility & Documentation',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16.0),
                          FormField<bool>(
                            initialValue: viewModel.eligibilityConfirmed,
                            validator: (value) =>
                                viewModel.validateEligibility(value),
                            builder: (field) {
                              return CheckboxListTile(
                                value: field.value ?? false,
                                onChanged: (val) {
                                  field.didChange(val);
                                  viewModel.setEligibilityConfirmed(val!);
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                subtitle: field.errorText != null
                                    ? Text(
                                        field.errorText!,
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton.icon(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf'],
                                  );
                              if (result != null &&
                                  result.files.single.path != null) {
                                viewModel.setSupportingDocument(
                                  File(result.files.single.path!),
                                );
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              viewModel.supportingDocument != null
                                  ? 'Document Selected: ${viewModel.supportingDocument!.path.split('/').last}'
                                  : 'Upload Supporting Document (PDF)',
                            ),
                          ),
                          if (viewModel.supportingDocument == null &&
                              viewModel.eligibilityConfirmed)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Please upload a supporting document.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  Center(
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                bool success = await viewModel
                                    .submitApplication();
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Application submitted successfully!',
                                      ),
                                    ),
                                  );
                                } else if (viewModel.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(viewModel.errorMessage!),
                                    ),
                                  );
                                }
                              }
                            },
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Application'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
