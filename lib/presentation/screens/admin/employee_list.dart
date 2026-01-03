import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayflow_hrms/logic/providers/admin_provider.dart';
import 'package:dayflow_hrms/logic/providers/employee_provider.dart';
import 'package:dayflow_hrms/config/theme.dart';


class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(allEmployeesProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.darkestNavy,
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: AppTheme.softBlue),
                  const SizedBox(height: 16),
                  const Text(
                    'No employees yet',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click + to add your first employee',
                    style: TextStyle(color: AppTheme.lightBlue, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final emp = employees[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: AppTheme.deepNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.steelBlue.withOpacity(0.3)),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 12,
                  ),
                  leading: CircleAvatar(
                    radius: isMobile ? 20 : 24,
                    backgroundColor: AppTheme.softBlue,
                    child: Text(
                      emp.firstName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    '${emp.firstName} ${emp.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        emp.designation,
                        style: TextStyle(color: AppTheme.lightBlue, fontSize: 13),
                      ),
                      if (!isMobile && emp.department.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          emp.department,
                          style: TextStyle(color: AppTheme.softBlue, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  trailing: isMobile
                      ? null
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.steelBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            emp.department,
                            style: TextStyle(color: AppTheme.lightBlue, fontSize: 12),
                          ),
                        ),
                ),
              );
            },
          );
        },
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Error loading employees',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: TextStyle(color: AppTheme.lightBlue, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.softBlue),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEmployeeDialog(context, ref),
        backgroundColor: AppTheme.steelBlue,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context, WidgetRef ref) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final designationController = TextEditingController();
    final departmentController = TextEditingController();
    final salaryController = TextEditingController();
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add New Employee',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 8),
              Text(
                'Login ID will be auto-generated',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              
              // Employee Info
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(labelText: 'First Name *'))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name *'))),
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone *')),
              const SizedBox(height: 12),
              TextField(
                  controller: designationController,
                  decoration: const InputDecoration(labelText: 'Designation *')),
              const SizedBox(height: 12),
              TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department *')),
              const SizedBox(height: 12),
              TextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Base Salary *')),
              const SizedBox(height: 12),
              TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  try {
                    // Validate basic fields
                    if (firstNameController.text.trim().isEmpty ||
                        lastNameController.text.trim().isEmpty ||
                        phoneController.text.trim().isEmpty ||
                        designationController.text.trim().isEmpty ||
                        departmentController.text.trim().isEmpty ||
                        salaryController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    final data = {
                      'firstName': firstNameController.text.trim(),
                      'lastName': lastNameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'designation': designationController.text.trim(),
                      'department': departmentController.text.trim(),
                      'baseSalary': double.tryParse(salaryController.text) ?? 0,
                      'address': addressController.text.trim(),
                      'dateOfJoining': DateTime.now().toIso8601String(),
                    };

                    final response = await ref
                        .read(employeeServiceProvider)
                        .createEmployee(data);

                    ref.invalidate(allEmployeesProvider); // Refresh list
                    if (context.mounted) Navigator.pop(context); // Close dialog

                    // Show success with login credentials
                    if (context.mounted && response['loginCredentials'] != null) {
                      final creds = response['loginCredentials'];
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Employee Created!'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Share these credentials with the employee:'),
                              const SizedBox(height: 16),
                              Text('Login ID: ${creds['loginId']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Password: ${creds['password']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              const Text('Note: Employee should change password on first login.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $e')),
                      );
                    }
                  }
                },
                child: const Text('Create Employee'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
