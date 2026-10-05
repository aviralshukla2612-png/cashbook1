import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PinPad extends StatelessWidget {
  final String pin;
  final ValueChanged<String> onPinChanged;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const PinPad({
    super.key,
    required this.pin,
    required this.onPinChanged,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  void _onKeyPress(String digit) {
    if (pin.length < 4) {
      onPinChanged(pin + digit);
    }
  }

  void _onBackspace() {
    if (pin.isNotEmpty) {
      onPinChanged(pin.substring(0, pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // 4 PIN Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
            );
          }),
        ),
        const SizedBox(height: 36),

        // Keypad Grid
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKey(context, '1'),
                _buildKey(context, '2'),
                _buildKey(context, '3'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKey(context, '4'),
                _buildKey(context, '5'),
                _buildKey(context, '6'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKey(context, '7'),
                _buildKey(context, '8'),
                _buildKey(context, '9'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                showBiometric
                    ? IconButton(
                        onPressed: onBiometricPressed,
                        icon: const Icon(Icons.fingerprint, size: 32, color: AppColors.primary),
                        padding: const EdgeInsets.all(20),
                      )
                    : const SizedBox(width: 72, height: 72),
                _buildKey(context, '0'),
                IconButton(
                  onPressed: _onBackspace,
                  icon: const Icon(Icons.backspace_outlined, size: 26),
                  padding: const EdgeInsets.all(20),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(BuildContext context, String digit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onKeyPress(digit),
          child: Center(
            child: Text(
              digit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
