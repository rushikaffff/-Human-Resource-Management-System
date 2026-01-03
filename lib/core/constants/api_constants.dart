class ApiConstants {
  // Using LAN IP 192.168.0.108 - Best for Physical Devices & Emulators
  static const String baseUrl = 'http://192.168.0.108:5000/api'; 
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator specific
  // static const String baseUrl = 'http://localhost:5000/api'; // Web only

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  static const String employeeMe = '/employees/me';
  static const String allEmployees = '/employees';

  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String myAttendance = '/attendance/me';
  static const String allAttendance = '/attendance';

  static const String applyLeave = '/leaves';
  static const String myLeaves = '/leaves/my-requests';
  static const String allLeaves = '/leaves';

  static const String myPayroll = '/payroll/my-slips';
  static const String generatePayroll = '/payroll/generate';
  static const String allPayroll = '/payroll';
}
