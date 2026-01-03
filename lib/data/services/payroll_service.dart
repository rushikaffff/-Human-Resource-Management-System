import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class PayrollService {
  final ApiService _apiService;

  PayrollService(this._apiService);

  Future<Map<String, dynamic>> getMyPayroll() async {
    final response = await _apiService.get(ApiConstants.myPayroll);
    return response.data;
  }

  Future<Map<String, dynamic>> generatePayroll(int month, int year) async {
    final response = await _apiService.post(ApiConstants.generatePayroll, data: {'month': month, 'year': year});
    return response.data;
  }

  Future<Map<String, dynamic>> getAllPayroll() async {
    final response = await _apiService.get(ApiConstants.allPayroll);
    return response.data;
  }
}
