import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable toast/snackbar helper for consistent styling across the app.
class AppToast {
  static void success(BuildContext context, String message) {
    _show(context, message, AppTheme.successGreen, Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppTheme.errorRed, Icons.error_outline);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppTheme.primaryBlue, Icons.info_outline);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, AppTheme.warningYellow, Icons.warning_amber);
  }

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
