class Admin {
  final int? id;
  final String accountNumber;
  final String password;

  Admin({
    this.id,
    required this.accountNumber,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'accountNumber': accountNumber,
      'password': password,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'],
      accountNumber: map['accountNumber'],
      password: map['password'],
    );
  }
}