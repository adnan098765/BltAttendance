class GetLeavesModel {
  int? iD;
  int? type;
  String? reason;
  int? status;
  int? userID;

  GetLeavesModel({this.iD, this.type, this.reason, this.status, this.userID});

  GetLeavesModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    type = json['Type'];
    reason = json['Reason'];
    status = json['Status'];
    userID = json['UserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Type'] = this.type;
    data['Reason'] = this.reason;
    data['Status'] = this.status;
    data['UserID'] = this.userID;
    return data;
  }
}
