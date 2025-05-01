// models/leave_type_model.dart
class LeaveTypeModel {
  final int id;
  final String name;

  LeaveTypeModel({required this.id, required this.name});

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['ID'],
      name: json['Name'],
    );
  }
}
