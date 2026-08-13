import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  
  const AppLoadingIndicator({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.secondary, // Teal by default
        ),
      ),
    );
  }
}
