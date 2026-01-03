import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/logic/providers/attendance_provider.dart';
import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/presentation/widgets/custom_button.dart';


class AttendanceView extends ConsumerWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: Column(
        children: [
           // Check-In / Check-Out Actions
           Container(
             padding: const EdgeInsets.all(16),
             color: Colors.white,
             child: Row(
               children: [
                 Expanded(
                   child: CustomButton(
                     text: 'Check In',
                     onPressed: () async {
                       try {
                         await ref.read(attendanceProvider.notifier).checkIn();
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked In Successfully')));
                       } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                       }
                     },
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: CustomButton(
                     text: 'Check Out',
                     onPressed: () async {
                       try {
                         await ref.read(attendanceProvider.notifier).checkOut();
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked Out Successfully')));
                       } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                       }
                     },
                   ),
                 ),
               ],
             ),
           ),
           
           Expanded(
             child: attendanceAsync.when(
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
                           backgroundColor: _getStatusColor(record.status),
                           child: const Icon(Icons.access_time, color: Colors.white, size: 20),
                         ),
                         title: Text(DateFormat('EEEE, MMM d, y').format(record.date)),
                         subtitle: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('In: ${record.checkIn != null ? DateFormat('hh:mm a').format(record.checkIn!) : '--:--'}'),
                             Text('Out: ${record.checkOut != null ? DateFormat('hh:mm a').format(record.checkOut!) : '--:--'}'),
                           ],
                         ),
                         trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                                Text('${record.workHours} hrs', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(record.status, style: TextStyle(color: _getStatusColor(record.status), fontSize: 12)),
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
           ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present': return Colors.green;
      case 'Absent': return Colors.red;
      case 'Half-day': return Colors.orange;
      case 'Leave': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
