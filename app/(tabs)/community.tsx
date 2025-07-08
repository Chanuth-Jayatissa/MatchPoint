import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Modal,
  TextInput,
  Image,
  FlatList,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Plus, Heart, MessageCircle, MoveHorizontal as MoreHorizontal, X, Trophy, CircleHelp as HelpCircle, Star, Camera, ChevronDown } from 'lucide-react-native';

interface Post {
  id: string;
  author: {
    username: string;
    profilePic: string;
  };
  sport: string;
  content: string;
  image?: string;
  tag: 'highlight' | 'question' | 'general';
  timestamp: string;
  likes: number;
  comments: number;
  isLiked: boolean;
}

interface Comment {
  id: string;
  author: string;
  content: string;
  timestamp: string;
}

const mockPosts: Post[] = [
  {
    id: '1',
    author: {
      username: 'PickleballAce_23',
      profilePic: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Pickleball',
    content: 'Just hit my first perfect serve ace! Been working on my technique for months. The key is really in the wrist snap and follow-through. Anyone else struggling with serves?',
    image: 'https://images.pexels.com/photos/209977/pexels-photo-209977.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
    tag: 'highlight',
    timestamp: '2 hours ago',
    likes: 24,
    comments: 8,
    isLiked: false,
  },
  {
    id: '2',
    author: {
      username: 'BadmintonPro',
      profilePic: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Badminton',
    content: 'Quick question - what\'s the best way to improve footwork for better court coverage? I feel like I\'m always a step behind my opponents.',
    tag: 'question',
    timestamp: '4 hours ago',
    likes: 12,
    comments: 15,
    isLiked: true,
  },
  {
    id: '3',
    author: {
      username: 'PingPongKing',
      profilePic: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Table Tennis',
    content: 'Finally mastered the perfect backhand loop! It took weeks of practice but the consistency is paying off in matches. Practice makes perfect!',
    tag: 'highlight',
    timestamp: '1 day ago',
    likes: 31,
    comments: 6,
    isLiked: false,
  },
];

export default function CommunityScreen() {
  const [activeSport, setActiveSport] = useState('Badminton');
  const [createPostVisible, setCreatePostVisible] = useState(false);
  const [postContent, setPostContent] = useState('');
  const [selectedTag, setSelectedTag] = useState<'highlight' | 'question' | 'general'>('general');
  const [sortBy, setSortBy] = useState<'recent' | 'liked'>('recent');
  const [sortDropdownVisible, setSortDropdownVisible] = useState(false);

  const sports = ['Badminton', 'Table Tennis', 'Pickleball'];

  const getTagIcon = (tag: string) => {
    switch (tag) {
      case 'highlight':
        return <Star size={16} color="#F59E0B" />;
      case 'question':
        return <HelpCircle size={16} color="#3B82F6" />;
      default:
        return <MessageCircle size={16} color="#64748B" />;
    }
  };

  const getTagColor = (tag: string) => {
    switch (tag) {
      case 'highlight':
        return '#FEF3C7';
      case 'question':
        return '#DBEAFE';
      default:
        return '#F3F4F6';
    }
  };

  const PostCard = ({ post }: { post: Post }) => (
    <View style={styles.postCard}>
      <View style={styles.postHeader}>
        <View style={styles.authorInfo}>
          <Image source={{ uri: post.author.profilePic }} style={styles.authorAvatar} />
          <View style={styles.authorDetails}>
            <Text style={styles.authorName}>{post.author.username}</Text>
            <View style={styles.postMeta}>
              <View style={[styles.tagContainer, { backgroundColor: getTagColor(post.tag) }]}>
                {getTagIcon(post.tag)}
                <Text style={styles.tagText}>{post.tag}</Text>
              </View>
              <Text style={styles.sportLabel}>{post.sport}</Text>
              <Text style={styles.timestamp}>{post.timestamp}</Text>
            </View>
          </View>
        </View>
        <TouchableOpacity>
          <MoreHorizontal size={20} color="#64748B" />
        </TouchableOpacity>
      </View>

      <Text style={styles.postContent}>{post.content}</Text>

      {post.image && (
        <Image source={{ uri: post.image }} style={styles.postImage} />
      )}

      <View style={styles.postActions}>
        <TouchableOpacity style={styles.actionButton}>
          <Heart size={20} color={post.isLiked ? '#EF4444' : '#64748B'} fill={post.isLiked ? '#EF4444' : 'none'} />
          <Text style={[styles.actionText, post.isLiked && { color: '#EF4444' }]}>{post.likes}</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.actionButton}>
          <MessageCircle size={20} color="#64748B" />
          <Text style={styles.actionText}>{post.comments}</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const filteredPosts = mockPosts
    .filter(post => post.sport === activeSport)
    .sort((a, b) => {
      if (sortBy === 'liked') {
        return b.likes - a.likes;
      }
      return 0; // Keep original order for 'recent'
    });

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Community</Text>
        <TouchableOpacity
          style={styles.sortButton}
          onPress={() => setSortDropdownVisible(true)}
        >
          <Text style={styles.sortButtonText}>
            {sortBy === 'recent' ? 'Most Recent' : 'Most Liked'}
          </Text>
          <ChevronDown size={16} color="#1D4ED8" />
        </TouchableOpacity>
      </View>

      {/* Sport Tabs */}
      <ScrollView 
        horizontal 
        showsHorizontalScrollIndicator={false}
        style={styles.sportsTabsContainer}
        contentContainerStyle={styles.sportsTabsContent}
      >
        {sports.map((sport) => (
          <TouchableOpacity
            key={sport}
            style={[
              styles.sportTab,
              activeSport === sport && styles.activeSportTab
            ]}
            onPress={() => setActiveSport(sport)}
          >
            <Trophy size={16} color={activeSport === sport ? '#FFFFFF' : '#64748B'} />
            <Text style={[
              styles.sportTabText,
              activeSport === sport && styles.activeSportTabText
            ]}>
              {sport}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Posts Feed */}
      <ScrollView style={styles.postsContainer} showsVerticalScrollIndicator={false}>
        {filteredPosts.length > 0 ? (
          filteredPosts.map((post) => (
            <PostCard key={post.id} post={post} />
          ))
        ) : (
          <View style={styles.emptyState}>
            <MessageCircle size={48} color="#D1D5DB" />
            <Text style={styles.emptyStateText}>No posts yet for {activeSport}</Text>
            <Text style={styles.emptyStateSubtext}>Be the first to share something!</Text>
          </View>
        )}
      </ScrollView>

      {/* Create Post FAB */}
      <TouchableOpacity
        style={styles.fab}
        onPress={() => setCreatePostVisible(true)}
      >
        <Plus size={24} color="#FFFFFF" />
      </TouchableOpacity>

      {/* Sort Dropdown Modal */}
      <Modal
        visible={sortDropdownVisible}
        transparent={true}
        animationType="fade"
        onRequestClose={() => setSortDropdownVisible(false)}
      >
        <TouchableOpacity
          style={styles.dropdownOverlay}
          activeOpacity={1}
          onPress={() => setSortDropdownVisible(false)}
        >
          <View style={styles.dropdownMenu}>
            <TouchableOpacity
              style={styles.dropdownItem}
              onPress={() => {
                setSortBy('recent');
                setSortDropdownVisible(false);
              }}
            >
              <Text style={[styles.dropdownText, sortBy === 'recent' && styles.selectedDropdownText]}>
                Most Recent
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.dropdownItem}
              onPress={() => {
                setSortBy('liked');
                setSortDropdownVisible(false);
              }}
            >
              <Text style={[styles.dropdownText, sortBy === 'liked' && styles.selectedDropdownText]}>
                Most Liked
              </Text>
            </TouchableOpacity>
          </View>
        </TouchableOpacity>
      </Modal>

      {/* Create Post Modal */}
      <Modal
        visible={createPostVisible}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setCreatePostVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.createPostModal}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Create Post</Text>
              <TouchableOpacity onPress={() => setCreatePostVisible(false)}>
                <X size={24} color="#64748B" />
              </TouchableOpacity>
            </View>

            <View style={styles.modalContent}>
              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>What's on your mind?</Text>
                <TextInput
                  style={styles.contentInput}
                  placeholder="Share your thoughts, achievements, or ask questions..."
                  value={postContent}
                  onChangeText={setPostContent}
                  multiline
                  numberOfLines={4}
                />
              </View>

              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Tag</Text>
                <View style={styles.tagSelection}>
                  {[
                    { key: 'general', label: 'General', icon: MessageCircle },
                    { key: 'highlight', label: 'Highlight', icon: Star },
                    { key: 'question', label: 'Question', icon: HelpCircle },
                  ].map((tag) => (
                    <TouchableOpacity
                      key={tag.key}
                      style={[
                        styles.tagOption,
                        selectedTag === tag.key && styles.selectedTagOption
                      ]}
                      onPress={() => setSelectedTag(tag.key as any)}
                    >
                      <tag.icon 
                        size={16} 
                        color={selectedTag === tag.key ? '#FFFFFF' : '#64748B'} 
                      />
                      <Text style={[
                        styles.tagOptionText,
                        selectedTag === tag.key && styles.selectedTagOptionText
                      ]}>
                        {tag.label}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </View>

              <TouchableOpacity style={styles.addImageButton}>
                <Camera size={20} color="#64748B" />
                <Text style={styles.addImageText}>Add Image (Optional)</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.postButton}
                onPress={() => {
                  setCreatePostVisible(false);
                  setPostContent('');
                  setSelectedTag('general');
                }}
              >
                <Text style={styles.postButtonText}>Post</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  headerTitle: {
    fontSize: 24,
    fontFamily: 'Inter-Bold',
    color: '#0F172A',
  },
  sortButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    backgroundColor: '#F1F5F9',
  },
  sortButtonText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#1D4ED8',
    marginRight: 4,
  },
  sportsTabsContainer: {
    marginTop: 16,
  },
  sportsTabsContent: {
    paddingHorizontal: 20,
  },
  sportTab: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginRight: 12,
    borderRadius: 20,
    backgroundColor: '#F8FAFC',
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  activeSportTab: {
    backgroundColor: '#1D4ED8',
    borderColor: '#1D4ED8',
  },
  sportTabText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#64748B',
    marginLeft: 6,
  },
  activeSportTabText: {
    color: '#FFFFFF',
  },
  postsContainer: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 16,
  },
  postCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    borderWidth: 1,
    borderColor: '#F1F5F9',
  },
  postHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  authorInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  authorAvatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 12,
  },
  authorDetails: {
    flex: 1,
  },
  authorName: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginBottom: 4,
  },
  postMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
  },
  tagContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
    marginRight: 8,
  },
  tagText: {
    fontSize: 12,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
    marginLeft: 4,
    textTransform: 'capitalize',
  },
  sportLabel: {
    fontSize: 12,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginRight: 8,
  },
  timestamp: {
    fontSize: 12,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
  },
  postContent: {
    fontSize: 15,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
    lineHeight: 22,
    marginBottom: 12,
  },
  postImage: {
    width: '100%',
    height: 200,
    borderRadius: 12,
    marginBottom: 12,
  },
  postActions: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#F1F5F9',
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 24,
  },
  actionText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#64748B',
    marginLeft: 6,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyStateText: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginTop: 16,
    marginBottom: 8,
  },
  emptyStateSubtext: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    textAlign: 'center',
  },
  fab: {
    position: 'absolute',
    bottom: 24,
    right: 24,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#F97316',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  dropdownOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    justifyContent: 'flex-start',
    alignItems: 'flex-end',
    paddingTop: 100,
    paddingRight: 20,
  },
  dropdownMenu: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingVertical: 8,
    minWidth: 150,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 8,
  },
  dropdownItem: {
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  dropdownText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
  },
  selectedDropdownText: {
    fontFamily: 'Inter-SemiBold',
    color: '#1D4ED8',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  createPostModal: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '80%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  modalTitle: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
  },
  modalContent: {
    padding: 20,
  },
  inputGroup: {
    marginBottom: 20,
  },
  inputLabel: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
    marginBottom: 8,
  },
  contentInput: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
    height: 100,
    textAlignVertical: 'top',
  },
  tagSelection: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  tagOption: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
    marginRight: 8,
    marginBottom: 8,
    borderRadius: 20,
    backgroundColor: '#F8FAFC',
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  selectedTagOption: {
    backgroundColor: '#1D4ED8',
    borderColor: '#1D4ED8',
  },
  tagOptionText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#64748B',
    marginLeft: 6,
  },
  selectedTagOptionText: {
    color: '#FFFFFF',
  },
  addImageButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 12,
    borderStyle: 'dashed',
    marginBottom: 24,
  },
  addImageText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginLeft: 8,
  },
  postButton: {
    backgroundColor: '#F97316',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  postButtonText: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#FFFFFF',
  },
});