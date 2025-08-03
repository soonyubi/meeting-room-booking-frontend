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
    // date와 startTime/endTime을 조합하여 DateTime 생성
    DateTime? startTime;
    DateTime? endTime;

    if (json['date'] != null) {
      final dateStr = json['date'] as String;
      final date = DateTime.parse(dateStr);

      if (json['startTime'] != null) {
        final startTimeStr = json['startTime'] as String;
        final timeParts = startTimeStr.split(':');
        if (timeParts.length == 2) {
          startTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }

      if (json['endTime'] != null) {
        final endTimeStr = json['endTime'] as String;
        final timeParts = endTimeStr.split(':');
        if (timeParts.length == 2) {
          endTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }
    }

    return Booking(
      id: json['id'] ?? 0,
      meetingRoomId: json['meetingRoomId'] ?? 0,
      meetingRoomName: json['meetingRoomName'] ?? '',
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '',
      startTime: startTime ?? DateTime.now(),
      endTime: endTime ?? DateTime.now(),
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
  final String date;
  final String startTime;
  final String endTime;
  final String title;

  CreateBookingDto({
    required this.meetingRoomId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'meetingRoomId': meetingRoomId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
    };
  }
}
