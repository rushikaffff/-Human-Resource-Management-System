import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class LeaveService {
  final ApiService _apiService;

  LeaveService(this._apiService);

  Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.applyLeave, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getMyLeaves() async {
    final response = await _apiService.get(ApiConstants.myLeaves);
    return response.data;
  }

  Future<Map<String, dynamic>> getAllLeaves() async {
    final response = await _apiService.get(ApiConstants.allLeaves);
    return response.data;
  }

  Future<Map<String, dynamic>> updateLeaveStatus(String id, String status, String comments) async {
    final response = await _apiService.put(
      '${ApiConstants.allLeaves}/$id/status',
      data: {'status': status, 'adminComments': comments}
    );
    return response.data;
  }
}
