import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/logic/providers/auth_provider.dart';
import 'package:dayflow_hrms/logic/providers/employee_provider.dart';
import 'package:dayflow_hrms/logic/providers/admin_provider.dart';
import 'package:dayflow_hrms/presentation/screens/admin/employee_profile_screen.dart';
import 'package:dayflow_hrms/presentation/screens/admin/attendance_screen.dart';
import 'package:dayflow_hrms/presentation/screens/admin/time_off_screen.dart';
import 'package:dayflow_hrms/presentation/screens/admin/payroll/payroll_screen.dart';
import 'package:dayflow_hrms/presentation/widgets/admin/add_employee_form.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Employee', 'Attendance', 'Time Off', 'Payroll'];

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(allEmployeesProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top Navigation Bar
          _buildTopNav(context, isMobile),
          
          // Main Content
          Expanded(
            child: _buildContent(employeesAsync, isMobile),
          ),
        ],
      ),
      floatingActionButton: _shouldShowFab()
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEmployeeForm(context),
              backgroundColor: AppTheme.steelBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                isMobile ? 'Add' : 'Add Employee',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  bool _shouldShowFab() {
    return _selectedTab == 'Employee' || _selectedTab == 'All';
  }

  void _showAddEmployeeForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 40,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddEmployeeForm(),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, bool isMobile) {
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
                    'HR Management',
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
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Admin',
                            style: TextStyle(
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
                    } else if (value == 'profile') {
                      _showProfileDialog(context);
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

  Widget _buildContent(AsyncValue employeesAsync, bool isMobile) {
    if (_selectedTab == 'All') {
      return _buildOverviewTab(isMobile, employeesAsync);
    } else if (_selectedTab == 'Attendance') {
      return const AttendanceScreen(isEmbedded: true);
    } else if (_selectedTab == 'Time Off') {
      return const TimeOffScreen(isEmbedded: true);
    } else if (_selectedTab == 'Payroll') {
      return const PayrollScreen();
    }
    
    // Employee tab show employee cards
    return employeesAsync.when(
      data: (employees) {
        if (employees.isEmpty) {
          return _buildEmptyState();
        }
        
        return Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              childAspectRatio: 0.7,
              crossAxisSpacing: isMobile ? 12 : 16,
              mainAxisSpacing: isMobile ? 12 : 16,
            ),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              return _buildEmployeeCard(employees[index], isMobile);
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.steelBlue),
      ),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(dynamic employee, bool isMobile) {
    final status = _getEmployeeStatus(employee);
    final checkInTime = _getCheckInTime(employee);
    
    return GestureDetector(
      onTap: () => _showEmployeeDetails(employee),
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header with Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: isMobile ? 24 : 32,
                        backgroundColor: AppTheme.steelBlue,
                        child: Text(
                          '${employee.firstName[0]}${employee.lastName[0]}'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Status Indicator
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: status.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Employee Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      '${employee.firstName} ${employee.lastName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Designation
                    Text(
                      employee.designation ?? 'Employee',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Department
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        employee.department ?? 'General',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.steelBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Check In/Out Status
                    if (checkInTime != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.login, size: 14, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Check IN > $checkInTime',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No employees found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first employee to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  EmployeeStatus _getEmployeeStatus(dynamic employee) {
    // Mock status - replace with actual attendance logic
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    switch (random) {
      case 0:
        return EmployeeStatus(Colors.green, 'Present');
      case 1:
        return EmployeeStatus(Colors.blue, 'On Leave');
      default:
        return EmployeeStatus(Colors.orange, 'Absent');
    }
  }

  String? _getCheckInTime(dynamic employee) {
    // Mock check-in time - replace with actual data
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    if (random == 0) {
      return DateFormat('h:mm a').format(DateTime.now().subtract(const Duration(hours: 2)));
    }
    return null;
  }

  void _showEmployeeDetails(dynamic employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeProfileScreen(
          employee: employee,
          isAdminView: true,
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final employeeState = ref.read(employeeProfileProvider);
    
    if (employeeState.value != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmployeeProfileScreen(
            employee: employeeState.value!,
            isAdminView: true,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile is loading, please try again completely.')),
      );
      // Trigger fetch just in case
      ref.refresh(employeeProfileProvider);
    }
  }

  Widget _buildOverviewTab(bool isMobile, AsyncValue employeesAsync) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.deepNavy, AppTheme.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepNavy.withOpacity(0.2),
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
                      const Text(
                        'Welcome Back, Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Here is what\'s happening at DayFlow today.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  Icon(Icons.dashboard_customize, size: 64, color: Colors.white.withOpacity(0.2)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Quick Access',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildQuickAccessCard('Employees', Icons.people_outline, Colors.blue, () => setState(() => _selectedTab = 'Employee')),
              _buildQuickAccessCard('Attendance', Icons.calendar_today, Colors.orange, () => setState(() => _selectedTab = 'Attendance')),
              _buildQuickAccessCard('Time Off', Icons.flight_takeoff, Colors.purple, () => setState(() => _selectedTab = 'Time Off')),
              _buildQuickAccessCard('Payroll', Icons.attach_money, Colors.green, () => setState(() => _selectedTab = 'Payroll')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.deepNavy),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeStatus {
  final Color color;
  final String label;
  
  EmployeeStatus(this.color, this.label);
}
