import 'package:go_router/go_router.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/employee/employee_dashboard.dart';
import '../presentation/screens/employee/employee_profile.dart';
import '../presentation/screens/employee/attendance_view.dart';
import '../presentation/screens/employee/leave_application.dart';
import '../presentation/screens/employee/salary_view.dart';
import '../presentation/screens/admin/admin_dashboard.dart';
import '../presentation/screens/admin/employee_list.dart';
import '../presentation/screens/admin/leave_approval.dart';
import '../presentation/screens/admin/attendance_management.dart';
import '../presentation/screens/admin/payroll_management.dart';
import 'package:flutter/material.dart';

// Placeholder screens until implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/employee-dashboard',
      builder: (context, state) => const EmployeeDashboard(),
    ),
    GoRoute(
      path: '/employee/profile',
      builder: (context, state) => const EmployeeProfileScreen(),
    ),
    GoRoute(
      path: '/employee/attendance',
      builder: (context, state) => const AttendanceView(),
    ),
    GoRoute(
      path: '/employee/leaves',
      builder: (context, state) => const LeaveApplicationScreen(),
    ),
    GoRoute(
      path: '/employee/payroll',
      builder: (context, state) => const SalaryView(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/admin/employees',
      builder: (context, state) => const EmployeeListScreen(),
    ),
    GoRoute(
      path: '/admin/leaves',
      builder: (context, state) => const LeaveApprovalScreen(),
    ),
    GoRoute(
      path: '/admin/attendance',
      builder: (context, state) => const AttendanceManagementScreen(),
    ),
    GoRoute(
      path: '/admin/payroll',
      builder: (context, state) => const PayrollManagementScreen(),
    ),
  ],
);
