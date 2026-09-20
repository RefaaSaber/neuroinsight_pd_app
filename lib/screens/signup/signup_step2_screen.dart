import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/signup_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/signup_header.dart';
import 'signup_step3_screen.dart';

/// Frame 4 — Sign Up Step 2 of 3: Verify Your Number (OTP).
class SignUpStep2Screen extends StatefulWidget {
  final SignupData data;
  const SignUpStep2Screen({super.key, required this.data});

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final List<TextEditingController> _digits = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsLeft = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digits) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SignUpHeader(step: 2, onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter Verification Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'A 6-digit code was sent to your phone number\n${widget.data.phone}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 44,
                          height: 52,
                          child: TextField(
                            controller: _digits[i],
                            focusNode: _focusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(counterText: ''),
                            onChanged: (value) {
                              if (value.isNotEmpty && i < 5) {
                                _focusNodes[i + 1].requestFocus();
                              } else if (value.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Resend code in $minutes:$seconds', style: const TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: _secondsLeft == 0 ? _startTimer : null,
                          child: const Text('Resend'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SignUpStep3Screen(data: widget.data)),
                      ),
                      child: const Text('Verify & Continue'),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('← Back to previous step'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}