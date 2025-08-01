import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/booking.dart';

class SocketService {
  static const String baseUrl =
      'https://meeting-room-booking-backend-production.up.railway.app';

  IO.Socket? _socket;
  final StreamController<Booking> _bookingUpdateController =
      StreamController<Booking>.broadcast();
  final StreamController<Booking> _bookingCreatedController =
      StreamController<Booking>.broadcast();
  final StreamController<Booking> _bookingCancelledController =
      StreamController<Booking>.broadcast();

  Stream<Booking> get bookingUpdates => _bookingUpdateController.stream;
  Stream<Booking> get bookingCreated => _bookingCreatedController.stream;
  Stream<Booking> get bookingCancelled => _bookingCancelledController.stream;

  void connect() {
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
    });

    // 예약 업데이트 이벤트
    _socket!.on('booking-updated', (data) {
      print('Booking updated: $data');
      if (data is Map<String, dynamic>) {
        final booking = Booking.fromJson(data);
        _bookingUpdateController.add(booking);
      }
    });

    // 새 예약 생성 이벤트
    _socket!.on('booking-created', (data) {
      print('Booking created: $data');
      if (data is Map<String, dynamic>) {
        final booking = Booking.fromJson(data);
        _bookingCreatedController.add(booking);
      }
    });

    // 예약 취소 이벤트
    _socket!.on('booking-cancelled', (data) {
      print('Booking cancelled: $data');
      if (data is Map<String, dynamic>) {
        final booking = Booking.fromJson(data);
        _bookingCancelledController.add(booking);
      }
    });
  }

  void joinRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join-room', roomId);
      print('Joined room: $roomId');
    }
  }

  void leaveRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave-room', roomId);
      print('Left room: $roomId');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _bookingUpdateController.close();
    _bookingCreatedController.close();
    _bookingCancelledController.close();
  }

  bool get isConnected => _socket?.connected ?? false;
}
