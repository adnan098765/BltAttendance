class GetBreaksModel {
  int? id;
  String? type;
  String? startDate;
  String? endDate;
  int? userID;

  GetBreaksModel({
    this.id,
    this.type,
    this.startDate,
    this.endDate,
    this.userID,
  });

  GetBreaksModel.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    type = json['Type'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
    userID = json['UserID'];
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Type': type,
      'StartDate': startDate,
      'EndDate': endDate,
      'UserID': userID,
    };
  }
}
