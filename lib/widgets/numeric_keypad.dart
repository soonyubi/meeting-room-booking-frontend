import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onEnter;
  final VoidCallback onTab;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onClear,
    required this.onEnter,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // 반응형 버튼 크기 계산
    final buttonSize = isMobile ? screenWidth * 0.15 : 70.0;
    final buttonHeight = isMobile ? 50.0 : 60.0;
    final fontSize = isMobile ? 16.0 : 20.0;
    final actionFontSize = isMobile ? 12.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        children: [
          // 첫 번째 행: EMP, 숫자 1-2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionKey(
                'EMP',
                () => onKeyPressed('EMP'),
                Colors.green,
                buttonSize,
                buttonHeight,
                actionFontSize,
              ),
              _buildKey('1', buttonSize, buttonHeight, fontSize),
              _buildKey('2', buttonSize, buttonHeight, fontSize),
            ],
          ),
          SizedBox(height: isMobile ? 4 : 8),
          // 두 번째 행: 숫자 3-5
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('3', buttonSize, buttonHeight, fontSize),
              _buildKey('4', buttonSize, buttonHeight, fontSize),
              _buildKey('5', buttonSize, buttonHeight, fontSize),
            ],
          ),
          SizedBox(height: isMobile ? 4 : 8),
          // 세 번째 행: 숫자 6-8
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('6', buttonSize, buttonHeight, fontSize),
              _buildKey('7', buttonSize, buttonHeight, fontSize),
              _buildKey('8', buttonSize, buttonHeight, fontSize),
            ],
          ),
          SizedBox(height: isMobile ? 4 : 8),
          // 네 번째 행: 숫자 9, 0, TAB
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('9', buttonSize, buttonHeight, fontSize),
              _buildKey('0', buttonSize, buttonHeight, fontSize),
              _buildActionKey(
                'TAB',
                onTab,
                Colors.purple,
                buttonSize,
                buttonHeight,
                actionFontSize,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 4 : 8),
          // 다섯 번째 행: Clear, Delete, Enter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionKey(
                'CLEAR',
                onClear,
                Colors.orange,
                buttonSize,
                buttonHeight,
                actionFontSize,
              ),
              _buildActionKey(
                'DEL',
                onDelete,
                Colors.red,
                buttonSize,
                buttonHeight,
                actionFontSize,
              ),
              _buildActionKey(
                'ENTER',
                onEnter,
                Colors.blue,
                buttonSize,
                buttonHeight,
                actionFontSize,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 16),
          // 여섯 번째 행: PASSWORD 버튼 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionKey(
                'PASSWORD',
                () => onKeyPressed('PASSWORD'),
                Colors.teal,
                buttonSize * 2.5,
                buttonHeight,
                actionFontSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key, double size, double height, double fontSize) {
    return SizedBox(
      width: size,
      height: height,
      child: ElevatedButton(
        onPressed: () => onKeyPressed(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Text(
            key,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(
    String text,
    VoidCallback onPressed,
    Color color,
    double size,
    double height,
    double fontSize,
  ) {
    return SizedBox(
      width: size,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
