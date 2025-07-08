import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Modal,
  Switch,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { CreditCard as Edit3, Trophy, TrendingUp, Settings, Bell, MapPin, Eye, LogOut, Trash2, Star, Calendar, Target, X } from 'lucide-react-native';

interface SportRating {
  sport: string;
  rating: number;
  trend: 'up' | 'down' | 'stable';
}

interface RecentMatch {
  id: string;
  opponent: string;
  sport: string;
  result: 'win' | 'loss';
  score: string;
  date: string;
}

const mockSportRatings: SportRating[] = [
  { sport: 'Pickleball', rating: 1850, trend: 'up' },
  { sport: 'Badminton', rating: 1720, trend: 'stable' },
  { sport: 'Table Tennis', rating: 0, trend: 'stable' }, // Unrated
];

const mockRecentMatches: RecentMatch[] = [
  {
    id: '1',
    opponent: 'PickleballAce_23',
    sport: 'Pickleball',
    result: 'win',
    score: '6-4, 7-5',
    date: '2 days ago'
  },
  {
    id: '2',
    opponent: 'BadmintonPro',
    sport: 'Badminton',
    result: 'loss',
    score: '21-17, 19-21, 18-21',
    date: '5 days ago'
  },
  {
    id: '3',
    opponent: 'PingPongKing',
    sport: 'Table Tennis',
    result: 'win',
    score: '11-9, 8-11, 11-7',
    date: '1 week ago'
  },
  {
    id: '4',
    opponent: 'CourtCrusher',
    sport: 'Pickleball',
    result: 'win',
    score: '6-2, 6-3',
    date: '1 week ago'
  },
];

export default function ProfileScreen() {
  const [settingsVisible, setSettingsVisible] = useState(false);
  const [notifications, setNotifications] = useState(true);
  const [gpsEnabled, setGpsEnabled] = useState(true);
  const [hideFromMap, setHideFromMap] = useState(false);

  const getSportIcon = (sport: string) => {
    return <Trophy size={20} color="#F97316" />;
  };

  const getTrendIcon = (trend: string) => {
    if (trend === 'up') return <TrendingUp size={16} color="#10B981" />;
    if (trend === 'down') return <TrendingUp size={16} color="#EF4444" style={{ transform: [{ rotate: '180deg' }] }} />;
    return null;
  };

  const SportRatingCard = ({ sport }: { sport: SportRating }) => (
    <View style={styles.sportCard}>
      <View style={styles.sportHeader}>
        {getSportIcon(sport.sport)}
        <Text style={styles.sportName}>{sport.sport}</Text>
        {getTrendIcon(sport.trend)}
      </View>
      <Text style={styles.rating}>
        {sport.rating === 0 ? 'Unrated' : sport.rating}
      </Text>
      {sport.rating > 0 && (
        <View style={styles.ratingGraph}>
          <View style={styles.graphLine} />
          <Text style={styles.graphLabel}>Rating over time</Text>
        </View>
      )}
    </View>
  );

  const MatchCard = ({ match }: { match: RecentMatch }) => (
    <View style={styles.matchCard}>
      <View style={styles.matchHeader}>
        <View style={styles.matchInfo}>
          <Text style={styles.matchOpponent}>{match.opponent}</Text>
          <Text style={styles.matchSport}>{match.sport}</Text>
        </View>
        <View style={styles.matchResult}>
          <Text style={[
            styles.resultText,
            { color: match.result === 'win' ? '#10B981' : '#EF4444' }
          ]}>
            {match.result.toUpperCase()}
          </Text>
        </View>
      </View>
      <Text style={styles.matchScore}>{match.score}</Text>
      <Text style={styles.matchDate}>{match.date}</Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Your Profile</Text>
        <TouchableOpacity
          style={styles.settingsButton}
          onPress={() => setSettingsVisible(true)}
        >
          <Settings size={24} color="#1D4ED8" />
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Profile Section */}
        <View style={styles.profileSection}>
          <TouchableOpacity style={styles.profilePicContainer}>
            <Image
              source={{ uri: 'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop' }}
              style={styles.profilePic}
            />
            <View style={styles.editPicBadge}>
              <Edit3 size={12} color="#FFFFFF" />
            </View>
          </TouchableOpacity>
          
          <Text style={styles.username}>SportsFan_92</Text>
          <Text style={styles.location}>San Francisco, CA</Text>
          
          <View style={styles.respectScoreContainer}>
            <Star size={20} color="#F59E0B" />
            <Text style={styles.respectScore}>92/100</Text>
            <Text style={styles.respectLabel}>Respect Score</Text>
          </View>

          <TouchableOpacity style={styles.editProfileButton}>
            <Edit3 size={16} color="#1D4ED8" />
            <Text style={styles.editProfileText}>Edit Profile</Text>
          </TouchableOpacity>
        </View>

        {/* Your Ratings Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Your Ratings</Text>
          <View style={styles.sportsGrid}>
            {mockSportRatings.map((sport, index) => (
              <SportRatingCard key={index} sport={sport} />
            ))}
          </View>
        </View>

        {/* Recent Matches Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent Matches</Text>
          {mockRecentMatches.map((match) => (
            <MatchCard key={match.id} match={match} />
          ))}
        </View>
      </ScrollView>

      {/* Settings Modal */}
      <Modal
        visible={settingsVisible}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setSettingsVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.settingsModal}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Settings</Text>
              <TouchableOpacity onPress={() => setSettingsVisible(false)}>
                <X size={24} color="#64748B" />
              </TouchableOpacity>
            </View>

            <View style={styles.settingsContent}>
              <View style={styles.settingItem}>
                <View style={styles.settingInfo}>
                  <Bell size={20} color="#64748B" />
                  <Text style={styles.settingLabel}>Notifications</Text>
                </View>
                <Switch
                  value={notifications}
                  onValueChange={setNotifications}
                  trackColor={{ false: '#D1D5DB', true: '#1D4ED8' }}
                  thumbColor={notifications ? '#FFFFFF' : '#FFFFFF'}
                />
              </View>

              <View style={styles.settingItem}>
                <View style={styles.settingInfo}>
                  <MapPin size={20} color="#64748B" />
                  <Text style={styles.settingLabel}>GPS Location</Text>
                </View>
                <Switch
                  value={gpsEnabled}
                  onValueChange={setGpsEnabled}
                  trackColor={{ false: '#D1D5DB', true: '#1D4ED8' }}
                  thumbColor={gpsEnabled ? '#FFFFFF' : '#FFFFFF'}
                />
              </View>

              <View style={styles.settingItem}>
                <View style={styles.settingInfo}>
                  <Eye size={20} color="#64748B" />
                  <Text style={styles.settingLabel}>Hide me from map</Text>
                </View>
                <Switch
                  value={hideFromMap}
                  onValueChange={setHideFromMap}
                  trackColor={{ false: '#D1D5DB', true: '#1D4ED8' }}
                  thumbColor={hideFromMap ? '#FFFFFF' : '#FFFFFF'}
                />
              </View>

              <TouchableOpacity style={styles.dangerSettingItem}>
                <LogOut size={20} color="#EF4444" />
                <Text style={styles.dangerSettingLabel}>Logout</Text>
              </TouchableOpacity>

              <TouchableOpacity style={styles.dangerSettingItem}>
                <Trash2 size={20} color="#EF4444" />
                <Text style={styles.dangerSettingLabel}>Delete Account</Text>
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
  settingsButton: {
    padding: 4,
  },
  content: {
    flex: 1,
  },
  profileSection: {
    alignItems: 'center',
    paddingVertical: 32,
    paddingHorizontal: 20,
    backgroundColor: '#F8FAFC',
  },
  profilePicContainer: {
    position: 'relative',
    marginBottom: 16,
  },
  profilePic: {
    width: 100,
    height: 100,
    borderRadius: 50,
  },
  editPicBadge: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#1D4ED8',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#FFFFFF',
  },
  username: {
    fontSize: 24,
    fontFamily: 'Inter-Bold',
    color: '#0F172A',
    marginBottom: 4,
  },
  location: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginBottom: 16,
  },
  respectScoreContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  respectScore: {
    fontSize: 18,
    fontFamily: 'Inter-Bold',
    color: '#0F172A',
    marginLeft: 6,
    marginRight: 8,
  },
  respectLabel: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
  },
  editProfileButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderWidth: 1,
    borderColor: '#1D4ED8',
    borderRadius: 20,
  },
  editProfileText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#1D4ED8',
    marginLeft: 6,
  },
  section: {
    paddingHorizontal: 20,
    paddingVertical: 24,
  },
  sectionTitle: {
    fontSize: 20,
    fontFamily: 'Inter-Bold',
    color: '#0F172A',
    marginBottom: 16,
  },
  sportsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  sportCard: {
    width: '48%',
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    borderWidth: 1,
    borderColor: '#F1F5F9',
  },
  sportHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  sportName: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
    marginLeft: 6,
    flex: 1,
  },
  rating: {
    fontSize: 24,
    fontFamily: 'Inter-Bold',
    color: '#1D4ED8',
    marginBottom: 8,
  },
  ratingGraph: {
    alignItems: 'center',
  },
  graphLine: {
    width: '100%',
    height: 2,
    backgroundColor: '#10B981',
    borderRadius: 1,
    marginBottom: 4,
  },
  graphLabel: {
    fontSize: 10,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
  },
  matchCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    borderWidth: 1,
    borderColor: '#F1F5F9',
  },
  matchHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  matchInfo: {
    flex: 1,
  },
  matchOpponent: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginBottom: 2,
  },
  matchSport: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
  },
  matchResult: {
    alignItems: 'flex-end',
  },
  resultText: {
    fontSize: 14,
    fontFamily: 'Inter-Bold',
  },
  matchScore: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
    marginBottom: 4,
  },
  matchDate: {
    fontSize: 12,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  settingsModal: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '70%',
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
  settingsContent: {
    padding: 20,
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F1F5F9',
  },
  settingInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  settingLabel: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
    marginLeft: 12,
  },
  dangerSettingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F1F5F9',
  },
  dangerSettingLabel: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#EF4444',
    marginLeft: 12,
  },
});