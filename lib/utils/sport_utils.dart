import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Helper utilities for sport-related display logic.
class SportUtils {
  /// Get the emoji for a sport.
  static String getEmoji(String sport) {
    switch (sport) {
      case 'Pickleball':
        return '🥒';
      case 'Badminton':
        return '🏸';
      case 'Table Tennis':
        return '🏓';
      default:
        return '🏆';
    }
  }

  /// All supported sports.
  static const List<String> allSports = [
    'Pickleball',
    'Badminton',
    'Table Tennis',
  ];

  /// Get availability display info for a player.
  static ({String text, Color color}) getAvailabilityStatus({
    required bool availableNow,
    String? lastActive,
  }) {
    if (availableNow) {
      return (text: 'Available Now', color: AppTheme.successGreen);
    } else if (lastActive == '15 min ago' ||
        lastActive == '2 min ago' ||
        lastActive == 'Just now') {
      return (text: 'Recently Active', color: AppTheme.textSecondary);
    } else {
      return (text: 'Inactive', color: AppTheme.textSecondary);
    }
  }

  /// Get the color for a match status tab.
  static Color getStatusColor(String status) {
    switch (status) {
      case 'accept':
      case 'pending':
        return AppTheme.acceptYellow;
      case 'to_log':
        return AppTheme.primaryOrange;
      case 'to_verify':
        return AppTheme.successGreen;
      case 'disputed':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  /// Get tag display info for social posts.
  static ({Color bgColor, Color iconColor, IconData icon}) getTagInfo(
      String tag) {
    switch (tag) {
      case 'highlight':
        return (
          bgColor: AppTheme.yellowLightBg,
          iconColor: AppTheme.warningYellow,
          icon: Icons.star,
        );
      case 'question':
        return (
          bgColor: AppTheme.blueLightBg,
          iconColor: AppTheme.primaryBlue,
          icon: Icons.help_outline,
        );
      default:
        return (
          bgColor: AppTheme.grayBg,
          iconColor: AppTheme.textSecondary,
          icon: Icons.chat_bubble_outline,
        );
    }
  }
}
