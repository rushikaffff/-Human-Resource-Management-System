import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dayflow_hrms/config/theme.dart';
import 'package:dayflow_hrms/logic/providers/auth_provider.dart';

class TimeOffScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const TimeOffScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<TimeOffScreen> createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends ConsumerState<TimeOffScreen> {
  int _selectedSubTab = 0;
  final List<String> _subTabs = ['Time OFF', 'Allocation'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock time off data
  final List<TimeOffRequest> _mockRequests = [
    TimeOffRequest(
      employeeName: 'Emp Name',
      startDate: DateTime(2025, 10, 25),
      endDate: DateTime(2025, 10, 29),
      timeOffType: 'Paid Time Off',
      status: 'Pending',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TimeOffRequest> get _filteredRequests {
    if (_searchQuery.isEmpty) return _mockRequests;
    return _mockRequests.where((request) {
      return request.employeeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.value?.role == 'HR';
    final isMobile = MediaQuery.of(context).size.width < 600;

    Widget content = Column(
      children: [
        if (!widget.isEmbedded) _buildTopNavigation(isMobile, isAdmin),
        _buildSubTabs(isMobile, isAdmin),
        _buildSearchBar(isMobile),
        if (_selectedSubTab == 0) ...[
          _buildTimeOffCategories(isMobile),
          Expanded(child: _buildTimeOffRequests(isMobile, isAdmin)),
        ] else ...[
          Expanded(child: _buildAllocationView()),
        ],
      ],
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: content,
        floatingActionButton: _selectedSubTab == 0
            ? FloatingActionButton.extended(
                onPressed: () => _showNewRequestDialog(context),
                backgroundColor: AppTheme.steelBlue,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  isMobile ? 'NEW' : 'NEW REQUEST',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: content,
      floatingActionButton: _selectedSubTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showNewRequestDialog(context),
              backgroundColor: AppTheme.steelBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                isMobile ? 'NEW' : 'NEW REQUEST',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
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
                  _buildTab('Attendance', false, Icons.access_time),
                  _buildTab('Time Off', true, Icons.event_note),
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

  Widget _buildSubTabs(bool isMobile, bool isAdmin) {
    final tabs = isAdmin ? _subTabs : ['Time OFF'];

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      color: Colors.white,
      child: Row(
        children: [
          ...tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedSubTab == index;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tab),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedSubTab = index);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppTheme.steelBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 12),
      color: Colors.white,
      child: TextField(
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
      ),
    );
  }

  Widget _buildTimeOffCategories(bool isMobile) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.value?.role == 'HR';
    
    // Employee view shows their specific balance
    final paidDays = isAdmin ? 28 : 24;  // Admin sees default, Employee sees their balance
    final sickDays = 7;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      color: Colors.white,
      child: isMobile
          ? Column(
              children: [
                _buildCategoryCard('Paid Time Off', paidDays, Colors.blue),
                const SizedBox(height: 12),
                _buildCategoryCard('Sick Time Off', sickDays, Colors.orange),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildCategoryCard('Paid Time Off', paidDays, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildCategoryCard('Sick Time Off', sickDays, Colors.orange)),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(String title, int daysAvailable, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$daysAvailable Days Available',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            title.contains('Paid') ? Icons.beach_access : Icons.local_hospital,
            size: 48,
            color: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOffRequests(bool isMobile, bool isAdmin) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Time Off Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
                const Spacer(),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Admin View - All Employees',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'My Requests',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (!isMobile) _buildTableHeader(isAdmin),
          Expanded(
            child: _filteredRequests.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRequests.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _buildRequestRow(_filteredRequests[index], isMobile, isAdmin),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.grey[50],
      child: Row(
        children: [
          const Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: _buildHeaderText('Start Date')),
          Expanded(flex: 2, child: _buildHeaderText('End Date')),
          Expanded(flex: 2, child: _buildHeaderText('Time Off Type')),
          Expanded(flex: 2, child: _buildHeaderText('Status')),
          if (isAdmin) const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }

  Widget _buildRequestRow(TimeOffRequest request, bool isMobile, bool isAdmin) {
    if (isMobile) return _buildMobileRequestCard(request, isAdmin);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              request.employeeName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 2, child: _buildDateCell(request.startDateFormatted)),
          Expanded(flex: 2, child: _buildDateCell(request.endDateFormatted)),
          Expanded(flex: 2, child: _buildTypeCell(request.timeOffType)),
          Expanded(flex: 2, child: _buildStatusBadge(request.status)),
          if (isAdmin && request.status == 'Pending')
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton('Approve', Colors.green, Icons.check),
                  const SizedBox(width: 8),
                  _buildActionButton('Reject', Colors.red, Icons.close),
                ],
              ),
            )
          else if (isAdmin)
            const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildMobileRequestCard(TimeOffRequest request, bool isAdmin) {
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
                Expanded(
                  child: Text(
                    request.employeeName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildMobileInfoRow(Icons.calendar_today, 'Start', request.startDateFormatted),
            const SizedBox(height: 8),
            _buildMobileInfoRow(Icons.event, 'End', request.endDateFormatted),
            const SizedBox(height: 8),
            _buildMobileInfoRow(Icons.category, 'Type', request.timeOffType),
            if (isAdmin && request.status == 'Pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCell(String date) {
    return Text(
      date,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildTypeCell(String type) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: type.contains('Paid') ? Colors.blue.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: type.contains('Paid') ? Colors.blue : Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == 'Approve') {
          _approveRequest(_filteredRequests[0]);
        } else {
          _rejectRequest(_filteredRequests[0]);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(90, 36),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No time-off requests found', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAllocationView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 80, color: AppTheme.softBlue),
            const SizedBox(height: 24),
            const Text(
              'Allocation Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
            ),
            const SizedBox(height: 16),
            Text(
              'Configure time-off allocations for employees',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _approveRequest(TimeOffRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Approved time-off request for ${request.employeeName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectRequest(TimeOffRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejected time-off request for ${request.employeeName}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showNewRequestDialog(BuildContext context) {
    final authState = ref.read(authProvider);
    final employeeName = authState.value?.role == 'HR' ? 'Admin User' : 'Employee Name';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: TimeOffRequestForm(employeeName: employeeName),
        ),
      ),
    );
  }
}

// Time Off Request Form Widget
class TimeOffRequestForm extends StatefulWidget {
  final String employeeName;
  
  const TimeOffRequestForm({super.key, required this.employeeName});

  @override
  State<TimeOffRequestForm> createState() => _TimeOffRequestFormState();
}

class _TimeOffRequestFormState extends State<TimeOffRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Paid Time Off';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _attachmentName;
  
  final List<String> _timeOffTypes = [
    'Paid Time Off',
    'Sick Time Off',
    'Unpaid Leaves',
  ];

  int get _calculatedDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
        title: const Text('Time Off Type Request'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Employee Field (Auto-filled, disabled)
            TextFormField(
              initialValue: widget.employeeName,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Employee',
                prefixIcon: const Icon(Icons.person, color: AppTheme.steelBlue),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Off Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Time Off Type *',
                prefixIcon: const Icon(Icons.category, color: AppTheme.steelBlue),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.steelBlue, width: 2),
                ),
              ),
              items: _timeOffTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Validity Period
            const Text(
              'Validity Period *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.deepNavy),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _startDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppTheme.steelBlue),
                              const SizedBox(width: 8),
                              Text(
                                _startDate != null 
                                    ? DateFormat('dd MMM yyyy').format(_startDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _startDate != null ? AppTheme.deepNavy : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _endDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.event, size: 16, color: AppTheme.steelBlue),
                              const SizedBox(width: 8),
                              Text(
                                _endDate != null 
                                    ? DateFormat('dd MMM yyyy').format(_endDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _endDate != null ? AppTheme.deepNavy : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Allocation (Auto-calculated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate, color: AppTheme.steelBlue, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'Allocation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.deepNavy),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.steelBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_calculatedDays ${_calculatedDays == 1 ? 'Day' : 'Days'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Attachment Upload
            const Text(
              'Attachment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.deepNavy),
            ),
            const SizedBox(height: 8),
            Text(
              'For sick leave certificate',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                // Mock file picker
                setState(() => _attachmentName = 'sick_certificate.pdf');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File upload feature coming soon')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.steelBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.upload_file, color: AppTheme.steelBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _attachmentName ?? 'Click to upload file',
                        style: TextStyle(
                          fontSize: 14,
                          color: _attachmentName != null ? AppTheme.deepNavy : Colors.grey[500],
                        ),
                      ),
                    ),
                    if (_attachmentName != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => setState(() => _attachmentName = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_startDate == null || _endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select validity period'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Submit form
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Time off request submitted: $_calculatedDays days'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.steelBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Time Off Request Model
class TimeOffRequest {
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final String timeOffType;
  final String status; // Pending, Approved, Rejected

  TimeOffRequest({
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.timeOffType,
    required this.status,
  });

  String get startDateFormatted => DateFormat('dd/MM/yyyy').format(startDate);
  String get endDateFormatted => DateFormat('dd/MM/yyyy').format(endDate);
  
  int get durationInDays => endDate.difference(startDate).inDays + 1;
}
