import 'package:calculator/calculator/utils/calculator_expression_evaluator.dart';
import 'package:calculator/calculator/widgets/calculator_button.dart';
import 'package:flutter/material.dart';

/// The main screen of the calculator application containing the display panel and the keypad grid.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Evaluates mathematical string expressions (e.g., "7+5*3") into numerical results.
  final CalculatorExpressionEvaluator _evaluator =
      CalculatorExpressionEvaluator();

  // The primary text shown on the calculator display (current operand or final result).
  String _display = '0';

  // The history/running formula expression shown in smaller text above the main display (e.g., "12+").
  String _expression = '';

  // Flag indicating if the next number input should replace the current display rather than append.
  // This happens right after pressing an operator or the equals button.
  bool _shouldResetDisplay = false;

  // The 2D matrix structure representing the layout configuration of the calculator buttons.
  final List<List<String>> _buttons = const [
    ['AC', 'CE', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '•', '<x|', '='],
  ];

  /// Handles incoming button clicks and routes them to the correct action.
  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'AC': // All Clear: Resets the entire state
          _display = '0';
          _expression = '';
          _shouldResetDisplay = false;
          break;
        case 'CE': // Clear Entry: Resets only the active display operand
          _display = '0';
          _shouldResetDisplay = false;
          break;
        case '=': // Compute the final expression
          _calculateResult();
          break;
        case '<x|': // Backspace: deletes the last input digit
          _onBackspace();
          break;
        case '÷':
        case '×':
        case '−':
        case '+':
        case '%': // Operators: commits active display to the running expression
          _handleOperator(buttonText);
          break;
        case '•': // Decimal separator
          _handleDecimal();
          break;
        default: // Numeric buttons
          _handleNumber(buttonText);
      }
    });
  }

  /// Handles numeric key presses and updates the display text.
  void _handleNumber(String number) {
    if (_shouldResetDisplay) {
      // Overwrite the screen if we just clicked an operator/equals
      _display = number;
      _shouldResetDisplay = false;
    } else {
      // Append number digits, or replace default '0' initial state
      if (_display == '0') {
        _display = number;
      } else {
        _display += number;
      }
    }
  }

  /// Appends the active display and operator to the running formula expression.
  void _handleOperator(String operator) {
    if (_display != '0' || !_shouldResetDisplay) {
      _expression += _display;
    }
    // Convert display operators (like '×') to code parser operators (like '*')
    _expression += _getOperatorSymbol(operator);
    // Mark screen to be cleared/overwritten on the next digit entry
    _shouldResetDisplay = true;
  }

  /// Safe insertion of a decimal separator, preventing duplicates in the current input.
  void _handleDecimal() {
    if (!_display.contains('.')) {
      _display += '.';
    }
  }

  /// Maps display symbols to standard mathematical operators for the expression evaluator.
  String _getOperatorSymbol(String displayOperator) {
    switch (displayOperator) {
      case '÷':
        return '/';
      case '×':
        return '*';
      case '−':
        return '-';
      case '+':
        return '+';
      case '%':
        return '%';
      default:
        return displayOperator;
    }
  }

  /// Evaluates the complete accumulated expression and presents the result.
  void _calculateResult() {
    try {
      // Append the final current operand to complete the expression string
      _expression += _display;

      // Perform math evaluation
      final result = _evaluator.evaluate(_expression);

      // Format the result to eliminate trailing zeros or scientific formats
      _display = _formatResult(result);
      _expression = '';
      _shouldResetDisplay = true;
    } catch (e) {
      // Handle syntax or mathematical runtime evaluation errors gracefully
      _display = 'Error';
      _expression = '';
      _shouldResetDisplay = true;
    }
  }

  /// Formats the floating point mathematical result into a clean, reader-friendly string.
  String _formatResult(double result) {
    // If it's a whole integer, strip the '.0' decimal representation
    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      // Otherwise, restrict to a maximum of 8 decimal places and strip trailing zeros
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

  /// Removes the last digit from the display (backspace logic).
  void _onBackspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0'; // Reverts to '0' if all digits are deleted
    }
  }

  /// Helper defining dynamic background colors for button classification categories.
  Color _getButtonColor(String text) {
    if (text == 'AC') return const Color.fromARGB(255, 242, 239, 235);
    if (text == 'CE') return const Color.fromARGB(255, 238, 233, 225);
    if (['%', '÷', '×', '−', '+', '='].contains(text)) {
      return Colors.orange[500]!;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        39,
        46,
        39,
      ), // Minty green page background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Scale padding with the smaller screen dimension so large
            // desktop windows get breathing room without shrinking the
            // grid, while small phone screens stay tight.
            final shortestSide = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            final padding = (shortestSide * 0.03).clamp(8.0, 32.0);

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  // DISPLAY AREA:
                  // Wrapped in Expanded so it occupies all available screen height
                  // that remains after constructing the button grid below.
                  Expanded(
                    flex: 2,
                    child: LayoutBuilder(
                      builder: (context, displayConstraints) {
                        // Base display font sizes on the panel's own height so
                        // they visibly grow on large desktop windows instead of
                        // staying phone-sized (FittedBox below only ever shrinks).
                        final expressionFontSize = (displayConstraints
                                    .maxHeight *
                                0.14)
                            .clamp(16.0, 40.0);
                        final resultFontSize = (displayConstraints.maxHeight *
                                0.32)
                            .clamp(32.0, 96.0);

                        return Container(
                          alignment:
                              Alignment.bottomRight, // Aligns content to bottom-right
                          padding: EdgeInsets.all(padding * 1.5),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 73, 71, 71),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Renders the running algebraic expression history (e.g. 5+3)
                              // Wrapped in Expanded so its allotted space is always
                              // bounded by the panel height, regardless of the
                              // computed font size — FittedBox then only ever
                              // shrinks to fit, which guarantees no overflow.
                              Expanded(
                                flex: 2,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _expression,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: expressionFontSize,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Renders the active number input or calculation result
                              Expanded(
                                flex: 5,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _display,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: resultFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        221,
                                        253,
                                        249,
                                        249,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BUTTON GRID LAYOUT:
                  // Maps the 2D button list blueprint into Columns, Rows, and individual Expanded items.
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: _buttons.map((row) {
                        return Expanded(
                          child: Row(
                            children: row.map((text) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    padding < 16 ? 3 : 6,
                                  ),
                                  child: CalculatorButton(
                                    text: text,
                                    backgroundColor: _getButtonColor(text),
                                    onPressed: () => _onButtonPressed(text),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
