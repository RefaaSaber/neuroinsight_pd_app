// The app's reusable brand mark widget (logo badge).
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The app's brand mark — a rounded-square badge with a brain/psychology
/// icon. Matches the web portal's `_BrandMark` (same icon, same shape),
/// so the mobile app and the web portal read as one product.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.onDark = false, this.size = 44});

  /// true draws a white badge with a navy icon (for use on a navy
  /// background); false draws a navy badge with a white icon.
  final bool onDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onDark ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Icon(
        Icons.psychology_outlined,
        size: size * 0.58,
        color: onDark ? AppColors.primary : Colors.white,
      ),
    );
  }
}
