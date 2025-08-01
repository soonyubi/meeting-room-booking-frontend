import 'package:flutter/material.dart';
import '../models/meeting_room.dart';

class MeetingRoomCard extends StatelessWidget {
  final MeetingRoom meetingRoom;

  const MeetingRoomCard({super.key, required this.meetingRoom});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 회의실 이름과 상태
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meetingRoom.name,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: meetingRoom.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      meetingRoom.isActive ? '사용가능' : '사용불가',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 수용 인원
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: isMobile ? 16 : 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${meetingRoom.capacity}명 수용',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 설명
              Text(
                meetingRoom.description,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
