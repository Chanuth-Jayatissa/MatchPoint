import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/supabase_config.dart';

/// Settings modal — availability, notifications, GPS, map visibility, sign out, delete.
class SettingsModal extends StatefulWidget {
  final bool availableNow;
  final bool notificationsEnabled;
  final bool gpsEnabled;
  final bool hideFromMap;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onGpsChanged;
  final ValueChanged<bool> onHideFromMapChanged;
  final VoidCallback onSignOut;

  const SettingsModal({
    super.key,
    required this.availableNow,
    required this.notificationsEnabled,
    required this.gpsEnabled,
    required this.hideFromMap,
    required this.onAvailableChanged,
    required this.onNotificationsChanged,
    required this.onGpsChanged,
    required this.onHideFromMapChanged,
    required this.onSignOut,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late bool _available;
  late bool _notifications;
  late bool _gps;
  late bool _hideMap;

  @override
  void initState() {
    super.initState();
    _available = widget.availableNow;
    _notifications = widget.notificationsEnabled;
    _gps = widget.gpsEnabled;
    _hideMap = widget.hideFromMap;
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Account', style: AppTheme.headingSmall),
        content: Text(
          'This will permanently delete your account and all data. This cannot be undone.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close settings
              if (SupabaseConfig.isConfigured) {
                await AuthService.deleteAccount();
              }
            },
            child: Text('Delete', style: AppTheme.labelMedium.copyWith(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderInput,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Settings', style: AppTheme.headingMedium),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Status Section
                  Text('Status', style: AppTheme.labelLarge),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.circle,
                    iconColor: AppTheme.successGreen,
                    label: 'Available Now',
                    subtitle: 'Show as available for matches',
                    value: _available,
                    onChanged: (val) {
                      setState(() => _available = val);
                      widget.onAvailableChanged(val);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Privacy Section
                  Text('Privacy', style: AppTheme.labelLarge),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.visibility_off_outlined,
                    iconColor: AppTheme.textSecondary,
                    label: 'Hide from Map',
                    subtitle: 'Other players can\'t see you on the map',
                    value: _hideMap,
                    onChanged: (val) {
                      setState(() => _hideMap = val);
                      widget.onHideFromMapChanged(val);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Preferences Section
                  Text('Preferences', style: AppTheme.labelLarge),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppTheme.primaryBlue,
                    label: 'Notifications',
                    subtitle: 'Match updates, messages, and more',
                    value: _notifications,
                    onChanged: (val) {
                      setState(() => _notifications = val);
                      widget.onNotificationsChanged(val);
                    },
                  ),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon: Icons.location_on_outlined,
                    iconColor: AppTheme.primaryOrange,
                    label: 'GPS Location',
                    subtitle: 'Auto-detect your play zone',
                    value: _gps,
                    onChanged: (val) {
                      setState(() => _gps = val);
                      widget.onGpsChanged(val);
                    },
                  ),

                  const SizedBox(height: 28),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onSignOut();
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _confirmDeleteAccount,
                      icon: const Icon(Icons.delete_forever, size: 20),
                      label: const Text('Delete Account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.labelMedium),
                Text(subtitle, style: AppTheme.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppTheme.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
