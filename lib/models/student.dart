import 'package:mongo_dart/mongo_dart.dart';

class Student {
  final String? id;
  final String name;
  final String accountNumber;
  final String password;
  final String status; // 'pending', 'approved', 'restricted'

  Student({
    this.id,
    required this.name,
    required this.accountNumber,
    required this.password,
    this.status = 'pending', // Default status is pending
  });

  Student copyWith({
    String? id,
    String? name,
    String? accountNumber,
    String? password,
    String? status,
  }) {
    return Student(
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

  factory Student.fromMap(Map<String, dynamic> map) {
    String? studentId;
    final dynamic idVal = map['id'] ?? map['_id'];
    if (idVal is String) {
      studentId = idVal;
    } else if (idVal is int) {
      studentId = idVal.toString();
    } else if (idVal is ObjectId) {
      studentId = idVal.toHexString();
    }

    final dynamic nameVal = map['name'];
    final dynamic accountVal = map['accountNumber'];
    final dynamic passwordVal = map['password'];
    final dynamic statusVal = map['status'];

    return Student(
      id: studentId,
      name: nameVal is String ? nameVal : nameVal?.toString() ?? '',
      accountNumber: accountVal is String ? accountVal : accountVal?.toString() ?? '',
      password: passwordVal is String ? passwordVal : passwordVal?.toString() ?? '',
      status: statusVal is String ? statusVal : statusVal?.toString() ?? 'pending',
    );
  }
}
