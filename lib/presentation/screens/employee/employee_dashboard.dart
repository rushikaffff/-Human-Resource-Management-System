import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/logic/providers/auth_provider.dart';
import 'package:dayflow_hrms/logic/providers/employee_provider.dart';
import 'package:dayflow_hrms/presentation/screens/admin/employee_profile_screen.dart';
import 'package:dayflow_hrms/presentation/screens/admin/attendance_screen.dart';
import 'package:dayflow_hrms/presentation/screens/admin/time_off_screen.dart';
import 'package:dayflow_hrms/presentation/screens/admin/payroll/payroll_screen.dart';

class EmployeeDashboard extends ConsumerStatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  ConsumerState<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends ConsumerState<EmployeeDashboard> {
  String _selectedTab = 'Overview';
  final List<String> _tabs = ['Overview', 'Attendance', 'Time Off', 'Payroll'];

  @override
  Widget build(BuildContext context) {
    final employeeAsync = ref.watch(employeeProfileProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top Navigation Bar (reusing style from AdminDashboard)
          _buildTopNav(context, isMobile, employeeAsync),
          
          // Main Content
          Expanded(
            child: _buildContent(employeeAsync, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, bool isMobile, AsyncValue employeeAsync) {
    final employee = employeeAsync.value;
    final userName = employee != null ? '${employee.firstName} ${employee.lastName}' : 'Employee';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Logo and Profile
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Logo
                Image.asset(
                  'assets/images/dayflow_logo.jpg',
                  height: isMobile ? 35 : 40,
                  fit: BoxFit.contain,
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  const Text(
                    'Employee Portal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepNavy,
                    ),
                  ),
                ],
                const Spacer(),
                
                // User Profile Dropdown
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.steelBlue,
                          child: Text(
                            employee?.firstName[0] ?? 'E',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 8),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, color: AppTheme.steelBlue, size: 20),
                          const SizedBox(width: 12),
                          const Text('My Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 12),
                          const Text('Log Out'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'logout') {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    } else if (value == 'profile' && employee != null) {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeProfileScreen(
                            employee: employee,
                            isAdminView: false,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(tab),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedTab = tab);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.steelBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.deepNavy,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppTheme.steelBlue : Colors.grey[300]!,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AsyncValue employeeAsync, bool isMobile) {
    if (_selectedTab == 'Attendance') {
      return const AttendanceScreen(isEmbedded: true);
    } else if (_selectedTab == 'Time Off') {
      return const TimeOffScreen(isEmbedded: true);
    } else if (_selectedTab == 'Payroll') {
      return const PayrollScreen(isEmployeeView: true);
    }
    
    // Overview Tab
    return employeeAsync.when(
      data: (employee) {
        if (employee == null) {
           return const Center(child: Text('Profile not found.'));
        }
        return _buildOverview(employee, isMobile);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.steelBlue),
      ),
      error: (err, stack) => Center(
        child: Text('Error loading dashboard: $err'),
      ),
    );
  }

  Widget _buildOverview(dynamic employee, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.steelBlue, AppTheme.softBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.steelBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${employee.firstName}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Have a productive day at work.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.wb_sunny, color: Colors.white, size: 40),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: isMobile ? 1 : 2, // 1 col on mobile, 2 on desktop? Or maybe 2 and 4.
            // Let's use responsive grid count
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 1.5 : 2.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
               _buildOverviewCard(
                  'Attendance',
                  'Present',
                  'Check-in: 09:30 AM',
                  Icons.access_time_filled,
                  Colors.green,
               ),
               _buildOverviewCard(
                  'Leave Balance',
                  '12 Days',
                  'Available Paid Leave',
                  Icons.calendar_today,
                  Colors.orange,
               ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity or Today's Schedule Placeholder
          Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: AppTheme.deepNavy
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_available, color: AppTheme.steelBlue),
                SizedBox(width: 12),
                Text(
                  'No meetings scheduled for today.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(
                   color: color.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(10),
                 ),
                 child: Icon(icon, color: color, size: 24),
               ),
             ],
           ),
           const Spacer(),
           Text(
             value,
             style: const TextStyle(
               fontSize: 24,
               fontWeight: FontWeight.bold,
               color: AppTheme.deepNavy,
             ),
           ),
           const SizedBox(height: 4),
           Text(
             title,
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[600],
               fontWeight: FontWeight.w600,
             ),
           ),
           Text(
             subtitle,
             style: TextStyle(
               fontSize: 12,
               color: Colors.grey[500],
             ),
           ),
        ],
      ),
    );
  }
}
