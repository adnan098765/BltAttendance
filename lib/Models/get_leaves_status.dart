class GetLpLeaveStatus {
  int? iD;
  String? name;

  GetLpLeaveStatus({this.iD, this.name});

  GetLpLeaveStatus.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Name'] = this.name;
    return data;
  }
}
