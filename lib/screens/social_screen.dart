import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/post.dart';
import '../data/mock_data.dart';
import '../utils/sport_utils.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_modal.dart';

/// Social Screen — sport-filtered community feed with posts.
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  late List<Post> _posts;
  String _selectedSport = 'All';
  String _sortBy = 'recent'; // 'recent' or 'popular'

  static const _sportFilters = ['All', 'Pickleball', 'Badminton', 'Table Tennis'];

  @override
  void initState() {
    super.initState();
    _posts = List.from(MockData.posts);
  }

  List<Post> get _filteredPosts {
    var posts = _selectedSport == 'All'
        ? _posts
        : _posts.where((p) => p.sport == _selectedSport).toList();

    if (_sortBy == 'popular') {
      posts = List.from(posts)..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    } else {
      posts = List.from(posts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return posts;
  }

  void _handleLike(Post post) {
    setState(() {
      final idx = _posts.indexWhere((p) => p.id == post.id);
      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(
          isLiked: !_posts[idx].isLiked,
          likesCount: _posts[idx].isLiked
              ? _posts[idx].likesCount - 1
              : _posts[idx].likesCount + 1,
        );
      }
    });
  }

  void _handleCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePostModal(
        onSubmit: (result) {
          setState(() {
            _posts.insert(
              0,
              Post(
                id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                authorId: 'current_user',
                authorUsername: 'You',
                sport: result.sport,
                content: result.content,
                tag: result.tag,
                createdAt: DateTime.now(),
              ),
            );
          });
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPosts;

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
                child: filtered.isEmpty
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
