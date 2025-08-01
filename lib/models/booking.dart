class Booking {
  final int id;
  final int meetingRoomId;
  final String meetingRoomName;
  final int userId;
  final String userName;
  final String employeeNumber;
  final DateTime startTime;
  final DateTime endTime;
  final String title;
  final String description;
  final String status; // 'confirmed', 'pending', 'cancelled'
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.meetingRoomId,
    required this.meetingRoomName,
    required this.userId,
    required this.userName,
    required this.employeeNumber,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      meetingRoomId: json['meetingRoomId'] ?? 0,
      meetingRoomName: json['meetingRoomName'] ?? '',
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '',
      startTime: DateTime.parse(
        json['startTime'] ?? DateTime.now().toIso8601String(),
      ),
      endTime: DateTime.parse(
        json['endTime'] ?? DateTime.now().toIso8601String(),
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingRoomId': meetingRoomId,
      'meetingRoomName': meetingRoomName,
      'userId': userId,
      'userName': userName,
      'employeeNumber': employeeNumber,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CreateBookingDto {
  final int meetingRoomId;
  final DateTime startTime;
  final DateTime endTime;
  final String title;
  final String description;

  CreateBookingDto({
    required this.meetingRoomId,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'meetingRoomId': meetingRoomId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'title': title,
      'description': description,
    };
  }
}
