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

    return GestureDetector(
      onTap: onPressed, // Triggers parent callback when tapped
      child: AspectRatio(
        // Forces a 1:1 width-to-height ratio so that the button stays a perfect
        // square area, which allows BoxShape.circle to form a perfect circle.
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle, // Clips the container to a circular shape
            boxShadow: const [
              // Subtle shadow underneath the button to create a premium, elevated feel
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            // If it's a backspace button, render a backspace icon.
            // Otherwise, render the label text with custom typography rules.
            child: isBackspace
                ? Icon(Icons.backspace, color: Colors.grey[700], size: 25)
                : Text(
                    text,
                    style: TextStyle(
                      // Action buttons use dark blue text, while numbers use standard grey text
                      color: isAction ? Colors.blue[900] : Colors.grey[800],
                      fontSize: 25,
                      fontWeight: isAction ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
