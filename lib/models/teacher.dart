class Teacher {
  final int? id;
  final String name;
  final String accountNumber;
  final String password;
  final String status; // 'pending', 'approved', 'restricted'

  Teacher({
    this.id,
    required this.name,
    required this.accountNumber,
    required this.password,
    this.status = 'pending', // Default status is pending
  });

  Teacher copyWith({
    int? id,
    String? name,
    String? accountNumber,
    String? password,
    String? status,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accountNumber': accountNumber,
      'password': password,
      'status': status,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      name: map['name'],
      accountNumber: map['accountNumber'],
      password: map['password'],
      status: map['status'] ?? 'pending', // Default to pending if status is null
    );
  }
}