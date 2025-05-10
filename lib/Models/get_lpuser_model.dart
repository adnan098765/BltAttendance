class LpUser {
  final int id;
  final String name;
  final String fatherName;
  final String gender;
  final String mobile;
  final String cnic;
  final String email;
  final String address;
  final String username;
  final String password;
  final DateTime regDate;
  final bool status;
  final bool role;

  LpUser({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.gender,
    required this.mobile,
    required this.cnic,
    required this.email,
    required this.address,
    required this.username,
    required this.password,
    required this.regDate,
    required this.status,
    required this.role,
  });

  factory LpUser.fromJson(Map<String, dynamic> json) {
    return LpUser(
      id: json['ID'],
      name: json['Name'],
      fatherName: json['FatherName'],
      gender: json['Gender'],
      mobile: json['Mobile'],
      cnic: json['CNIC'],
      email: json['Email'],
      address: json['Address'],
      username: json['Username'],
      password: json['Password'],
      regDate: DateTime.parse(json['RegDate']),
      status: json['Status'],
      role: json['Role'],
    );
  }
}
