class LoginModel {
  int? iD;
  String? fullName;
  String? fatherName;
  String? cNIC;
  String? rank;
  String? beltNo;
  String? computerNo;
  String? wing;
  String? pS;
  String? circle;
  String? division;
  String? mobile;
  Null? email;
  Null? username;
  Null? password;
  Null? role;
  Null? regDate;
  Null? expDate;
  Null? status;
  Null? application;

  LoginModel(
      {this.iD,
        this.fullName,
        this.fatherName,
        this.cNIC,
        this.rank,
        this.beltNo,
        this.computerNo,
        this.wing,
        this.pS,
        this.circle,
        this.division,
        this.mobile,
        this.email,
        this.username,
        this.password,
        this.role,
        this.regDate,
        this.expDate,
        this.status,
        this.application});

  LoginModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    fullName = json['FullName'];
    fatherName = json['FatherName'];
    cNIC = json['CNIC'];
    rank = json['Rank'];
    beltNo = json['BeltNo'];
    computerNo = json['ComputerNo'];
    wing = json['Wing'];
    pS = json['PS'];
    circle = json['Circle'];
    division = json['Division'];
    mobile = json['Mobile'];
    email = json['Email'];
    username = json['Username'];
    password = json['Password'];
    role = json['Role'];
    regDate = json['RegDate'];
    expDate = json['ExpDate'];
    status = json['Status'];
    application = json['Application'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['FullName'] = this.fullName;
    data['FatherName'] = this.fatherName;
    data['CNIC'] = this.cNIC;
    data['Rank'] = this.rank;
    data['BeltNo'] = this.beltNo;
    data['ComputerNo'] = this.computerNo;
    data['Wing'] = this.wing;
    data['PS'] = this.pS;
    data['Circle'] = this.circle;
    data['Division'] = this.division;
    data['Mobile'] = this.mobile;
    data['Email'] = this.email;
    data['Username'] = this.username;
    data['Password'] = this.password;
    data['Role'] = this.role;
    data['RegDate'] = this.regDate;
    data['ExpDate'] = this.expDate;
    data['Status'] = this.status;
    data['Application'] = this.application;
    return data;
  }
}
