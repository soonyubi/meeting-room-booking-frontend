import 'package:flutter/material.dart';
import '../models/meeting_room.dart';
import '../models/booking.dart';
import '../models/login_dto.dart';
import '../services/booking_service.dart';
import '../services/socket_service.dart';

class MeetingRoomDetailPage extends StatefulWidget {
  final MeetingRoom meetingRoom;
  final LoginResponseDto loginResponse;

  const MeetingRoomDetailPage({
    super.key,
    required this.meetingRoom,
    required this.loginResponse,
  });

  @override
  State<MeetingRoomDetailPage> createState() => _MeetingRoomDetailPageState();
}

class _MeetingRoomDetailPageState extends State<MeetingRoomDetailPage> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  late SocketService _socketService;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _loadBookings();
    _setupSocket();
    _startTimer();
  }

  void _startTimer() {
    // 1분마다 현재 시간 업데이트
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _startTimer();
      }
    });
  }

  void _setupSocket() {
    _socketService.connect();
    _socketService.joinRoom(widget.meetingRoom.id.toString());

    // 실시간 업데이트 리스너
    _socketService.bookingCreated.listen((booking) {
      if (booking.meetingRoomId == widget.meetingRoom.id) {
        setState(() {
          _bookings.add(booking);
          _bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
        });
        _showNotification('새로운 예약이 생성되었습니다.');
      }
    });

    _socketService.bookingCancelled.listen((booking) {
      if (booking.meetingRoomId == widget.meetingRoom.id) {
        setState(() {
          _bookings.removeWhere((b) => b.id == booking.id);
        });
        _showNotification('예약이 취소되었습니다.');
      }
    });

    _socketService.bookingUpdates.listen((booking) {
      if (booking.meetingRoomId == widget.meetingRoom.id) {
        setState(() {
          final index = _bookings.indexWhere((b) => b.id == booking.id);
          if (index != -1) {
            _bookings[index] = booking;
            _bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
          }
        });
        _showNotification('예약이 업데이트되었습니다.');
      }
    });
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bookings = await BookingService.getBookingsByMeetingRoom(
        widget.meetingRoom.id,
        widget.loginResponse.accessToken,
      );

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getCurrentTimeString() {
    return '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
  }

  String _getCurrentDateString() {
    final months = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

    return '${months[_currentTime.month - 1]} ${_currentTime.day}일 ${weekdays[_currentTime.weekday - 1]}';
  }

  List<Booking> _getTodayBookings() {
    final today = DateTime.now();
    return _bookings.where((booking) {
      return booking.startTime.year == today.year &&
          booking.startTime.month == today.month &&
          booking.startTime.day == today.day;
    }).toList();
  }

  Booking? _getCurrentMeeting() {
    return _bookings.where((booking) {
      return booking.startTime.isBefore(_currentTime) &&
          booking.endTime.isAfter(_currentTime);
    }).firstOrNull;
  }

  List<Booking> _getUpcomingMeetings() {
    return _bookings.where((booking) {
      return booking.startTime.isAfter(_currentTime);
    }).toList();
  }

  @override
  void dispose() {
    _socketService.leaveRoom(widget.meetingRoom.id.toString());
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.meetingRoom.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBookings,
            tooltip: '새로고침',
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
              '예약 목록을 불러오는 중...',
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
              onPressed: _loadBookings,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // 상단: 회의실 정보 및 날짜/시간
        _buildHeader(),

        // 중앙: 예약 상태 및 시간표
        Expanded(
          child: Row(
            children: [
              // 왼쪽: 예약 상태 메시지
              Expanded(flex: 2, child: _buildStatusSection()),

              // 오른쪽: 시간표
              Expanded(flex: 1, child: _buildTimeSchedule()),
            ],
          ),
        ),

        // 하단: 예약 버튼
        _buildBookingButton(),
      ],
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(isMobile ? 16 : 24),
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 회의실 정보
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.meeting_room,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.meetingRoom.name,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.meetingRoom.capacity}석',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 날짜 및 시간
          Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _getCurrentDateString(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _getCurrentTimeString(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final todayBookings = _getTodayBookings();
    final currentMeeting = _getCurrentMeeting();
    final upcomingMeetings = _getUpcomingMeetings();

    return Container(
      margin: EdgeInsets.only(
        left: isMobile ? 16 : 24,
        right: isMobile ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 예약된 시간대 표시
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 20, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 예약',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (todayBookings.isEmpty)
                  Text(
                    '08:00 ~ 19:00 예약 없음',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    '${todayBookings.length}개의 예약이 있습니다',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 현재 진행 중인 회의
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 20,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '현재 진행 중',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (currentMeeting == null)
                  Text(
                    '현재 진행 중인 회의 없음',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    '${currentMeeting.title} (${_formatTime(currentMeeting.startTime)} ~ ${_formatTime(currentMeeting.endTime)})',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 이후 예약된 회의
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.upcoming, size: 20, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(
                      '이후 예약',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (upcomingMeetings.isEmpty)
                  Text(
                    '이후 예약된 회의 없음',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    '${upcomingMeetings.length}개의 예약이 있습니다',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSchedule() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final currentHour = _currentTime.hour;

    return Container(
      margin: EdgeInsets.only(
        left: isMobile ? 8 : 12,
        right: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간표 헤더
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  '시간표',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 시간표 내용
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                itemCount: 9, // 14:00 ~ 22:00 (9시간)
                itemBuilder: (context, index) {
                  final hour = 14 + index; // 14시부터 시작
                  final timeString = '${hour.toString().padLeft(2, '0')}:00';
                  final isCurrentHour = hour == currentHour;
                  final isPastHour = hour < currentHour;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCurrentHour
                              ? Colors.red[100]
                              : isPastHour
                              ? Colors.grey[100]
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          isCurrentHour
                              ? Border.all(color: Colors.red, width: 2)
                              : null,
                    ),
                    child: Row(
                      children: [
                        Text(
                          timeString,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight:
                                isCurrentHour
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isCurrentHour
                                    ? Colors.red[700]
                                    : isPastHour
                                    ? Colors.grey[500]
                                    : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (isCurrentHour)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '현재',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(isMobile ? 16 : 24),
      child: ElevatedButton(
        onPressed: () {
          // 예약 페이지로 이동하는 로직
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('예약 기능은 준비 중입니다.'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          '예약하기',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
