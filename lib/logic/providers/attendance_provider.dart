import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/attendance_service.dart';
import '../../logic/providers/auth_provider.dart';
import '../../data/models/attendance_model.dart';

final attendanceServiceProvider = Provider((ref) {
  return AttendanceService(ref.watch(apiServiceProvider));
});

final attendanceProvider = StateNotifierProvider.autoDispose<AttendanceNotifier, AsyncValue<List<Attendance>>>((ref) {
  return AttendanceNotifier(ref.watch(attendanceServiceProvider));
});

class AttendanceNotifier extends StateNotifier<AsyncValue<List<Attendance>>> {
  final AttendanceService _attendanceService;

  AttendanceNotifier(this._attendanceService) : super(const AsyncValue.loading()) {
    getMyAttendance();
  }

  Future<void> getMyAttendance() async {
    try {
      state = const AsyncValue.loading();
      final response = await _attendanceService.getMyAttendance();
      final List<dynamic> list = response['data'];
      final attendanceList = list.map((e) => Attendance.fromJson(e)).toList();
      state = AsyncValue.data(attendanceList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> checkIn() async {
    try {
      await _attendanceService.checkIn();
      await getMyAttendance(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkOut() async {
    try {
      await _attendanceService.checkOut();
      await getMyAttendance(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }
}
