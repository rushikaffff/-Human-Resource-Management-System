import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/logic/providers/leave_provider.dart';
import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/presentation/widgets/custom_button.dart';
import 'package:dayflow_hrms/presentation/widgets/custom_textfield.dart';


class LeaveApplicationScreen extends ConsumerStatefulWidget {
  const LeaveApplicationScreen({super.key});

  @override
  ConsumerState<LeaveApplicationScreen> createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends ConsumerState<LeaveApplicationScreen> {
  final _reasonController = TextEditingController();
  String _leaveType = 'Sick';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final leaveAsync = ref.watch(leaveProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showApplyLeaveSheet,
        child: const Icon(Icons.add),
      ),
      body: leaveAsync.when(
        data: (leaves) {
          if (leaves.isEmpty) return const Center(child: Text('No leave history'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              final leave = leaves[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(leave.leaveType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Chip(
                            label: Text(leave.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: _getStatusColor(leave.status),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d').format(leave.endDate)}'),
                      const SizedBox(height: 8),
                      Text(leave.reason, style: TextStyle(color: Colors.grey[600])),
                      if (leave.adminComments != null) ...[
                          const Divider(),
                          Text('Admin: ${leave.adminComments}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showApplyLeaveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply for Leave', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _leaveType,
              decoration: const InputDecoration(labelText: 'Leave Type'),
              items: ['Sick', 'Casual', 'Annual', 'Unpaid'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _leaveType = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030), initialDate: DateTime.now());
                      if (date != null) setState(() => _startDate = date);
                    },
                    child: Text(_startDate == null ? 'Start Date' : DateFormat('MMM d').format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030), initialDate: DateTime.now());
                      if (date != null) setState(() => _endDate = date);
                    },
                    child: Text(_endDate == null ? 'End Date' : DateFormat('MMM d').format(_endDate!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _reasonController, label: 'Reason', hint: 'Why do you need leave?'),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Submit Application',
              onPressed: () async {
                if (_startDate == null || _endDate == null || _reasonController.text.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                   return;
                }
                
                try {
                  await ref.read(leaveProvider.notifier).applyLeave({
                    'leaveType': _leaveType,
                    'startDate': _startDate!.toIso8601String(),
                    'endDate': _endDate!.toIso8601String(),
                    'reason': _reasonController.text
                  });
                  Navigator.pop(context);
                  _reasonController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
      if (status == 'Approved') return Colors.green;
      if (status == 'Rejected') return Colors.red;
      return Colors.orange;
  }
}
