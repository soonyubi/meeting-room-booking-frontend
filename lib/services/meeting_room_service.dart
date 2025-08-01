import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meeting_room.dart';

class MeetingRoomService {
  static const String baseUrl =
      'https://meeting-room-booking-backend-production.up.railway.app';

  static Future<List<MeetingRoom>> getMeetingRooms(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meeting-rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MeetingRoom.fromJson(json)).toList();
      } else {
        throw Exception('회의실 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
