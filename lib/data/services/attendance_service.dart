import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class AttendanceService {
  final ApiService _apiService;

  AttendanceService(this._apiService);

  Future<Map<String, dynamic>> checkIn() async {
    final response = await _apiService.post(ApiConstants.checkIn);
    return response.data;
  }

  Future<Map<String, dynamic>> checkOut() async {
    final response = await _apiService.post(ApiConstants.checkOut);
    return response.data;
  }

  Future<Map<String, dynamic>> getMyAttendance() async {
    final response = await _apiService.get(ApiConstants.myAttendance);
    return response.data;
  }

  Future<Map<String, dynamic>> getAllAttendance() async {
    final response = await _apiService.get(ApiConstants.allAttendance);
    return response.data;
  }
}
