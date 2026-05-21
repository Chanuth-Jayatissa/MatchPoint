import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../utils/sport_utils.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_modal.dart';

/// Social Screen — sport-filtered community feed with posts.
class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> {
  String _selectedSport = 'All';
  String _sortBy = 'recent'; // 'recent' or 'popular'

  static const _sportFilters = ['All', 'Pickleball', 'Badminton', 'Table Tennis'];

  List<Post> _getFilteredPosts(List<Post> posts) {
    var filtered = _selectedSport == 'All'
        ? posts
        : posts.where((p) => p.sport == _selectedSport).toList();

    if (_sortBy == 'popular') {
      filtered = List.from(filtered)..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    } else {
      filtered = List.from(filtered)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return filtered;
  }

  void _handleLike(Post post) {
    ref.read(postServiceProvider).toggleLike(post.id, post.isLiked).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to like post: $e',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  void _handleCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePostModal(
        onSubmit: (result) {
          ref.read(postServiceProvider).createPost(
            sport: result.sport,
            content: result.content,
            tag: result.tag,
          ).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Post created! 🎉',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                ),
                backgroundColor: AppTheme.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to create post: $e',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                ),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsStreamProvider);

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Community', style: AppTheme.headingLarge),
                    // Sort toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _sortBy = _sortBy == 'recent' ? 'popular' : 'recent';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _sortBy == 'recent'
                                  ? Icons.access_time
                                  : Icons.trending_up,
                              size: 16,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _sortBy == 'recent' ? 'Recent' : 'Popular',
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.primaryBlue,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Sport filter chips (horizontal scroll)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sportFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final sport = _sportFilters[i];
                    final isSelected = _selectedSport == sport;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSport = sport),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (sport != 'All') ...[
                              Text(
                                SportUtils.getEmoji(sport),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              sport,
                              style: AppTheme.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Post feed
              Expanded(
                child: postsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                  ),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error loading posts: $err',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (posts) {
                    final filtered = _getFilteredPosts(posts);
                    return filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => PostCard(
                              post: filtered[i],
                              onLike: () => _handleLike(filtered[i]),
                              onComment: () {
                                // Comment view — placeholder for now
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Comments coming soon!',
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
                              onTap: () {},
                            ),
                          );
                  },
                ),
              ),
            ],
          ),

          // Floating Create Post Button
          Positioned(
            right: 20,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: _handleCreatePost,
              backgroundColor: AppTheme.primaryOrange,
              elevation: 6,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48, color: AppTheme.borderInput),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedSport == 'All'
                  ? 'Be the first to share something!'
                  : 'No $_selectedSport posts yet. Create one!',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
