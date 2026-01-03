import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/employee_service.dart';
import '../../data/services/api_service.dart';
import '../../logic/providers/auth_provider.dart';
import '../../data/models/employee_model.dart';
import 'package:dio/dio.dart';

final employeeServiceProvider = Provider((ref) {
  return EmployeeService(ref.watch(apiServiceProvider));
});

final employeeProfileProvider = StateNotifierProvider<EmployeeProfileNotifier, AsyncValue<Employee?>>((ref) {
  return EmployeeProfileNotifier(ref.watch(employeeServiceProvider));
});

class EmployeeProfileNotifier extends StateNotifier<AsyncValue<Employee?>> {
  final EmployeeService _employeeService;

  EmployeeProfileNotifier(this._employeeService) : super(const AsyncValue.loading()) {
    getMe();
  }

  Future<void> getMe() async {
    try {
      state = const AsyncValue.loading();
      // Service returns { success: true, data: {...} }
      final response = await _employeeService.getMe();
      final employee = Employee.fromJson(response['data']);
      state = AsyncValue.data(employee);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMe(Map<String, dynamic> data) async {
    try {
        final response = await _employeeService.updateMe(data);
        final employee = Employee.fromJson(response['data']);
        state = AsyncValue.data(employee);
    } catch (e) {
        throw e;
    }
  }
}
