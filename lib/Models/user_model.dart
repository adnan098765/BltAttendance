class UserModel {
  final String fullName;
  final String fatherName;
  final String phoneNumber;
  final String email;
  final String userName;
  final String cnic;
  final String address;
  final String gender;
  final String registrationDate;

  UserModel({
    required this.fullName,
    required this.fatherName,
    required this.phoneNumber,
    required this.email,
    required this.userName,
    required this.cnic,
    required this.address,
    required this.gender,
    required this.registrationDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['Name'] ?? '',
      fatherName: json['FatherName'] ?? '',
      phoneNumber: json['Mobile'] ?? '',
      email: json['Email'] ?? '',
      userName: json['UserName'] ?? '',
      cnic: json['CNIC'] ?? '',
      address: json['Address'] ?? '',
      gender: json['Gender'] ?? 'Male',
      registrationDate: json['RegDate'] ?? '',
    );
  }

  String getDisplayGender() {
    return gender == '1' ? 'Male' : gender == '2' ? 'Female' : 'Other';
  }
}

  // Method to get display gender
