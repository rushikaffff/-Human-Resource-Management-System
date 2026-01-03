import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class EmployeeService {
  final ApiService _apiService;

  EmployeeService(this._apiService);

  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiService.get(ApiConstants.employeeMe);
    return response.data;
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final response = await _apiService.put(ApiConstants.employeeMe, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getEmployees() async {
    final response = await _apiService.get(ApiConstants.allEmployees);
    return response.data;
  }

  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.allEmployees, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateEmployee(String id, Map<String, dynamic> data) async {
    final response = await _apiService.put('${ApiConstants.allEmployees}/$id', data: data);
    return response.data;
  }
}
