import 'package:flutter/material.dart';

class AppBarLogoTitle extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final double logoSize;
  final double spacing;

  const AppBarLogoTitle({
    super.key,
    required this.title,
    this.style,
    this.logoSize = 24.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/app_logo.png',
          height: logoSize,
          width: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            title,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
