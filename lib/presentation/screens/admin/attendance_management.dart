import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dayflow_hrms/logic/providers/admin_provider.dart';


class AttendanceManagementScreen extends ConsumerWidget {
  const AttendanceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(allAttendanceProvider);

     return Scaffold(
      appBar: AppBar(title: const Text('All Attendance')),
      body: attendanceAsync.when(
        data: (attendanceList) {
          if (attendanceList.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final record = attendanceList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(record.status[0]), // Initials
                  ),
                  title: Text(DateFormat('EEEE, MMM d, y').format(record.date)),
                  subtitle: Text('ID: ${record.id}'), // In real app, name should be populated
                  trailing: Text(record.status),
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
}
