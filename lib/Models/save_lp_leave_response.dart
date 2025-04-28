class SaveLpLeaveResponse {
  final int status;
  final String message;

  SaveLpLeaveResponse({
    required this.status,
    required this.message,
  });

  factory SaveLpLeaveResponse.fromJson(Map<String, dynamic> json) {
    return SaveLpLeaveResponse(
      status: json['Status'],
      message: json['Message'],
    );
  }
}
