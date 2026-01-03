import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/payroll_service.dart';
import '../../logic/providers/auth_provider.dart';
import '../../data/models/salary_model.dart';

final payrollServiceProvider = Provider((ref) {
  return PayrollService(ref.watch(apiServiceProvider));
});

final payrollProvider = StateNotifierProvider.autoDispose<PayrollNotifier, AsyncValue<List<Salary>>>((ref) {
  return PayrollNotifier(ref.watch(payrollServiceProvider));
});

class PayrollNotifier extends StateNotifier<AsyncValue<List<Salary>>> {
  final PayrollService _payrollService;

  PayrollNotifier(this._payrollService) : super(const AsyncValue.loading()) {
    getMyPayroll();
  }

  Future<void> getMyPayroll() async {
    try {
      state = const AsyncValue.loading();
      final response = await _payrollService.getMyPayroll();
      final List<dynamic> list = response['data'];
      final payrollList = list.map((e) => Salary.fromJson(e)).toList();
      state = AsyncValue.data(payrollList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
