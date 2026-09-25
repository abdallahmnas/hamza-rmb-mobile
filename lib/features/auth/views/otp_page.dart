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
    if (_otp.length < 6 || _isLoading) return;
    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider.notifier);
    final success = await authService.verifyOtp(
      email: widget.email,
      otp: _otp,
    );

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
    final success = await authService.resendOtp(email: widget.email);

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Verify your email',
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Enter the 6-digit verification code sent to\n',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 6-digit responsive OTP box row
              AppOtpInput(
                length: 6,
                onChanged: (otp) {
                  setState(() {
                    _otp = otp;
                  });
                },
                onCompleted: (otp) {
                  setState(() {
                    _otp = otp;
                  });
                  _verifyOtp();
                },
              ),

              const SizedBox(height: 36),
              AppButton.primary(
                text: 'Verify Account',
                onPressed: _otp.length == 6 && !_isLoading ? _verifyOtp : null,
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
                      _isResending ? 'Sending...' : 'Resend Code',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w800,
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
