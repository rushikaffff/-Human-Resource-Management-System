import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/logic/providers/admin_provider.dart';
import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/presentation/widgets/custom_button.dart';


class LeaveApprovalScreen extends ConsumerWidget {
  const LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leavesAsync = ref.watch(adminLeaveProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: leavesAsync.when(
        data: (leaves) {
          if (leaves.isEmpty) return const Center(child: Text('No leave requests.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              final leave = leaves[index];
              return Card(
                color: leave.status == 'Pending' ? Colors.white : Colors.grey[100],
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
                      // We need employee name here but the model might need update if it's just ID in some contexts
                      // Assuming backend populates employee object, but our model expects top level fields. 
                      // For now simpler UI.
                      Text('Duration: ${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d').format(leave.endDate)}'),
                      const SizedBox(height: 8),
                      Text('Reason: ${leave.reason}'),
                      
                      if (leave.status == 'Pending') ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ref.read(adminLeaveProvider.notifier).updateStatus(leave.id, 'Rejected', 'Rejected by HR');
                                },
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  ref.read(adminLeaveProvider.notifier).updateStatus(leave.id, 'Approved', 'Approved by HR');
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        )
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

   Color _getStatusColor(String status) {
      if (status == 'Approved') return Colors.green;
      if (status == 'Rejected') return Colors.red;
      return Colors.orange;
  }
}
