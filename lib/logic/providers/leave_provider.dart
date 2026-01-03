import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/leave_service.dart';
import '../../logic/providers/auth_provider.dart';
import '../../data/models/leave_model.dart';

final leaveServiceProvider = Provider((ref) {
  return LeaveService(ref.watch(apiServiceProvider));
});

final leaveProvider = StateNotifierProvider.autoDispose<LeaveNotifier, AsyncValue<List<Leave>>>((ref) {
  return LeaveNotifier(ref.watch(leaveServiceProvider));
});

class LeaveNotifier extends StateNotifier<AsyncValue<List<Leave>>> {
  final LeaveService _leaveService;

  LeaveNotifier(this._leaveService) : super(const AsyncValue.loading()) {
    getMyLeaves();
  }

  Future<void> getMyLeaves() async {
    try {
      state = const AsyncValue.loading();
      final response = await _leaveService.getMyLeaves();
      final List<dynamic> list = response['data'];
      final leaveList = list.map((e) => Leave.fromJson(e)).toList();
      state = AsyncValue.data(leaveList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> applyLeave(Map<String, dynamic> data) async {
    try {
      await _leaveService.applyLeave(data);
      await getMyLeaves();
    } catch (e) {
      rethrow;
    }
  }
}
