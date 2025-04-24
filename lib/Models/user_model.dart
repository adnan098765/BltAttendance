// lib/Models/user_model.dart
class UserModel {
  final String fullName;
  final String fatherName;
  final String gender;
  final String phoneNumber;
  final String cnic;
  final String email;
  final String address;
  final String userName;
  final String registrationDate;
  final String status;
  final String role;

  UserModel({
    required this.fullName,
    required this.fatherName,
    required this.gender,
    required this.phoneNumber,
    required this.cnic,
    required this.email,
    required this.address,
    required this.userName,
    required this.registrationDate,
    required this.status,
    required this.role,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'fatherName': fatherName,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'cnic': cnic,
      'email': email,
      'address': address,
      'userName': userName,
      'registrationDate': registrationDate,
      'status': status,
      'role': role,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] ?? '',
      fatherName: json['fatherName'] ?? '',
      gender: json['gender'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      cnic: json['cnic'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      userName: json['userName'] ?? '',
      registrationDate: json['registrationDate'] ?? '',
      status: json['status'] ?? '',
      role: json['role'] ?? '',
    );
  }

  // Method to get display gender
  String getDisplayGender() {
    switch (gender) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'O':
        return 'Other';
      default:
        return gender;
    }
  }
}