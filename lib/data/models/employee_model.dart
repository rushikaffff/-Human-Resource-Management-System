class Employee {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String designation;
  final String department;
  final String phone;
  final String? profilePicture;
  final String? address;
  final double baseSalary;
  final DateTime? dateOfJoining;

  Employee({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.designation,
    required this.department,
    required this.phone,
    this.profilePicture,
    this.address,
    this.baseSalary = 0.0,
    this.dateOfJoining,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Handling populated user object or just id
    String emailStr = '';
    String userIdStr = '';
    
    if (json['user'] is Map) {
        emailStr = json['user']['email'] ?? '';
        userIdStr = json['user']['_id'] ?? '';
    } else {
        userIdStr = json['user'] ?? '';
    }

    return Employee(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userIdStr,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: emailStr,
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profilePicture'],
      address: json['address'],
      baseSalary: (json['baseSalary'] ?? 0).toDouble(),
      dateOfJoining: json['dateOfJoining'] != null ? DateTime.tryParse(json['dateOfJoining']) : null,
    );
  }
}
