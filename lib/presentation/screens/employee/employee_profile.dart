import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayflow_hrms/logic/providers/employee_provider.dart';
import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/presentation/widgets/custom_button.dart';
import 'package:dayflow_hrms/presentation/widgets/custom_textfield.dart';


class EmployeeProfileScreen extends ConsumerStatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  ConsumerState<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends ConsumerState<EmployeeProfileScreen> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;
  
  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeAsync = ref.watch(employeeProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: employeeAsync.when(
        data: (employee) {
          if (employee == null) return const Center(child: Text('No Data'));

          // Initialize controllers if not editing to keep them in sync
          if (!_isEditing) {
            _phoneController.text = employee.phone;
            _addressController.text = employee.address ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                const SizedBox(height: 16),
                Text('${employee.firstName} ${employee.lastName}', style: Theme.of(context).textTheme.headlineSmall),
                Text(employee.designation, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),
                
                _buildInfoTile('Email', employee.email, Icons.email),
                _buildInfoTile('Department', employee.department, Icons.business),
                
                const Divider(height: 32),
                
                // Editable Fields
                if (_isEditing) ...[
                     CustomTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                     CustomTextField(
                        controller: _addressController,
                        label: 'Address',
                        prefixIcon: const Icon(Icons.home),
                    ),
                    const SizedBox(height: 24),
                    Row(
                        children: [
                            Expanded(child: CustomButton(
                                text: 'Cancel', 
                                onPressed: () => setState(() => _isEditing = false))),
                            const SizedBox(width: 16),
                            Expanded(child: CustomButton(
                                text: 'Save', 
                                onPressed: () async {
                                    await ref.read(employeeProfileProvider.notifier).updateMe({
                                        'phone': _phoneController.text,
                                        'address': _addressController.text
                                    });
                                    setState(() => _isEditing = false);
                                }
                            )),
                        ],
                    )
                ] else ...[
                     _buildInfoTile('Phone', employee.phone, Icons.phone),
                     _buildInfoTile('Address', employee.address ?? 'N/A', Icons.home),
                     const SizedBox(height: 24),
                     CustomButton(text: 'Edit Profile', onPressed: () => setState(() => _isEditing = true)),
                ]
              ],
            ),
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.deepNavy),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
