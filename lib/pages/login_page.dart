import 'package:flutter/material.dart';
import '../widgets/numeric_keypad.dart';
import '../models/login_dto.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _employeeNumberController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isPasswordField = false; // 현재 포커스가 비밀번호 필드인지 확인

  @override
  void dispose() {
    _employeeNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (key == 'EMP') {
      setState(() {
        if (_isPasswordField) {
          _passwordController.text += 'EMP';
        } else {
          _employeeNumberController.text += 'EMP';
        }
      });
    } else if (key == 'PASSWORD') {
      setState(() {
        if (_isPasswordField) {
          _passwordController.text += 'password';
        } else {
          _employeeNumberController.text += 'password';
        }
      });
    } else {
      setState(() {
        if (_isPasswordField) {
          if (_passwordController.text.length < 20) {
            _passwordController.text += key;
          }
        } else {
          if (_employeeNumberController.text.length < 10) {
            _employeeNumberController.text += key;
          }
        }
      });
    }
  }

  void _onDelete() {
    setState(() {
      if (_isPasswordField) {
        if (_passwordController.text.isNotEmpty) {
          _passwordController.text = _passwordController.text.substring(
            0,
            _passwordController.text.length - 1,
          );
        }
      } else {
        if (_employeeNumberController.text.isNotEmpty) {
          _employeeNumberController.text = _employeeNumberController.text
              .substring(0, _employeeNumberController.text.length - 1);
        }
      }
    });
  }

  void _onClear() {
    setState(() {
      _employeeNumberController.clear();
      _passwordController.clear();
    });
  }

  void _onTab() {
    setState(() {
      _isPasswordField = !_isPasswordField;
    });
  }

  void _onEnter() async {
    if (_employeeNumberController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사원번호와 비밀번호를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 로그인 API 호출
      final loginDto = LoginDto(
        employeeNumber: _employeeNumberController.text,
        password: _passwordController.text,
      );

      final response = await AuthService.login(loginDto);

      // 로그인 성공 시 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공! ${response.user.name}님 환영합니다.'),
            backgroundColor: Colors.green,
          ),
        );
        // TODO: 메인 페이지로 이동
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // 로고 또는 제목
            const Text(
              '회의실 예약 시스템',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),

            // 입력 필드들
            _buildInputFields(),
            const SizedBox(height: 30),

            // 키패드
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // 왼쪽 패널: 입력 필드
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 로고 또는 제목
                const Text(
                  '회의실 예약 시스템',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 40),

                // 입력 필드들
                _buildInputFields(),
              ],
            ),
          ),
        ),

        // 오른쪽 패널: 키패드
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'EMP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                _buildKeypad(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 사원번호 입력
        Text(
          '사원번호',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _isPasswordField ? Colors.grey : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPasswordField ? Colors.grey : Colors.blue,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _employeeNumberController,
            enabled: false, // 키패드로만 입력
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              hintText: '사원번호를 입력하세요',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 비밀번호 입력
        Text(
          '비밀번호',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _isPasswordField ? Colors.black87 : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPasswordField ? Colors.blue : Colors.grey,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            enabled: false, // 키패드로만 입력
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: '비밀번호를 입력하세요',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),

        // 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onEnter,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    return NumericKeypad(
      onKeyPressed: _onKeyPressed,
      onDelete: _onDelete,
      onClear: _onClear,
      onEnter: _onEnter,
      onTab: _onTab,
    );
  }
}
