import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/employee_model.dart';
import '../../data/models/leave_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/salary_model.dart';

import 'employee_provider.dart';
import 'attendance_provider.dart';
import 'leave_provider.dart';
import 'payroll_provider.dart';

/// ===============================
/// ADMIN – EMPLOYEE LIST
/// ===============================
final allEmployeesProvider =
    FutureProvider.autoDispose<List<Employee>>((ref) async {
  final service = ref.watch(employeeServiceProvider);
  final response = await service.getEmployees();

  return (response['data'] as List)
      .map((e) => Employee.fromJson(e))
      .toList();
});

/// ===============================
/// ADMIN – ATTENDANCE
/// ===============================
final allAttendanceProvider =
    FutureProvider.autoDispose<List<Attendance>>((ref) async {
  final service = ref.watch(attendanceServiceProvider);
  final response = await service.getAllAttendance();

  return (response['data'] as List)
      .map((e) => Attendance.fromJson(e))
      .toList();
});

/// ===============================
/// ADMIN – LEAVE MANAGEMENT
/// ===============================
final adminLeaveProvider = StateNotifierProvider.autoDispose<
    AdminLeaveNotifier, AsyncValue<List<Leave>>>((ref) {
  return AdminLeaveNotifier(ref);
});

class AdminLeaveNotifier extends StateNotifier<AsyncValue<List<Leave>>> {
  final Ref ref;

  AdminLeaveNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchAllLeaves();
  }

  Future<void> fetchAllLeaves() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(leaveServiceProvider);
      final response = await service.getAllLeaves();

      final leaves = (response['data'] as List)
          .map((e) => Leave.fromJson(e))
          .toList();

      state = AsyncValue.data(leaves);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(
    String id,
    String status,
    String comments,
  ) async {
    final service = ref.read(leaveServiceProvider);
    await service.updateLeaveStatus(id, status, comments);
    await fetchAllLeaves(); // refresh
  }
}

/// ===============================
/// ADMIN – PAYROLL
/// ===============================
final adminPayrollProvider = StateNotifierProvider.autoDispose<
    AdminPayrollNotifier, AsyncValue<List<Salary>>>((ref) {
  return AdminPayrollNotifier(ref);
});

class AdminPayrollNotifier extends StateNotifier<AsyncValue<List<Salary>>> {
  final Ref ref;

  AdminPayrollNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchAllPayroll();
  }

  Future<void> fetchAllPayroll() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(payrollServiceProvider);
      final response = await service.getAllPayroll();

      final payroll = (response['data'] as List)
          .map((e) => Salary.fromJson(e))
          .toList();

      state = AsyncValue.data(payroll);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generate(int month, int year) async {
    final service = ref.read(payrollServiceProvider);
    await service.generatePayroll(month, year);
    await fetchAllPayroll();
  }
}
