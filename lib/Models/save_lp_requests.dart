// save_lp_leave_request.dart

class SaveLpLeaveRequest {
  int type;
  String reason;
  int status;
  int userId;

  SaveLpLeaveRequest({
    required this.type,
    required this.reason,
    required this.status,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Reason': reason,
      'Status': status,
      'UserID': userId,
    };
  }
}
