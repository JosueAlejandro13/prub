import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../theme/app_theme.dart';

enum _SnackBarType { success, error, info }

class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, _SnackBarType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, _SnackBarType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, _SnackBarType.info);
  }

  static void _show(BuildContext context, String message, _SnackBarType type) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    showTopSnackBar(
      overlay,
      _ApplePillWidget(message: message, type: type),
      displayDuration: const Duration(milliseconds: 2800),
      animationDuration: const Duration(milliseconds: 350),
      reverseAnimationDuration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
  }
}

class _ApplePillWidget extends StatelessWidget {
  final String message;
  final _SnackBarType type;

  const _ApplePillWidget({
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final IconData icon;
    final Color iconColor;

    switch (type) {
      case _SnackBarType.success:
        icon = Icons.check_circle_rounded;
        iconColor = isDark ? AppTheme.portalGreen : AppTheme.primaryGreen;
        break;
      case _SnackBarType.error:
        icon = Icons.error_rounded;
        iconColor = Colors.redAccent;
        break;
      case _SnackBarType.info:
        icon = Icons.info_rounded;
        iconColor = isDark ? AppTheme.portalGreen : AppTheme.accentCyan;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
