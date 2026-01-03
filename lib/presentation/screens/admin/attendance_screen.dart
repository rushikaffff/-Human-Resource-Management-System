import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/logic/providers/auth_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const AttendanceScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data for admin view (all employees, single day)
  final List<DailyAttendance> _mockDailyAttendance = [
    DailyAttendance(
      employeeName: 'Employee1',
      checkIn: DateTime(2026, 1, 3, 10, 0),
      checkOut: DateTime(2026, 1, 3, 19, 0),
    ),
    DailyAttendance(
      employeeName: 'Employee2',
      checkIn: DateTime(2026, 1, 3, 10, 0),
      checkOut: DateTime(2026, 1, 3, 14, 0),
    ),
  ];

  // Mock data for employee view (one employee, multiple days)
  final List<MonthlyAttendance> _mockMonthlyAttendance = [
    MonthlyAttendance(
      date: DateTime(2025, 10, 29),
      checkIn: DateTime(2025, 10, 29, 10, 0),
      checkOut: DateTime(2025, 10, 29, 19, 0),
    ),
    MonthlyAttendance(
      date: DateTime(2025, 10, 30),
      checkIn: DateTime(2025, 10, 30, 10, 0),
      checkOut: DateTime(2025, 10, 30, 19, 0),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DailyAttendance> get _filteredDailyAttendance {
    if (_searchQuery.isEmpty) return _mockDailyAttendance;
    return _mockDailyAttendance.where((record) {
      return record.employeeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get _daysPresent => _mockMonthlyAttendance.length;
  int get _leavesCount => 2; // Mock data
  int get _totalWorkingDays => 26; // Mock data

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.value?.role == 'HR';
    final isMobile = MediaQuery.of(context).size.width < 600;

    Widget content = Column(
      children: [
        if (!widget.isEmbedded) _buildTopNavigation(isMobile, isAdmin),
        if (isAdmin)
          _buildAdminControls(isMobile)
        else
          _buildEmployeeControls(isMobile),
        Expanded(
          child: isAdmin
              ? _buildAdminView(isMobile)
              : _buildEmployeeView(isMobile),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Container(
        color: Colors.grey[100],
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: content,
    );
  }

  Widget _buildTopNavigation(bool isMobile, bool isAdmin) {
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
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 12,
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/dayflow_logo.jpg',
                  height: isMobile ? 35 : 40,
                  fit: BoxFit.contain,
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  const Text(
                    'HR Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.deepNavy),
                  ),
                ],
                const Spacer(),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.steelBlue,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('Company Logo', false, Icons.business),
                  _buildTab('Employees', false, Icons.people),
                  _buildTab('Attendance', true, Icons.access_time),
                  _buildTab('Time Off', false, Icons.event_note),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.steelBlue),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: Colors.white,
        selectedColor: AppTheme.steelBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.deepNavy,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        checkmarkColor: Colors.white,
        side: BorderSide(color: isSelected ? AppTheme.steelBlue : Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // ADMIN CONTROLS
  Widget _buildAdminControls(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      color: Colors.white,
      child: Column(
        children: [
          if (isMobile) ...[
            _buildSearchBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateSelector()),
                const SizedBox(width: 8),
                Expanded(child: _buildDayDisplay()),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(flex: 3, child: _buildSearchBar()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildDateSelector()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildDayDisplay()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search employee...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.steelBlue),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: AppTheme.steelBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, size: 18, color: AppTheme.steelBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Day: ${DateFormat('EEEE').format(_selectedDate)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // EMPLOYEE CONTROLS
  Widget _buildEmployeeControls(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      color: Colors.white,
      child: Column(
        children: [
          // Month Selector
          Row(
            children: [
              Expanded(child: _buildMonthSelector()),
            ],
          ),
          const SizedBox(height: 16),
          // Summary Cards
          if (isMobile)
            Column(
              children: [
                _buildSummaryCard('Days Present', _daysPresent.toString(), Colors.green),
                const SizedBox(height: 8),
                _buildSummaryCard('Leaves Count', _leavesCount.toString(), Colors.orange),
                const SizedBox(height: 8),
                _buildSummaryCard('Total Working Days', _totalWorkingDays.toString(), Colors.blue),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Days Present', _daysPresent.toString(), Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Leaves Count', _leavesCount.toString(), Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Total Working Days', _totalWorkingDays.toString(), Colors.blue)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonth,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: List.generate(12, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(months[index]),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedMonth = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ADMIN VIEW
  Widget _buildAdminView(bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Attendance Records',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.steelBlue),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (!isMobile) _buildAdminTableHeader(),
          Expanded(
            child: _filteredDailyAttendance.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDailyAttendance.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _buildAdminRow(_filteredDailyAttendance[index], isMobile),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.grey[50],
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text('Employee', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: _buildHeaderText('Check In')),
          Expanded(flex: 2, child: _buildHeaderText('Check Out')),
          Expanded(flex: 2, child: _buildHeaderText('Work Hours')),
          Expanded(flex: 2, child: _buildHeaderText('Extra Hours')),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13));
  }

  Widget _buildAdminRow(DailyAttendance record, bool isMobile) {
    if (isMobile) return _buildMobileCard(record);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.softBlue,
                  child: Text(
                    record.employeeName.split(' ').map((n) => n[0]).join().toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(record.employeeName, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Expanded(flex: 2, child: _buildTimeCell(record.checkInFormatted)),
          Expanded(flex: 2, child: _buildTimeCell(record.checkOutFormatted)),
          Expanded(flex: 2, child: _buildBadge(record.workHoursFormatted, Colors.green)),
          Expanded(flex: 2, child: _buildBadge(record.extraHoursFormatted, Colors.orange)),
        ],
      ),
    );
  }

  // EMPLOYEE VIEW
  Widget _buildEmployeeView(bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: const Text(
              'My Attendance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
            ),
          ),
          const Divider(height: 1),
          if (!isMobile) _buildEmployeeTableHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _mockMonthlyAttendance.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildEmployeeRow(_mockMonthlyAttendance[index], isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.grey[50],
      child: Row(
        children: [
          const Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: _buildHeaderText('Check In')),
          Expanded(flex: 2, child: _buildHeaderText('Check Out')),
          Expanded(flex: 2, child: _buildHeaderText('Work Hours')),
          Expanded(flex: 2, child: _buildHeaderText('Extra Hours')),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(MonthlyAttendance record, bool isMobile) {
    if (isMobile) return _buildEmployeeMobileCard(record);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(record.dateFormatted, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: _buildTimeCell(record.checkInFormatted)),
          Expanded(flex: 2, child: _buildTimeCell(record.checkOutFormatted)),
          Expanded(flex: 2, child: _buildBadge(record.workHoursFormatted, Colors.green)),
          Expanded(flex: 2, child: _buildBadge(record.extraHoursFormatted, Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildTimeCell(String time) {
    return Text(time, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
  }

  Widget _buildBadge(String text, Color color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }

  Widget _buildMobileCard(DailyAttendance record) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.softBlue,
                  child: Text(
                    record.employeeName.split(' ').map((n) => n[0]).join().toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(record.employeeName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoItem('Check In', record.checkInFormatted, Icons.login)),
                Expanded(child: _buildInfoItem('Check Out', record.checkOutFormatted, Icons.logout)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInfoItem('Work Hours', record.workHoursFormatted, Icons.access_time, Colors.green)),
                Expanded(child: _buildInfoItem('Extra Hours', record.extraHoursFormatted, Icons.add_circle_outline, Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeMobileCard(MonthlyAttendance record) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.dateFormatted, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoItem('Check In', record.checkInFormatted, Icons.login)),
                Expanded(child: _buildInfoItem('Check Out', record.checkOutFormatted, Icons.logout)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInfoItem('Work Hours', record.workHoursFormatted, Icons.access_time, Colors.green)),
                Expanded(child: _buildInfoItem('Extra Hours', record.extraHoursFormatted, Icons.add_circle_outline, Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color ?? Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? AppTheme.deepNavy)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No attendance records found', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// Daily Attendance Model (Admin View - All employees, single day)
class DailyAttendance {
  final String employeeName;
  final DateTime checkIn;
  final DateTime? checkOut;
  final Duration breakDuration;

  DailyAttendance({
    required this.employeeName,
    required this.checkIn,
    this.checkOut,
    this.breakDuration = const Duration(hours: 1),
  });

  String get checkInFormatted => DateFormat('HH:mm').format(checkIn);
  String get checkOutFormatted => checkOut != null ? DateFormat('HH:mm').format(checkOut!) : '--:--';
  
  Duration get totalTime => checkOut != null ? checkOut!.difference(checkIn) : Duration.zero;
  Duration get workHours => totalTime > breakDuration ? totalTime - breakDuration : Duration.zero;
  Duration get extraHours {
    const standard = Duration(hours: 8);
    return workHours > standard ? workHours - standard : Duration.zero;
  }
  
  String get workHoursFormatted {
    final hours = workHours.inHours;
    final minutes = workHours.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
  
  String get extraHoursFormatted {
    final hours = extraHours.inHours;
    final minutes = extraHours.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

// Monthly Attendance Model (Employee View - One employee, multiple days)
class MonthlyAttendance {
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final Duration breakDuration;

  MonthlyAttendance({
    required this.date,
    required this.checkIn,
    this.checkOut,
    this.breakDuration = const Duration(hours: 1),
  });

  String get dateFormatted => DateFormat('dd/MM/yyyy').format(date);
  String get checkInFormatted => DateFormat('HH:mm').format(checkIn);
  String get checkOutFormatted => checkOut != null ? DateFormat('HH:mm').format(checkOut!) : '--:--';
  
  Duration get totalTime => checkOut != null ? checkOut!.difference(checkIn) : Duration.zero;
  Duration get workHours => totalTime > breakDuration ? totalTime - breakDuration : Duration.zero;
  Duration get extraHours {
    const standard = Duration(hours: 8);
    return workHours > standard ? workHours - standard : Duration.zero;
  }
  
  String get workHoursFormatted {
    final hours = workHours.inHours;
    final minutes = workHours.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
  
  String get extraHoursFormatted {
    final hours = extraHours.inHours;
    final minutes = extraHours.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
