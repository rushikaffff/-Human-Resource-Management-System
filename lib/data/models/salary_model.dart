class Salary {
  final String id;
  final int month;
  final int year;
  final double baseSalary;
  final double netSalary;
  final String status;

  Salary({
    required this.id,
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.netSalary,
    required this.status,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['_id'],
      month: json['month'],
      year: json['year'],
      baseSalary: (json['baseSalary'] as num).toDouble(),
      netSalary: (json['netSalary'] as num).toDouble(),
      status: json['status'],
    );
  }
}
