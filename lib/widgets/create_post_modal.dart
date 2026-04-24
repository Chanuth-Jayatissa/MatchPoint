import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/sport_utils.dart';
import '../utils/validators.dart';

/// Create post modal — text content, sport selector, tag selector, image button.
class CreatePostModal extends StatefulWidget {
  final ValueChanged<({String content, String sport, String tag})> onSubmit;

  const CreatePostModal({super.key, required this.onSubmit});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  String _selectedSport = 'Pickleball';
  String _selectedTag = 'general';

  static const _tags = ['general', 'highlight', 'question'];

  @override
  void dispose() {
    _contentController.dispose();
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
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                    Text('Create Post', style: AppTheme.headingMedium),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: AppTheme.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Sport Selector
                Text('Sport', style: AppTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SportUtils.allSports.map((sport) {
                    final isSelected = _selectedSport == sport;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSport = sport),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              SportUtils.getEmoji(sport),
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              sport,
                              style: AppTheme.labelMedium.copyWith(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Tag Selector
                Text('Tag', style: AppTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _tags.map((tag) {
                    final isSelected = _selectedTag == tag;
                    final tagInfo = SportUtils.getTagInfo(tag);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTag = tag),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? tagInfo.bgColor : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? tagInfo.iconColor : AppTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tagInfo.icon, size: 16, color: tagInfo.iconColor),
                            const SizedBox(width: 6),
                            Text(
                              tag[0].toUpperCase() + tag.substring(1),
                              style: AppTheme.labelMedium.copyWith(
                                color: isSelected
                                    ? tagInfo.iconColor
                                    : AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Content Input
                Text('What\'s on your mind?', style: AppTheme.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  validator: (val) => Validators.required(val, 'Post content'),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts, highlights, or questions...',
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderInput),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Image button (placeholder for now)
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Image upload coming with Supabase storage integration',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppTheme.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.image_outlined, size: 20),
                  label: const Text('Add Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      widget.onSubmit((
                        content: _contentController.text.trim(),
                        sport: _selectedSport,
                        tag: _selectedTag,
                      ));
                      Navigator.of(context).pop();
                    },
                    child: Text('Post', style: AppTheme.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
