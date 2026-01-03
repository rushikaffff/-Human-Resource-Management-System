import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayflow_hrms/logic/providers/admin_provider.dart';
import 'package:dayflow_hrms/presentation/widgets/custom_button.dart';


class PayrollManagementScreen extends ConsumerStatefulWidget {
  const PayrollManagementScreen({super.key});

  @override
  ConsumerState<PayrollManagementScreen> createState() => _PayrollManagementScreenState();
}

class _PayrollManagementScreenState extends ConsumerState<PayrollManagementScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final payrollAsync = ref.watch(adminPayrollProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Generate Payroll', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: _selectedMonth,
                          items: List.generate(12, (index) => index + 1).map((m) => DropdownMenuItem(value: m, child: Text(_getMonth(m)))).toList(),
                          onChanged: (val) => setState(() => _selectedMonth = val!),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<int>(
                          value: _selectedYear,
                          items: [2024, 2025, 2026, 2027].map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                           onChanged: (val) => setState(() => _selectedYear = val!),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                              try {
                                  await ref.read(adminPayrollProvider.notifier).generate(_selectedMonth, _selectedYear);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payroll Generated')));
                              } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                          },
                          child: const Text('Generate'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: payrollAsync.when(
               data: (list) {
                   if (list.isEmpty) return const Center(child: Text('No payroll records generated yet.'));
                   return ListView.builder(
                       itemCount: list.length,
                       itemBuilder: (context, index) {
                           final sal = list[index];
                           return ListTile(
                               leading: const Icon(Icons.receipt_long),
                               title: Text('Month: ${sal.month}/${sal.year}'),
                               subtitle: Text('Status: ${sal.status}'),
                               trailing: Text('\$${sal.netSalary.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                           );
                       }
                   );
               },
               error: (e, st) => Center(child: Text('Error: $e')),
               loading: () => const Center(child: CircularProgressIndicator()),
            ),
          )
        ],
      ),
    );
  }
   String _getMonth(int month) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[month - 1]; // 1-indexed
  }
}
