import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/biometric_service.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/pin_pad.dart';

class PinScreen extends ConsumerStatefulWidget {
  final bool isSettingPin;

  const PinScreen({
    super.key,
    this.isSettingPin = false,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  String? _firstPin; // For confirm PIN workflow when setting PIN
  String _errorMessage = '';
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    if (!widget.isSettingPin) {
      final security = ref.read(securitySettingsProvider);
      if (security.isBiometricsEnabled) {
        final available = await BiometricService.isBiometricsAvailable();
        if (mounted) setState(() => _canUseBiometrics = available);
        _authenticateBiometrics();
      }
    }
  }

  Future<void> _authenticateBiometrics() async {
    final authenticated = await BiometricService.authenticate();
    if (authenticated && mounted) {
      ref.read(authStateProvider.notifier).unlock();
      Navigator.pop(context);
    }
  }

  void _onPinEntered(String newPin) async {
    setState(() {
      _pin = newPin;
      _errorMessage = '';
    });

    if (newPin.length == 4) {
      final securityNotifier = ref.read(securitySettingsProvider.notifier);

      if (widget.isSettingPin) {
        if (_firstPin == null) {
          // Store first entry and ask for confirmation
          setState(() {
            _firstPin = newPin;
            _pin = '';
          });
        } else {
          // Confirm PIN
          if (_firstPin == newPin) {
            await securityNotifier.setPin(newPin);
            await securityNotifier.toggleAppLock(true);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN setup successfully! App lock enabled.')),
              );
              Navigator.pop(context);
            }
          } else {
            setState(() {
              _firstPin = null;
              _pin = '';
              _errorMessage = 'PINs did not match. Try again.';
            });
          }
        }
      } else {
        // Authenticate existing PIN
        final isValid = await securityNotifier.verifyPin(newPin);
        if (isValid && mounted) {
          ref.read(authStateProvider.notifier).unlock();
          Navigator.pop(context);
        } else {
          setState(() {
            _pin = '';
            _errorMessage = 'Incorrect PIN. Please try again.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title = widget.isSettingPin
        ? (_firstPin == null ? 'Set 4-Digit PIN' : 'Confirm 4-Digit PIN')
        : 'Enter Security PIN';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSettingPin
                    ? (_firstPin == null ? 'Choose a 4-digit PIN to secure your cashbook.' : 'Re-enter your 4-digit PIN to confirm.')
                    : 'Enter PIN to unlock Daily Cashbook',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: AppColors.cashOut, fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 20),
              PinPad(
                pin: _pin,
                onPinChanged: _onPinEntered,
                showBiometric: _canUseBiometrics && !widget.isSettingPin,
                onBiometricPressed: _authenticateBiometrics,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
