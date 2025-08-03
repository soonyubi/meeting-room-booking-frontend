import 'package:flutter/material.dart';
import '../widgets/numeric_keypad.dart';
import '../models/login_dto.dart';
import '../services/auth_service.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _employeeNumberController =
      TextEditingController();
  bool _isLoading = false;
  String _selectedDepartment = '';

  @override
  void dispose() {
    _employeeNumberController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (key == 'GP' || key == 'BP' || key == 'IT') {
      setState(() {
        _selectedDepartment = key;
        // 기존 입력값이 있으면 prefix만 변경
        String currentNumber = _employeeNumberController.text;
        if (currentNumber.length > 2) {
          _employeeNumberController.text = key + currentNumber.substring(2);
        } else {
          _employeeNumberController.text = key;
        }
      });
    } else if (key == '←') {
      setState(() {
        if (_employeeNumberController.text.isNotEmpty) {
          _employeeNumberController.text = _employeeNumberController.text
              .substring(0, _employeeNumberController.text.length - 1);
        }
      });
    } else if (key == '확인') {
      _onEnter();
    } else {
      setState(() {
        // 부서 코드가 선택되지 않았으면 GP를 기본값으로 설정
        if (_selectedDepartment.isEmpty) {
          _selectedDepartment = 'GP';
        }

        // 부서 코드 + 숫자 조합으로 입력
        String currentText = _employeeNumberController.text;
        if (currentText.length < 2) {
          _employeeNumberController.text = _selectedDepartment + key;
        } else {
          _employeeNumberController.text = currentText + key;
        }
      });
    }
  }

  void _onDelete() {
    setState(() {
      if (_employeeNumberController.text.isNotEmpty) {
        _employeeNumberController.text = _employeeNumberController.text
            .substring(0, _employeeNumberController.text.length - 1);
      }
    });
  }

  void _onClear() {
    setState(() {
      _employeeNumberController.clear();
      _selectedDepartment = '';
    });
  }

  void _onEnter() async {
    if (_employeeNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사원번호를 입력해주세요.'),
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
      final loginDto = LoginDto(employeeNumber: _employeeNumberController.text);

      final response = await AuthService.login(loginDto);

      // 로그인 성공 시 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공! ${response.user.name}님 환영합니다.'),
            backgroundColor: Colors.green,
          ),
        );
        // 메인 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainPage(loginResponse: response),
          ),
        );
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // 상단 여백
        const SizedBox(height: 20),

        // 사원번호 입력창
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '사원번호 입력',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // 입력창
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _employeeNumberController.text.isEmpty
                        ? '사원번호를 입력하세요'
                        : _employeeNumberController.text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          _employeeNumberController.text.isEmpty
                              ? Colors.grey
                              : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 부서 코드 버튼들
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildDepartmentButton('GP', Colors.blue),
              const SizedBox(width: 10),
              _buildDepartmentButton('BP', Colors.green),
              const SizedBox(width: 10),
              _buildDepartmentButton('IT', Colors.orange),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 키패드
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildKeypad(),
          ),
        ),

        // 하단 버튼
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      // 취소 로직
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onEnter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // 상단 여백
        const SizedBox(height: 40),

        // 메인 컨텐츠
        Expanded(
          child: Row(
            children: [
              // 좌측: 사원번호 입력창 + 안내문구
              Expanded(flex: 1, child: _buildLeftPanel()),

              // 우측: 키패드
              Expanded(flex: 1, child: _buildKeypad()),
            ],
          ),
        ),

        // 하단 버튼들
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildLeftPanel() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사원번호 입력창
          const Text(
            '사원번호 입력',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // 입력창
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _employeeNumberController.text.isEmpty
                    ? '사원번호를 입력하세요'
                    : _employeeNumberController.text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      _employeeNumberController.text.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 안내 문구
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '안내사항',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '1. 카드가 없을 경우 사원번호를 사용하여 로그인합니다.\n'
                  '2. 사원번호를 입력해 주시기 바랍니다.\n'
                  '3. 모든 예약을 마치면 자동으로 로그아웃됩니다.\n'
                  '4. 60초 동안 아무런 터치가 없으면 자동으로 홈으로 이동합니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // 부서 코드 버튼들 (데스크톱에서만 표시)
          if (MediaQuery.of(context).size.width >= 768)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDepartmentButton('GP', Colors.blue),
                _buildDepartmentButton('BP', Colors.green),
                _buildDepartmentButton('IT', Colors.orange),
              ],
            ),

          if (MediaQuery.of(context).size.width >= 768)
            const SizedBox(height: 20),

          // 숫자 키패드
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1-2-3
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildNumericKey('1')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumericKey('2')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumericKey('3')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 4-5-6
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildNumericKey('4')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumericKey('5')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumericKey('6')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 7-8-9
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildNumericKey('7')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumericKey('8')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumericKey('9')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 0-←-확인
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildNumericKey('0')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildActionKey('←', _onDelete)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildConfirmKey()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentButton(String department, Color color) {
    bool isSelected = _selectedDepartment == department;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        height: 50,
        child: ElevatedButton(
          onPressed: () => _onKeyPressed(department),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color : Colors.grey.shade300,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            department,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKey(String number) {
    return ElevatedButton(
      onPressed: () => _onKeyPressed(number),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionKey(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildConfirmKey() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _onEnter,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
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
                '확인',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 취소 버튼
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(right: 10),
              child: ElevatedButton(
                onPressed: () {
                  // 취소 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // 로그인 버튼
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(left: 10),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onEnter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
