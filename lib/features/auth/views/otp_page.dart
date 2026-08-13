import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_otp_input.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool _isLoading = false;
  String _otp = '';

  void _verifyOtp() {
    if (_otp.length == 4) {
      setState(() => _isLoading = true);
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to Shell or success
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verify your email',
                style: AppTypography.headlineLg,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a 4-digit verification code to hello@example.com.',
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AppOtpInput(
                  length: 4,
                  onCompleted: (otp) {
                    setState(() {
                      _otp = otp;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 40),
              AppButton.primary(
                text: 'Verify Account',
                onPressed: _otp.length == 4 ? _verifyOtp : null,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () {
                      // Resend logic
                    },
                    child: Text(
                      'Resend',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
