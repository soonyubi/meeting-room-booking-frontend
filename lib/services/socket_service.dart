import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/booking.dart';

class SocketService {
  static const String baseUrl =
      'https://meeting-room-booking-backend-production.up.railway.app';

  // 싱글톤 패턴
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentRoomId;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  int _connectionCount = 0; // 연결 횟수 추적

  final StreamController<Booking> _bookingUpdateController =
      StreamController<Booking>.broadcast();
  final StreamController<Booking> _bookingCreatedController =
      StreamController<Booking>.broadcast();
  final StreamController<Booking> _bookingCancelledController =
      StreamController<Booking>.broadcast();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<Booking> get bookingUpdates => _bookingUpdateController.stream;
  Stream<Booking> get bookingCreated => _bookingCreatedController.stream;
  Stream<Booking> get bookingCancelled => _bookingCancelledController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  void connect() {
    try {
      if (_socket != null && _socket!.connected) {
        print('Socket already connected (connection #$_connectionCount)');
        if (!_connectionStatusController.isClosed) {
          _connectionStatusController.add(true);
        }
        return;
      }

      if (_isConnecting) {
        print('Socket connection already in progress');
        return;
      }

      _connectionCount++;
      _isConnecting = true;
      print('Connecting to socket server... (attempt #$_connectionCount)');

      // 이전 소켓이 있다면 완전히 정리
      if (_socket != null) {
        try {
          _socket!.disconnect();
        } catch (e) {
          print('Error cleaning up previous socket: $e');
        }
        _socket = null;
      }

      // 약간의 딜레이 후 연결 (서버 정리 시간 확보)
      Future.delayed(const Duration(milliseconds: 100), () {
        _socket = IO.io(baseUrl, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true,
          'reconnection': true,
          'reconnectionAttempts': 5,
          'reconnectionDelay': 1000,
          'timeout': 20000,
        });

        _setupEventListeners();
      });
    } catch (e) {
      print('Error creating socket connection: $e');
      _isConnecting = false;
      if (!_connectionStatusController.isClosed) {
        _connectionStatusController.add(false);
      }
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    try {
      _socket!.onConnect((_) {
        print('Socket connected successfully');
        _isConnecting = false;
        if (!_connectionStatusController.isClosed) {
          _connectionStatusController.add(true);
        }

        // 연결 후 이전에 입장했던 방이 있다면 재입장
        if (_currentRoomId != null) {
          joinRoom(_currentRoomId!);
        }
      });

      _socket!.onDisconnect((_) {
        print('Socket disconnected');
        _isConnecting = false;
        if (!_connectionStatusController.isClosed) {
          _connectionStatusController.add(false);
        }
      });

      _socket!.onConnectError((error) {
        print('Socket connection error: $error');
        _isConnecting = false;
        if (!_connectionStatusController.isClosed) {
          _connectionStatusController.add(false);
        }

        // 연결 실패 시 재시도
        _scheduleReconnect();
      });

      _socket!.onReconnect((_) {
        print('Socket reconnected');
        if (!_connectionStatusController.isClosed) {
          _connectionStatusController.add(true);
        }

        // 재연결 후 방 재입장
        if (_currentRoomId != null) {
          joinRoom(_currentRoomId!);
        }
      });

      // 예약 업데이트 이벤트
      _socket!.on('booking-updated', (data) {
        print('Booking updated: $data');
        if (data is Map<String, dynamic>) {
          try {
            final booking = Booking.fromJson(data);
            if (!_bookingUpdateController.isClosed) {
              _bookingUpdateController.add(booking);
            }
          } catch (e) {
            print('Error parsing booking update: $e');
          }
        }
      });

      // 새 예약 생성 이벤트
      _socket!.on('booking-created', (data) {
        print('Booking created: $data');
        if (data is Map<String, dynamic>) {
          try {
            final booking = Booking.fromJson(data);
            if (!_bookingCreatedController.isClosed) {
              _bookingCreatedController.add(booking);
            }
          } catch (e) {
            print('Error parsing booking created: $e');
          }
        }
      });

      // 예약 취소 이벤트
      _socket!.on('booking-cancelled', (data) {
        print('Booking cancelled: $data');
        if (data is Map<String, dynamic>) {
          try {
            final booking = Booking.fromJson(data);
            if (!_bookingCancelledController.isClosed) {
              _bookingCancelledController.add(booking);
            }
          } catch (e) {
            print('Error parsing booking cancelled: $e');
          }
        }
      });
    } catch (e) {
      print('Error setting up event listeners: $e');
      _isConnecting = false;
      if (!_connectionStatusController.isClosed) {
        _connectionStatusController.add(false);
      }
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
    }

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      print('Attempting to reconnect...');
      connect();
    });
  }

  void joinRoom(String roomId) {
    if (_socket == null || !_socket!.connected) {
      print('Cannot join room: socket not connected');
      _currentRoomId = roomId; // 연결 후 자동 입장을 위해 저장
      return;
    }

    _currentRoomId = roomId;
    _socket!.emit('join-room', roomId);
    print('Joined room: $roomId');
  }

  void leaveRoom(String roomId) {
    if (_socket == null || !_socket!.connected) {
      print('Cannot leave room: socket not connected');
      return;
    }

    _socket!.emit('leave-room', roomId);
    print('Left room: $roomId');

    if (_currentRoomId == roomId) {
      _currentRoomId = null;
    }
  }

  void disconnect() {
    print('Disconnecting socket...');

    // 재연결 타이머 취소
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // 방에서 나가기 (소켓이 연결되어 있을 때만)
    if (_currentRoomId != null && _socket != null) {
      try {
        if (_socket!.connected) {
          _socket!.emit('leave-room', _currentRoomId);
          print('Left room: $_currentRoomId');
        }
      } catch (e) {
        print('Error leaving room: $e');
      }
    }

    // 이벤트 리스너 제거
    if (_socket != null) {
      try {
        _socket!.clearListeners();
      } catch (e) {
        print('Error clearing listeners: $e');
        // clearListeners가 실패하면 개별적으로 제거 시도
        try {
          _socket!.off('booking-updated');
          _socket!.off('booking-created');
          _socket!.off('booking-cancelled');
        } catch (e2) {
          print('Error removing individual listeners: $e2');
        }
      }
    }

    // 연결 상태를 먼저 false로 설정
    try {
      if (!_connectionStatusController.isClosed) {
        _connectionStatusController.add(false);
      }
    } catch (e) {
      print('Error updating connection status: $e');
    }

    // 소켓 연결 해제
    try {
      _socket?.disconnect();
    } catch (e) {
      print('Error disconnecting socket: $e');
    }

    // 상태 초기화
    _socket = null;
    _currentRoomId = null;
    _isConnecting = false;
  }

  void dispose() {
    print('Disposing SocketService...');

    // 소켓 연결만 해제 (싱글톤이므로 스트림 컨트롤러는 유지)
    disconnect();

    print('SocketService disposed successfully');
  }

  // 앱 종료 시에만 호출되는 완전한 정리 메서드
  void shutdown() {
    print('Shutting down SocketService...');

    disconnect();

    // 스트림 컨트롤러들을 안전하게 정리
    _closeStreamController(_bookingUpdateController, 'bookingUpdate');
    _closeStreamController(_bookingCreatedController, 'bookingCreated');
    _closeStreamController(_bookingCancelledController, 'bookingCancelled');
    _closeStreamController(_connectionStatusController, 'connectionStatus');

    print('SocketService shutdown successfully');
  }

  void _closeStreamController(StreamController controller, String name) {
    try {
      if (!controller.isClosed) {
        controller.close();
        print('$name controller closed');
      }
    } catch (e) {
      print('Error closing $name controller: $e');
    }
  }

  bool get isConnected => _socket?.connected ?? false;
  bool get isConnecting => _isConnecting;
  String? get currentRoomId => _currentRoomId;
}
