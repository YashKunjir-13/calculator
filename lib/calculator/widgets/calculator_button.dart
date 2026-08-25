import 'package:flutter/material.dart';

/// A reusable, styled button widget designed specifically for the calculator grid.
/// It renders as a circular button with custom styling based on whether it represents
/// a number, an operator/action, or a backspace action.
class CalculatorButton extends StatelessWidget {
  /// The label text of the button (e.g., '7', '+', 'AC', '⌫').
  final String text;

  /// The background color of the circular button.
  final Color backgroundColor;

  /// Callback function executed when the button is tapped.
  final VoidCallback? onPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the current button is the backspace button to render an icon instead of text.
    final isBackspace = text == '<x|';

    // Check if this button performs an arithmetic/calculator operation.
    // Operator/action buttons will receive distinct text coloring and font weights.
    final isAction = ['AC', 'CE', '%', '÷', '×', '−', '+', '='].contains(text);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final fontSize = (shortSide * 0.32).clamp(16.0, 40.0);
        final radius = (shortSide * 0.18).clamp(12.0, 28.0);

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(radius),
              child: Center(
                child: isBackspace
                    ? Icon(
                        Icons.backspace,
                        color: Colors.grey[700],
                        size: fontSize,
                      )
                    : Text(
                        text,
                        maxLines: 1,
                        style: TextStyle(
                          color: isAction
                              ? Colors.blue[900]
                              : Colors.grey[800],
                          fontSize: fontSize,
                          fontWeight: isAction
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
