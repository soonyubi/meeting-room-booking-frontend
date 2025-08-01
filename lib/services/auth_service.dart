import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_dto.dart';

class AuthService {
  static const String baseUrl =
      'https://meeting-room-booking-backend-production.up.railway.app';

  static Future<LoginResponseDto> login(LoginDto loginDto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginDto.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponseDto.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
