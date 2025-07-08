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
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Trophy, Clock, CircleCheck as CheckCircle, TriangleAlert as AlertTriangle, X, User, MapPin, Calendar } from 'lucide-react-native';

interface Match {
  id: string;
  opponent: {
    username: string;
    profilePic: string;
  };
  sport: string;
  court: string;
  status: 'to-log' | 'to-verify' | 'disputed';
  timestamp: string;
  score?: string;
  result?: 'win' | 'loss';
}

const mockMatches: Match[] = [
  {
    id: '1',
    opponent: {
      username: 'PickleballAce_23',
      profilePic: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Pickleball',
    court: 'Downtown Pickleball Court #1',
    status: 'to-log',
    timestamp: '2 hours ago',
  },
  {
    id: '2',
    opponent: {
      username: 'BadmintonPro',
      profilePic: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Badminton',
    court: 'University Gym Court B',
    status: 'to-verify',
    timestamp: '1 day ago',
    score: '21-17, 19-21, 21-15',
    result: 'win',
  },
  {
    id: '3',
    opponent: {
      username: 'PingPongKing',
      profilePic: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Table Tennis',
    court: 'Community Center Table 3',
    status: 'disputed',
    timestamp: '3 days ago',
    score: '11-9, 8-11, 11-7',
    result: 'win',
  },
];

export default function MatchesScreen() {
  const [activeTab, setActiveTab] = useState<'to-log' | 'to-verify' | 'disputed'>('to-log');
  const [selectedMatch, setSelectedMatch] = useState<Match | null>(null);
  const [logModalVisible, setLogModalVisible] = useState(false);
  const [score, setScore] = useState('');
  const [comment, setComment] = useState('');
  const [reportIssue, setReportIssue] = useState(false);

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'to-log':
        return <Clock size={20} color="#F97316" />;
      case 'to-verify':
        return <CheckCircle size={20} color="#10B981" />;
      case 'disputed':
        return <AlertTriangle size={20} color="#EF4444" />;
      default:
        return <Clock size={20} color="#64748B" />;
    }
  };

  const getActionButtonText = (status: string) => {
    switch (status) {
      case 'to-log':
        return 'Log Result';
      case 'to-verify':
        return 'Verify';
      case 'disputed':
        return 'View Dispute';
      default:
        return 'Action';
    }
  };

  const filteredMatches = mockMatches.filter(match => match.status === activeTab);

  const MatchCard = ({ match }: { match: Match }) => (
    <View style={styles.matchCard}>
      <View style={styles.matchHeader}>
        <View style={styles.opponentInfo}>
          <Image source={{ uri: match.opponent.profilePic }} style={styles.opponentAvatar} />
          <View style={styles.opponentDetails}>
            <Text style={styles.opponentName}>{match.opponent.username}</Text>
            <View style={styles.matchMeta}>
              <Trophy size={16} color="#F97316" />
              <Text style={styles.sportText}>{match.sport}</Text>
            </View>
          </View>
        </View>
        {getStatusIcon(match.status)}
      </View>

      <View style={styles.matchDetails}>
        <View style={styles.detailRow}>
          <MapPin size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.court}</Text>
        </View>
        <View style={styles.detailRow}>
          <Calendar size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.timestamp}</Text>
        </View>
        {match.score && (
          <View style={styles.scoreContainer}>
            <Text style={styles.scoreLabel}>Score:</Text>
            <Text style={styles.scoreText}>{match.score}</Text>
            <Text style={[
              styles.resultText,
              { color: match.result === 'win' ? '#10B981' : '#EF4444' }
            ]}>
              {match.result === 'win' ? 'WIN' : 'LOSS'}
            </Text>
          </View>
        )}
      </View>

      <TouchableOpacity
        style={[styles.actionButton, { backgroundColor: getActionButtonColor(match.status) }]}
        onPress={() => {
          if (match.status === 'to-log') {
            setSelectedMatch(match);
            setLogModalVisible(true);
          }
        }}
      >
        <Text style={styles.actionButtonText}>{getActionButtonText(match.status)}</Text>
      </TouchableOpacity>
    </View>
  );

  const getActionButtonColor = (status: string) => {
    switch (status) {
      case 'to-log':
        return '#F97316';
      case 'to-verify':
        return '#10B981';
      case 'disputed':
        return '#EF4444';
      default:
        return '#64748B';
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Your Matches</Text>
      </View>

      {/* Tab Navigation */}
      <View style={styles.tabContainer}>
        {[
          { key: 'to-log', label: 'To Log', count: mockMatches.filter(m => m.status === 'to-log').length },
          { key: 'to-verify', label: 'To Verify', count: mockMatches.filter(m => m.status === 'to-verify').length },
          { key: 'disputed', label: 'Disputes', count: mockMatches.filter(m => m.status === 'disputed').length },
        ].map((tab) => (
          <TouchableOpacity
            key={tab.key}
            style={[
              styles.tab,
              activeTab === tab.key && styles.activeTab
            ]}
            onPress={() => setActiveTab(tab.key as any)}
          >
            <Text style={[
              styles.tabText,
              activeTab === tab.key && styles.activeTabText
            ]}>
              {tab.label}
            </Text>
            {tab.count > 0 && (
              <View style={styles.tabBadge}>
                <Text style={styles.tabBadgeText}>{tab.count}</Text>
              </View>
            )}
          </TouchableOpacity>
        ))}
      </View>

      {/* Matches List */}
      <ScrollView style={styles.matchesList} showsVerticalScrollIndicator={false}>
        {filteredMatches.length > 0 ? (
          filteredMatches.map((match) => (
            <MatchCard key={match.id} match={match} />
          ))
        ) : (
          <View style={styles.emptyState}>
            <Trophy size={48} color="#D1D5DB" />
            <Text style={styles.emptyStateText}>No matches to {activeTab.replace('-', ' ')}</Text>
            <Text style={styles.emptyStateSubtext}>
              {activeTab === 'to-log' 
                ? 'Play some matches to see them here' 
                : 'All caught up!'}
            </Text>
          </View>
        )}
      </ScrollView>

      {/* Log Result Modal */}
      <Modal
        visible={logModalVisible}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setLogModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.logModal}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Log Match Result</Text>
              <TouchableOpacity onPress={() => setLogModalVisible(false)}>
                <X size={24} color="#64748B" />
              </TouchableOpacity>
            </View>

            <View style={styles.modalContent}>
              {selectedMatch && (
                <View style={styles.matchInfo}>
                  <Text style={styles.modalLabel}>Match with {selectedMatch.opponent.username}</Text>
                  <Text style={styles.modalSubtext}>{selectedMatch.sport} • {selectedMatch.court}</Text>
                </View>
              )}

              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Score</Text>
                <TextInput
                  style={styles.textInput}
                  placeholder="e.g., 21-17, 19-21, 21-15"
                  value={score}
                  onChangeText={setScore}
                />
              </View>

              <View style={styles.inputGroup}>
                <Text style={styles.inputLabel}>Comment (Optional)</Text>
                <TextInput
                  style={[styles.textInput, styles.multilineInput]}
                  placeholder="Add any notes about the match..."
                  value={comment}
                  onChangeText={setComment}
                  multiline
                  numberOfLines={3}
                />
              </View>

              <TouchableOpacity
                style={styles.checkboxRow}
                onPress={() => setReportIssue(!reportIssue)}
              >
                <View style={[styles.checkbox, reportIssue && styles.checkboxChecked]} />
                <Text style={styles.checkboxLabel}>Report an issue with this match</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.submitButton}
                onPress={() => {
                  setLogModalVisible(false);
                  setScore('');
                  setComment('');
                  setReportIssue(false);
                }}
              >
                <Text style={styles.submitButtonText}>Submit Result</Text>
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
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: '#F8FAFC',
    marginHorizontal: 20,
    marginTop: 16,
    borderRadius: 12,
    padding: 4,
  },
  tab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
  },
  activeTab: {
    backgroundColor: '#1D4ED8',
  },
  tabText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#64748B',
  },
  activeTabText: {
    color: '#FFFFFF',
  },
  tabBadge: {
    backgroundColor: '#F97316',
    borderRadius: 10,
    paddingHorizontal: 6,
    paddingVertical: 2,
    marginLeft: 6,
  },
  tabBadgeText: {
    fontSize: 12,
    fontFamily: 'Inter-Bold',
    color: '#FFFFFF',
  },
  matchesList: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 16,
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
    marginBottom: 12,
  },
  opponentInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  opponentAvatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 12,
  },
  opponentDetails: {
    flex: 1,
  },
  opponentName: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginBottom: 2,
  },
  matchMeta: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  sportText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginLeft: 6,
  },
  matchDetails: {
    marginBottom: 16,
  },
  detailRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  detailText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginLeft: 8,
  },
  scoreContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    padding: 8,
    backgroundColor: '#F8FAFC',
    borderRadius: 8,
  },
  scoreLabel: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
    marginRight: 8,
  },
  scoreText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
    flex: 1,
  },
  resultText: {
    fontSize: 12,
    fontFamily: 'Inter-Bold',
  },
  actionButton: {
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignItems: 'center',
  },
  actionButtonText: {
    fontSize: 14,
    fontFamily: 'Inter-SemiBold',
    color: '#FFFFFF',
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
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  logModal: {
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
  matchInfo: {
    marginBottom: 20,
  },
  modalLabel: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginBottom: 4,
  },
  modalSubtext: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
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
  textInput: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
  },
  multilineInput: {
    height: 80,
    textAlignVertical: 'top',
  },
  checkboxRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
  },
  checkbox: {
    width: 20,
    height: 20,
    borderRadius: 4,
    borderWidth: 2,
    borderColor: '#D1D5DB',
    marginRight: 12,
  },
  checkboxChecked: {
    backgroundColor: '#1D4ED8',
    borderColor: '#1D4ED8',
  },
  checkboxLabel: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
    flex: 1,
  },
  submitButton: {
    backgroundColor: '#F97316',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  submitButtonText: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#FFFFFF',
  },
});