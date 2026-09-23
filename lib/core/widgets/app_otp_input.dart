import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class AppOtpInput extends StatefulWidget {
  final int length;
  final void Function(String) onCompleted;
  final void Function(String)? onChanged;

  const AppOtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<AppOtpInput> createState() => _AppOtpInputState();
}

class _AppOtpInputState extends State<AppOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Handle pasting multi-digit code (e.g., 6 digits at once)
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (int i = 0; i < widget.length; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        }
      }
      final fullOtp = _controllers.map((c) => c.text).join();
      widget.onChanged?.call(fullOtp);
      if (fullOtp.length == widget.length) {
        _focusNodes.last.unfocus();
        widget.onCompleted(fullOtp);
      } else {
        final nextIdx = digits.length < widget.length ? digits.length : widget.length - 1;
        _focusNodes[nextIdx].requestFocus();
      }
      return;
    }

    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(otp);

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (otp.length == widget.length) {
          widget.onCompleted(otp);
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: widget.length > 4 ? 4 : 6),
            constraints: const BoxConstraints(maxWidth: 52, maxHeight: 58),
            child: AspectRatio(
              aspectRatio: 0.9,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(widget.length),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => _onChanged(value, index),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
