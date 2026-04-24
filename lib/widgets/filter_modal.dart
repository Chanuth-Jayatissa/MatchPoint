import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/sport_utils.dart';

/// Filter modal bottom sheet — sport toggles + "Available Now" switch.
class FilterModal extends StatefulWidget {
  final Set<String> selectedSports;
  final bool availableNowOnly;
  final ValueChanged<Set<String>> onSportsChanged;
  final ValueChanged<bool> onAvailableNowChanged;

  const FilterModal({
    super.key,
    required this.selectedSports,
    required this.availableNowOnly,
    required this.onSportsChanged,
    required this.onAvailableNowChanged,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late Set<String> _selected;
  late bool _availableNow;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedSports);
    _availableNow = widget.availableNowOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderInput,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: AppTheme.headingMedium),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sport selection
            Text('Sports', style: AppTheme.labelLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: SportUtils.allSports.map((sport) {
                final isSelected = _selected.contains(sport);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(sport);
                      } else {
                        _selected.add(sport);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue.withOpacity(0.1)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(SportUtils.getEmoji(sport), style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          sport,
                          style: AppTheme.labelMedium.copyWith(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, size: 18, color: AppTheme.primaryBlue),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Available Now toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Available Now Only', style: AppTheme.labelMedium),
                    ],
                  ),
                  Switch.adaptive(
                    value: _availableNow,
                    activeColor: AppTheme.successGreen,
                    onChanged: (val) => setState(() => _availableNow = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSportsChanged(_selected);
                  widget.onAvailableNowChanged(_availableNow);
                  Navigator.of(context).pop();
                },
                child: Text('Apply Filters', style: AppTheme.button),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
