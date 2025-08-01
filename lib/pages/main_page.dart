import 'package:flutter/material.dart';
import '../models/meeting_room.dart';
import '../models/login_dto.dart';
import '../services/meeting_room_service.dart';
import '../widgets/meeting_room_card.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  final LoginResponseDto loginResponse;

  const MainPage({super.key, required this.loginResponse});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<MeetingRoom> _meetingRooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMeetingRooms();
  }

  Future<void> _loadMeetingRooms() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final meetingRooms = await MeetingRoomService.getMeetingRooms(
        widget.loginResponse.accessToken,
      );

      setState(() {
        _meetingRooms = meetingRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onLogout() {
    // 로그아웃 처리 - 로그인 페이지로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // 모든 이전 페이지 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '회의실 예약 시스템',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          // 사용자 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.white,
                  size: isMobile ? 18 : 20,
                ),
                const SizedBox(width: 8),
                if (!isMobile)
                  Text(
                    '${widget.loginResponse.user.name}님',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _onLogout,
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '회의실 목록을 불러오는 중...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMeetingRooms,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return _buildMeetingRoomList();
  }

  Widget _buildMeetingRoomList() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      children: [
        // 헤더
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '회의실 목록',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_meetingRooms.length}개의 회의실이 있습니다',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // 회의실 목록
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: isMobile ? 0 : 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.2 : 1.1,
              ),
              itemCount: _meetingRooms.length,
              itemBuilder: (context, index) {
                final meetingRoom = _meetingRooms[index];
                return MeetingRoomCard(meetingRoom: meetingRoom);
              },
            ),
          ),
        ),
      ],
    );
  }
}
