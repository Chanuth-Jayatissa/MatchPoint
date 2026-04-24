import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

/// Modal for logging match results — score input + win/loss selector.
class LogResultModal extends StatefulWidget {
  final String opponentName;
  final String sport;
  final ValueChanged<({String score, String result})> onSubmit;

  const LogResultModal({
    super.key,
    required this.opponentName,
    required this.sport,
    required this.onSubmit,
  });

  @override
  State<LogResultModal> createState() => _LogResultModalState();
}

class _LogResultModalState extends State<LogResultModal> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  String _selectedResult = 'win';

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Form(
          key: _formKey,
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
                  Text('Log Match Result', style: AppTheme.headingMedium),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                'vs ${widget.opponentName} • ${widget.sport}',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),

              const SizedBox(height: 24),

              // Score Input
              Text('Score', style: AppTheme.labelMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: _scoreController,
                validator: Validators.score,
                decoration: const InputDecoration(
                  hintText: 'e.g. 21-17, 19-21, 21-15',
                  prefixIcon: Icon(Icons.scoreboard_outlined, size: 20),
                ),
              ),

              const SizedBox(height: 24),

              // Win/Loss Selector
              Text('Your Result', style: AppTheme.labelMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ResultOption(
                      label: 'Win',
                      icon: Icons.emoji_events,
                      isSelected: _selectedResult == 'win',
                      color: AppTheme.successGreen,
                      onTap: () => setState(() => _selectedResult = 'win'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultOption(
                      label: 'Loss',
                      icon: Icons.trending_down,
                      isSelected: _selectedResult == 'loss',
                      color: AppTheme.errorRed,
                      onTap: () => setState(() => _selectedResult = 'loss'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    widget.onSubmit((
                      score: _scoreController.text.trim(),
                      result: _selectedResult,
                    ));
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit Result', style: AppTheme.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ResultOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? color : AppTheme.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
