// class GetBreaksModel {
//   int? id;
//   String? type;
//   String? startDate;
//   String? endDate;
//   int? userID;
//
//   GetBreaksModel({
//     this.id,
//     this.type,
//     this.startDate,
//     this.endDate,
//     this.userID,
//   });
//
//   GetBreaksModel.fromJson(Map<String, dynamic> json) {
//     id = json['ID'];
//     type = json['Type'];
//     startDate = json['StartDate'];
//     endDate = json['EndDate'];
//     userID = json['UserID'];
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'ID': id,
//       'Type': type,
//       'StartDate': startDate,
//       'EndDate': endDate,
//       'UserID': userID,
//     };
//   }
// }
// class GetBreaksModel {
//   int? id;
//   String? type;
//   String? startDate;
//   String? endDate;
//   int? userID;
//   int? duration;
//   String? status;
//
//   GetBreaksModel({
//     this.id,
//     this.type,
//     this.startDate,
//     this.endDate,
//     this.userID,
//     this.duration,
//     this.status,
//   });
//
//   factory GetBreaksModel.fromJson(Map<String, dynamic> json) {
//     // Safely convert field based on type
//     dynamic safelyConvertField(dynamic value, Type targetType) {
//       if (value == null) return null;
//
//       if (targetType == int) {
//         if (value is int) return value;
//         if (value is String) return int.tryParse(value);
//         return null;
//       }
//
//       if (targetType == String) {
//         return value.toString();
//       }
//
//       return value;
//     }
//
//     return GetBreaksModel(
//       id: safelyConvertField(json['ID'] ?? json['id'] ?? json['Id'], int),
//       type: safelyConvertField(
//           json['Type'] ?? json['type'] ?? json['breakType'], String),
//       startDate: safelyConvertField(
//           json['StartDate'] ?? json['startDate'] ?? json['startTime'], String),
//       endDate: safelyConvertField(
//           json['EndDate'] ?? json['endDate'] ?? json['endTime'], String),
//       userID: safelyConvertField(
//           json['UserID'] ?? json['userId'] ?? json['userID'] ?? json['user_id'],
//           int),
//       duration: safelyConvertField(json['Duration'] ?? json['duration'], int),
//       status: safelyConvertField(json['Status'] ?? json['status'], String),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'ID': id,
//       'Type': type,
//       'StartDate': startDate,
//       'EndDate': endDate,
//       'UserID': userID,
//       'Duration': duration,
//       'Status': status,
//     };
//   }
// }
class GetBreaksModel {
  int? id;
  int? type; // Changed from String to int based on your API response
  String? startDate;
  String? endDate;
  int? userID;
  int? duration;
  String? status;

  GetBreaksModel({
    this.id,
    this.type,
    this.startDate,
    this.endDate,
    this.userID,
    this.duration,
    this.status,
  });

  factory GetBreaksModel.fromJson(Map<String, dynamic> json) {
    // Log for debugging specific fields
    // print('Processing JSON with ID: ${json['ID']}, Type: ${json['Type']}');

    return GetBreaksModel(
      id: json['ID'],
      type: json['Type'], // This is actually an integer in your API response
      startDate: json['StartTime'], // Changed from StartDate to StartTime based on API
      endDate: json['EndTime'],    // Changed from EndDate to EndTime based on API
      userID: json['UserID'],
      // Add these if they're in your actual API response
      // duration: json['Duration'],
      // status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Type': type,
      'StartTime': startDate, // Match the API field names
      'EndTime': endDate,     // Match the API field names
      'UserID': userID,
      'Duration': duration,
      'Status': status,
    };
  }
}