import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayflow_hrms/logic/providers/payroll_provider.dart';
import 'package:dayflow_hrms/config/theme.dart';


class SalaryView extends ConsumerWidget {
  const SalaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payrollAsync = ref.watch(payrollProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Payroll')),
      body: payrollAsync.when(
        data: (payrolls) {
          if (payrolls.isEmpty) return const Center(child: Text('No payroll records found.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payrolls.length,
            itemBuilder: (context, index) {
              final slip = payrolls[index];
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.deepNavy,
                    child: const Icon(Icons.attach_money, color: Colors.white),
                  ),
                  title: Text('${_getMonth(slip.month)} ${slip.year}'),
                  subtitle: Text(
                      'Net Salary: \$${slip.netSalary.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _RowItem('Base Salary', slip.baseSalary),
                          // Bonuses and Deductions could be added here if in the model
                          const Divider(),
                          _RowItem('Net Salary', slip.netSalary, isBold: true),
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Chip(label: Text(slip.status), backgroundColor: slip.status == 'Paid' ? Colors.green[100] : Colors.orange[100])
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _getMonth(int month) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[month - 1]; // 1-indexed
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const _RowItem(this.label, this.amount, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
