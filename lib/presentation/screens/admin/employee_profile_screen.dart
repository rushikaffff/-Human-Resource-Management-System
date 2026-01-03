import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/logic/providers/auth_provider.dart';
import 'package:dayflow_hrms/presentation/widgets/admin/edit_employee_form.dart';

class EmployeeProfileScreen extends ConsumerStatefulWidget {
  final dynamic employee;
  final bool isAdminView;

  const EmployeeProfileScreen({
    super.key,
    required this.employee,
    this.isAdminView = true,
  });

  @override
  ConsumerState<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends ConsumerState<EmployeeProfileScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Resume', 'Private Info', 'Salary Info'];

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.isAdminView;
    final authUser = ref.watch(authProvider).value;
    // Check if the profile being viewed is the current user's profile
    final isMe = authUser?.email == widget.employee.email;
    
    // Filter tabs based on role
    final List<String> availableTabs = [];
    availableTabs.add('Resume');
    availableTabs.add('Private Info');
    if (isAdmin) availableTabs.add('Salary Info');
    if (isMe) availableTabs.add('Security');
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Employee Profile',
          style: TextStyle(color: AppTheme.deepNavy),
        ),
        actions: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => _showEditForm(context),
                icon: const Icon(Icons.edit, color: AppTheme.steelBlue),
                tooltip: 'Edit Profile',
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar (Only on desktop)
          if (MediaQuery.of(context).size.width > 900) _buildSidebar(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Card
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  
                  // Tabs
                  _buildTabs(availableTabs),
                  const SizedBox(height: 24),
                  
                  // Tab Content
                  _buildTabContent(availableTabs, isAdmin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: AppTheme.deepNavy,
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/dayflow_logo.jpg',
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32),
          // Navigation Items
          _buildNavItem(Icons.business, 'Company Logo'),
          _buildNavItem(Icons.people, 'Employees'),
          _buildNavItem(Icons.access_time, 'Attendance'),
          _buildNavItem(Icons.event_note, 'Time Off'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: () {},
    );
  }

  Widget _buildProfileHeader() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
    );
  }

  Widget _buildDesktopHeader() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.steelBlue,
              child: Text(
                '${widget.employee.firstName[0]}${widget.employee.lastName[0]}'.toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.employee.firstName} ${widget.employee.lastName}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Login ID', widget.employee.userId ?? 'N/A', Icons.badge),
                  _buildInfoRow('Email', widget.employee.email ?? 'N/A', Icons.email),
                  _buildInfoRow('Mobile', widget.employee.phone ?? 'N/A', Icons.phone),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildInfoRow('Company', 'DayFlow Corp', Icons.business),
                  _buildInfoRow('Department', widget.employee.department ?? 'N/A', Icons.apartment),
                  _buildInfoRow('Manager', 'N/A', Icons.person_outline),
                  _buildInfoRow('Location', 'N/A', Icons.location_on),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.steelBlue,
          child: Text(
            '${widget.employee.firstName[0]}${widget.employee.lastName[0]}'.toUpperCase(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${widget.employee.firstName} ${widget.employee.lastName}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Login ID', widget.employee.userId ?? 'N/A', Icons.badge),
        _buildInfoRow('Email', widget.employee.email ?? 'N/A', Icons.email),
        _buildInfoRow('Mobile', widget.employee.phone ?? 'N/A', Icons.phone),
        const Divider(height: 24),
        _buildInfoRow('Company', 'DayFlow Corp', Icons.business),
        _buildInfoRow('Department', widget.employee.department ?? 'N/A', Icons.apartment),
        _buildInfoRow('Manager', 'N/A', Icons.person_outline),
        _buildInfoRow('Location', 'N/A', Icons.location_on),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.steelBlue),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppTheme.deepNavy, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(List<String> availableTabs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: availableTabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTab == index;
          
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.steelBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.deepNavy,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(List<String> availableTabs, bool isAdmin) {
    final selectedTabName = availableTabs[_selectedTab];
    
    switch (selectedTabName) {
      case 'Resume':
        return _buildResumeTab();
      case 'Private Info':
        return _buildPrivateInfoTab();
      case 'Salary Info':
        return _buildSalaryInfoTab();
      case 'Security':
        return _buildSecurityTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSecurityTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Security',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage your account password and security settings.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: AppTheme.steelBlue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last changed: --',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _showChangePasswordDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.steelBlue,
                    side: const BorderSide(color: AppTheme.steelBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  Widget _buildResumeTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 12),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Skills',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Flutter', 'Dart', 'JavaScript', 'Node.js', 'MongoDB'].map((skill) {
              return Chip(
                label: Text(skill),
                backgroundColor: AppTheme.lightBlue.withOpacity(0.2),
                labelStyle: const TextStyle(color: AppTheme.steelBlue),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Education & Experience',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 12),
          _buildExperienceItem(
            'Senior Developer',
            'DayFlow Corp',
            '2023 - Present',
          ),
          _buildExperienceItem(
            'Junior Developer',
            'Tech Solutions Inc',
            '2021 - 2023',
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String period) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: AppTheme.steelBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.deepNavy),
                ),
                Text(
                  company,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  period,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateInfoTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Private Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          SizedBox(height: 16),
          Text('This section will contain private employee information.'),
        ],
      ),
    );
  }

  Widget _buildSalaryInfoTab() {
    final baseSalary = widget.employee.baseSalary;
    final monthlyWage = baseSalary;
    final yearlyWage = monthlyWage * 12;
    
    // Salary Components
    final basicSalary = monthlyWage * 0.50; // 50% of monthly
    final hra = basicSalary * 0.50; // 50% of basic
    final standardAllowance = 3167.0; // Fixed
    final performanceBonus = basicSalary * 0.0833; // 8.33% of basic
    final lta = basicSalary * 0.0833; // 8.33% of basic
    final fixedAllowance = monthlyWage - (basicSalary + hra + standardAllowance + performanceBonus + lta);
    
    // PF & Tax
    final pfEmployee = basicSalary * 0.12;
    final pfEmployer = basicSalary * 0.12;
    final professionalTax = 200.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.lock, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Salary Info Tab Should Only Be Visible to Admin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Wages
          Row(
            children: [
              Expanded(
                child: _buildWageCard('Monthly Wage', monthlyWage, Icons.calendar_month),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWageCard('Yearly Wage', yearlyWage, Icons.calendar_today),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Working Details
          Row(
            children: [
              Expanded(
                child: _buildDetailCard('No of working days\nin a week', '5 days'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailCard('Break time', '1.0 hrs'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Salary Components
          const Text(
            'Salary Components',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 16),
          
          _buildComponentRow('Basic Salary', basicSalary, monthlyWage, '50.0 %'),
          _buildComponentRow('House Rent Allowance', hra, monthlyWage, '${((hra / basicSalary) * 100).toStringAsFixed(1)} %'),
          _buildComponentRow('Standard Allowance', standardAllowance, monthlyWage, '${((standardAllowance / monthlyWage) * 100).toStringAsFixed(1)} %'),
          _buildComponentRow('Performance Bonus', performanceBonus, monthlyWage, '8.33 %'),
          _buildComponentRow('Leave Travel Allowance', lta, monthlyWage, '8.33 %'),
          _buildComponentRow('Fixed Allowance', fixedAllowance, monthlyWage, '${((fixedAllowance / monthlyWage) * 100).toStringAsFixed(1)} %'),
          
          const Divider(height: 32),
          
          // Provident Fund
          const Text(
            'Provident Fund (PF) Contribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 16),
          _buildPFRow('Employee', pfEmployee, basicSalary, '12.00 %'),
          _buildPFRow('Employer', pfEmployer, basicSalary, '12.00 %'),
          
          const Divider(height: 32),
          
          // Tax Deductions
          const Text(
            'Tax Deductions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 16),
          _buildTaxRow('Professional Tax', professionalTax),
        ],
      ),
    );
  }

  Widget _buildWageCard(String label, double amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.steelBlue, AppTheme.softBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${NumberFormat('#,##,###').format(amount)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentRow(String label, double amount, double total, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.deepNavy),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${NumberFormat('#,##,###').format(amount)} / month',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 60,
            child: Text(
              percentage,
              style: const TextStyle(fontSize: 13, color: AppTheme.steelBlue, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPFRow(String label, double amount, double basicSalary, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.deepNavy),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${NumberFormat('#,##,###').format(amount)} / month',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 60,
            child: Text(
              percentage,
              style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.deepNavy),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${NumberFormat('#,##,###').format(amount)} / month',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditEmployeeForm(employee: widget.employee),
      ),
    );
  }
}

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      await ref.read(authProvider.notifier).changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      
       if (!mounted) return;
       Navigator.pop(context); // Close dialog
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Password changed successfully'), backgroundColor: Colors.green),
       );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password', style: TextStyle(color: AppTheme.deepNavy)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               TextFormField(
                 controller: _currentPasswordController,
                 obscureText: _obscureCurrent,
                 decoration: InputDecoration(
                   labelText: 'Current Password',
                   border: const OutlineInputBorder(),
                   suffixIcon: IconButton(
                     icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                     onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                   ),
                 ),
                 validator: (v) => v!.isEmpty ? 'Required' : null,
               ),
               const SizedBox(height: 16),
               TextFormField(
                 controller: _newPasswordController,
                 obscureText: _obscureNew,
                 decoration: InputDecoration(
                   labelText: 'New Password',
                   border: const OutlineInputBorder(),
                   suffixIcon: IconButton(
                     icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                     onPressed: () => setState(() => _obscureNew = !_obscureNew),
                   ),
                 ),
                 validator: (v) {
                   if (v!.isEmpty) return 'Required';
                   if (v.length < 6) return 'At least 6 characters';
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               TextFormField(
                 controller: _confirmPasswordController,
                 obscureText: _obscureConfirm,
                 decoration: InputDecoration(
                   labelText: 'Confirm New Password',
                   border: const OutlineInputBorder(),
                   suffixIcon: IconButton(
                     icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                     onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                   ),
                 ),
                 validator: (v) {
                   if (v != _newPasswordController.text) return 'Passwords do not match';
                   return null;
                 },
               ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.steelBlue,
          ),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Update Password', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
