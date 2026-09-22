import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_otp_input.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String email;

  const OtpPage({
    super.key,
    this.email = 'your email',
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  bool _isLoading = false;
  bool _isResending = false;
  String _otp = '';

  Future<void> _verifyOtp() async {
    if (_otp.length < 4 || _isLoading) return;
    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider.notifier);
    final success = await authService.verifyOtp(_otp);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account verified successfully!'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/');
      } else {
        final errorMessage = ref.read(authServiceProvider).errorMessage ??
            'Invalid or expired OTP code';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    final authService = ref.read(authServiceProvider.notifier);
    final success = await authService.resendOtp();

    if (mounted) {
      setState(() => _isResending = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new 6-digit code has been sent to your email.'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend code. Please try again later.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                'We\'ve sent a verification code to ${widget.email}.',
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 48),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AppOtpInput(
                  length: 6,
                  onCompleted: (otp) {
                    setState(() {
                      _otp = otp;
                    });
                    _verifyOtp();
                  },
                ),
              ),

              const SizedBox(height: 40),
              AppButton.primary(
                text: 'Verify Account',
                onPressed: _otp.length >= 4 && !_isLoading ? _verifyOtp : null,
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
                    onPressed: _isResending ? null : _resendOtp,
                    child: Text(
                      _isResending ? 'Sending...' : 'Resend',
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

