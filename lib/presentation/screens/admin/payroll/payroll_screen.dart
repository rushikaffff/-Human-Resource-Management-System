import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dayflow_hrms/config/theme.dart';

class PayrollScreen extends ConsumerStatefulWidget {
  final bool isEmployeeView;
  const PayrollScreen({super.key, this.isEmployeeView = false});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  
  // Mock Admin Data
  final List<Map<String, dynamic>> _payrollData = [
    {
      'id': '1',
      'name': 'John Doe',
      'designation': 'Senior Developer',
      'basic': 75000.0,
      'additions': 5000.0,
      'deductions': 2500.0,
      'net': 77500.0,
      'status': 'Pending',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'designation': 'Product Manager',
      'basic': 85000.0,
      'additions': 0.0,
      'deductions': 3000.0,
      'net': 82000.0,
      'status': 'Paid',
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'designation': 'UI/UX Designer',
      'basic': 65000.0,
      'additions': 2000.0,
      'deductions': 1500.0,
      'net': 65500.0,
      'status': 'Processing',
    },
  ];

  // Mock Employee History Data
  final List<Map<String, dynamic>> _myPayrollHistory = [
    {
      'month': 'October 2025',
      'basic': 75000.0,
      'additions': 5000.0,
      'deductions': 2500.0,
      'net': 77500.0,
      'status': 'Paid',
    },
    {
      'month': 'September 2025',
      'basic': 75000.0,
      'additions': 2000.0,
      'deductions': 2500.0,
      'net': 74500.0,
      'status': 'Paid',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: Colors.grey[50], // Background for the tab content
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(isMobile),
          
          // Content
          Expanded(
            child: isMobile 
              ? _buildMobileListView()
              : _buildDesktopTableView(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.isEmployeeView ? 'My Payslips' : 'Payroll Management',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const Spacer(),
              // Month Selector (Only for Admin)
              if (!widget.isEmployeeView)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _selectedMonth,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.deepNavy),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats Cards
          if (widget.isEmployeeView)
            // Employee Stats
             Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Last Net Salary',
                    '₹ ${_myPayrollHistory.first['net']}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Payslips Available',
                    '${_myPayrollHistory.length}',
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
              ],
            )
          else
            // Admin Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Payroll',
                    '₹ 2,25,000',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Paid Employees',
                    '1 / 3',
                    Icons.people,
                    Colors.green,
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      '2',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTableView() {
    final columns = widget.isEmployeeView 
      ? const {
          0: FlexColumnWidth(2), // Month
          1: FlexColumnWidth(1), // Basic
          2: FlexColumnWidth(1), // Additions
          3: FlexColumnWidth(1), // Deductions
          4: FlexColumnWidth(1), // Net Salary
          5: FlexColumnWidth(1), // Status
          6: FixedColumnWidth(100), // Actions
        }
      : const {
          0: FlexColumnWidth(2), // Employee
          1: FlexColumnWidth(1.5), // Designation
          2: FlexColumnWidth(1), // Basic
          3: FlexColumnWidth(1), // Additions
          4: FlexColumnWidth(1), // Deductions
          5: FlexColumnWidth(1), // Net Salary
          6: FlexColumnWidth(1), // Status
          7: FixedColumnWidth(100), // Actions
        };
        
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columns,
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              children: widget.isEmployeeView
                ? [
                    _buildHeaderCell('Month'),
                    _buildHeaderCell('Basic'),
                    _buildHeaderCell('Additions'),
                    _buildHeaderCell('Deductions'),
                    _buildHeaderCell('Net Salary'),
                    _buildHeaderCell('Status'),
                    _buildHeaderCell('Actions'),
                  ]
                : [
                    _buildHeaderCell('Employee'),
                    _buildHeaderCell('Designation'),
                    _buildHeaderCell('Basic'),
                    _buildHeaderCell('Additions'),
                    _buildHeaderCell('Deductions'),
                    _buildHeaderCell('Net Salary'),
                    _buildHeaderCell('Status'),
                    _buildHeaderCell('Actions'),
                  ],
            ),
            // Rows
            if (widget.isEmployeeView)
              ..._myPayrollHistory.map((data) => TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                ),
                children: [
                  _buildCell(data['month'], isBold: true),
                  _buildCell('₹${data['basic']}'),
                  _buildCell('₹${data['additions']}', color: Colors.green),
                  _buildCell('₹${data['deductions']}', color: Colors.red),
                  _buildCell('₹${data['net']}', isBold: true),
                  _buildStatusCell(data['status']),
                  _buildActionCell(data),
                ],
              ))
            else
              ..._payrollData.map((data) => TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                ),
                children: [
                  _buildCell(data['name'], isBold: true),
                  _buildCell(data['designation']),
                  _buildCell('₹${data['basic']}'),
                  _buildCell('₹${data['additions']}', color: Colors.green),
                  _buildCell('₹${data['deductions']}', color: Colors.red),
                  _buildCell('₹${data['net']}', isBold: true),
                  _buildStatusCell(data['status']),
                  _buildActionCell(data),
                ],
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileListView() {
    final dataList = widget.isEmployeeView ? _myPayrollHistory : _payrollData;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final data = dataList[index];
        final title = widget.isEmployeeView ? data['month'] : data['name'];
        final subTitle = widget.isEmployeeView ? 'Net: ₹${data['net']}' : data['designation'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subTitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isEmployeeView ? AppTheme.steelBlue : Colors.grey[600],
                            fontWeight: widget.isEmployeeView ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(data['status']),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMobileInfoItem('Basic', '₹${data['basic']}'),
                  if (!widget.isEmployeeView) _buildMobileInfoItem('Net Salary', '₹${data['net']}', isBold: true),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.steelBlue),
                  ),
                  child: const Text('View Slip'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCell(String text, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? AppTheme.deepNavy,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildStatusBadge(status),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Paid':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: const Icon(Icons.receipt_long, color: AppTheme.steelBlue),
        tooltip: 'View Slip',
        onPressed: () {},
      ),
    );
  }

  Widget _buildMobileInfoItem(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: AppTheme.deepNavy,
          ),
        ),
      ],
    );
  }
}

