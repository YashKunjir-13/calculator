import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isBackspace = text == '⌫';
    final isAction = ['AC', 'CE', '%', '÷', '×', '−', '+', '='].contains(text);

    return GestureDetector(
      onTap: onPressed,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isBackspace
                ? Icon(
                    Icons.backspace,
                    color: Colors.grey[700],
                    size: 24,
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: isAction ? Colors.blue[900] : Colors.grey[800],
                      fontSize: 24,
                      fontWeight: isAction ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
