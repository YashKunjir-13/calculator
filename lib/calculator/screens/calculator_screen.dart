import 'package:calculator/calculator/utils/calculator_expression_evaluator.dart';
import 'package:calculator/calculator/widgets/calculator_button.dart';
import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorExpressionEvaluator _evaluator = CalculatorExpressionEvaluator();
  String _display = '0';
  String _expression = '';
  bool _shouldResetDisplay = false;

  final List<List<String>> _buttons = const [
    ['AC', 'CE', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '•', '⌫', '='],
  ];

  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'AC':
          _display = '0';
          _expression = '';
          _shouldResetDisplay = false;
          break;
        case 'CE':
          _display = '0';
          _shouldResetDisplay = false;
          break;
        case '=':
          _calculateResult();
          break;
        case '⌫':
          _onBackspace();
          break;
        case '÷':
        case '×':
        case '−':
        case '+':
        case '%':
          _handleOperator(buttonText);
          break;
        case '•':
          _handleDecimal();
          break;
        default:
          _handleNumber(buttonText);
      }
    });
  }

  void _handleNumber(String number) {
    if (_shouldResetDisplay) {
      _display = number;
      _shouldResetDisplay = false;
    } else {
      if (_display == '0') {
        _display = number;
      } else {
        _display += number;
      }
    }
  }

  void _handleOperator(String operator) {
    if (_display != '0' || !_shouldResetDisplay) {
      _expression += _display;
    }
    _expression += _getOperatorSymbol(operator);
    _shouldResetDisplay = true;
  }

  void _handleDecimal() {
    if (!_display.contains('.')) {
      _display += '.';
    }
  }

  String _getOperatorSymbol(String displayOperator) {
    switch (displayOperator) {
      case '÷': return '/';
      case '×': return '*';
      case '−': return '-';
      case '+': return '+';
      case '%': return '%';
      default: return displayOperator;
    }
  }

  void _calculateResult() {
    try {
      _expression += _display;
      final result = _evaluator.evaluate(_expression);
      _display = _formatResult(result);
      _expression = '';
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _expression = '';
      _shouldResetDisplay = true;
    }
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      String formatted = result.toStringAsFixed(8);
      while (formatted.endsWith('0') && formatted.contains('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
      return formatted;
    }
  }

  void _onBackspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
  }

  Color _getButtonColor(String text) {
    if (text == 'AC') return Colors.purple[200]!;
    if (text == 'CE') return Colors.orange[200]!;
    if (['%', '÷', '×', '−', '+', '='].contains(text)) return Colors.blue[200]!;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display Area (takes up remaining vertical space dynamically)
              Expanded(
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _expression,
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _display,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Button Grid Layout
              Column(
                children: _buttons.map((row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((text) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: CalculatorButton(
                            text: text,
                            backgroundColor: _getButtonColor(text),
                            onPressed: () => _onButtonPressed(text),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
