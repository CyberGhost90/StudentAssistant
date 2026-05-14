// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../viewmodels/admin_dashboard_viewmodel.dart';
// import '../widgets/loading_widget.dart';
// import '../widgets/error_widget.dart';
// import '../widgets/status_chip.dart';
// import '../utils/constants.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await context.read<AdminDashboardViewModel>().loadApplications();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//         centerTitle: false,
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => _loadData(),
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: Consumer<AdminDashboardViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading && viewModel.applications.isEmpty) {
//             return const LoadingWidget(message: 'Loading applications...');
//           }

//           if (viewModel.error != null) {
//             return ErrorMessageWidget(
//               message: viewModel.error!,
//               onRetry: () => _loadData(),
//             );
//           }

//           return Column(
//             children: [
//               // Stats Cards
//               _buildStatsRow(viewModel),
              
//               // Filters
//               _buildFilters(viewModel),
              
//               // Applications List
//               Expanded(
//                 child: viewModel.applications.isEmpty
//                     ? const Center(child: Text('No applications found'))
//                     : RefreshIndicator(
//                         onRefresh: () => _loadData(),
//                         child: ListView.builder(
//                           padding: const EdgeInsets.all(8),
//                           itemCount: viewModel.applications.length,
//                           itemBuilder: (context, index) {
//                             final application = viewModel.applications[index];
//                             return _buildApplicationCard(viewModel, application);
//                           },
//                         ),
//                       ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatsRow(AdminDashboardViewModel viewModel) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           _buildStatCard(
//             'Pending',
//             viewModel.pendingCount,
//             Colors.orange,
//           ),
//           const SizedBox(width: 12),
//           _buildStatCard(
//             'Approved',
//             viewModel.approvedCount,
//             Colors.green,
//           ),
//           const SizedBox(width: 12),
//           _buildStatCard(
//             'Rejected',
//             viewModel.rejectedCount,
//             Colors.red,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, int count, Color color) {
//     return Expanded(
//       child: Card(
//         color: color.withOpacity(0.1),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Text(
//                 count.toString(),
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilters(AdminDashboardViewModel viewModel) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Filters',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 const Text('Status: ', style: TextStyle(fontSize: 12)),
//                 ...viewModel.getFilterStatuses().map((status) {
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: FilterChip(
//                       label: Text(status),
//                       selected: viewModel.statusFilter == status,
//                       onSelected: (_) => viewModel.setStatusFilter(status),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 const Text('Level: ', style: TextStyle(fontSize: 12)),
//                 ...viewModel.getFilterLevels().map((level) {
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: FilterChip(
//                       label: Text(level),
//                       selected: viewModel.levelFilter == level,
//                       onSelected: (_) => viewModel.setLevelFilter(level),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplicationCard(AdminDashboardViewModel viewModel, application) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ExpansionTile(
//         leading: StatusChip(status: application.status, compact: true),
//         title: Text(
//           application.module1Name,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text('Student Year: ${application.studentYear}'),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDetailRow('Primary Module', '${application.module1Level} - ${application.module1Name}'),
//                 if (application.module2Name != null)
//                   _buildDetailRow('Secondary Module', '${application.module2Level} - ${application.module2Name}'),
//                 _buildDetailRow('Submitted', _formatDate(application.submittedAt)),
//                 const Divider(),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (application.status == AppConstants.statusPending) ...[
//                       ElevatedButton.icon(
//                         onPressed: () => _confirmAction(viewModel, application.id, true),
//                         icon: const Icon(Icons.check, size: 18),
//                         label: const Text('Approve'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       ElevatedButton.icon(
//                         onPressed: () => _confirmAction(viewModel, application.id, false),
//                         icon: const Icon(Icons.close, size: 18),
//                         label: const Text('Reject'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                     const SizedBox(width: 12),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _confirmDelete(viewModel, application.id),
//                       tooltip: 'Delete',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   void _confirmAction(AdminDashboardViewModel viewModel, String id, bool approve) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(approve ? 'Approve Application' : 'Reject Application'),
//         content: Text('Are you sure you want to ${approve ? 'approve' : 'reject'} this application?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(ctx);
//               await viewModel.updateApplicationStatus(id, approve);
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Application ${approve ? 'approved' : 'rejected'}'),
//                     backgroundColor: approve ? Colors.green : Colors.orange,
//                   ),
//                 );
//               }
//             },
//             child: Text(
//               approve ? 'Approve' : 'Reject',
//               style: TextStyle(color: approve ? Colors.green : Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmDelete(AdminDashboardViewModel viewModel, String id) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete Application'),
//         content: const Text('Are you sure you want to delete this application?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(ctx);
//               await viewModel.deleteApplication(id);
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Application deleted')),
//                 );
//               }
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }