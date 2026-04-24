import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/court.dart';
import '../utils/sport_utils.dart';

/// Court detail bottom sheet — shown when a court marker is tapped in court mode.
class CourtDetailSheet extends StatelessWidget {
  final Court court;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  const CourtDetailSheet({
    super.key,
    required this.court,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(court.name, style: AppTheme.headingSmall),
                          if (court.locationName != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    court.locationName!,
                                    style: AppTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Court image
                if (court.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: court.imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 160,
                        color: AppTheme.surface,
                        child: const Center(
                          child: Icon(Icons.sports_tennis, size: 32, color: AppTheme.textMuted),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 160,
                        color: AppTheme.surface,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 32, color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                // Sports available
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: court.sports.map((sport) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${SportUtils.getEmoji(sport)} $sport',
                        style: AppTheme.labelMedium.copyWith(fontSize: 13),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Select button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onSelect,
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Select This Court'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
