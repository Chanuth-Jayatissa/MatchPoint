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
import { Trophy, Clock, CircleCheck as CheckCircle, TriangleAlert as AlertTriangle, X, User, MapPin, Calendar, Zap } from 'lucide-react-native';

interface Match {
  id: string;
  opponent: {
    username: string;
    profilePic: string;
  };
  sport: string;
  court: {
    name: string;
    location: string;
  };
  status: 'accept' | 'to-log' | 'to-verify' | 'disputed';
  timestamp: string;
  score?: string;
  result?: 'win' | 'loss';
  acceptanceStatus: {
    userAccepted: boolean;
    opponentAccepted: boolean;
    courtChanged: boolean;
  };
}

const mockMatches: Match[] = [
  {
    id: '1',
    opponent: {
      username: 'PickleballAce_23',
      profilePic: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Pickleball',
    court: {
      name: 'Downtown Pickleball Court #1',
      location: 'Downtown Sports Complex',
    },
    status: 'accept',
    timestamp: '2 hours ago',
    acceptanceStatus: {
      userAccepted: false,
      opponentAccepted: true,
      courtChanged: false,
    },
  },
  {
    id: '2',
    opponent: {
      username: 'BadmintonPro',
      profilePic: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Badminton',
    court: {
      name: 'University Badminton Hall',
      location: 'University Recreation Center',
    },
    status: 'accept',
    timestamp: '4 hours ago',
    acceptanceStatus: {
      userAccepted: true,
      opponentAccepted: false,
      courtChanged: false,
    },
  },
  {
    id: '3',
    opponent: {
      username: 'CourtCrusher',
      profilePic: 'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Pickleball',
    court: {
      name: 'Elite Pickleball Academy Court A',
      location: 'Downtown Sports Complex',
    },
    status: 'accept',
    timestamp: '6 hours ago',
    acceptanceStatus: {
      userAccepted: true,
      opponentAccepted: true,
      courtChanged: true,
    },
  },
  {
    id: '4',
    opponent: {
      username: 'PingPongKing',
      profilePic: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Table Tennis',
    court: {
      name: 'Community Ping Pong Room',
      location: 'Community Sports Hub',
    },
    status: 'to-log',
    timestamp: '1 day ago',
    acceptanceStatus: {
      userAccepted: true,
      opponentAccepted: true,
      courtChanged: false,
    },
  },
  {
    id: '5',
    opponent: {
      username: 'NetNinja',
      profilePic: 'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Badminton',
    court: {
      name: 'Recreation Center Multi-Court',
      location: 'University Recreation Center',
    },
    status: 'to-verify',
    timestamp: '2 days ago',
    score: '21-17, 19-21, 21-15',
    result: 'win',
    acceptanceStatus: {
      userAccepted: true,
      opponentAccepted: true,
      courtChanged: false,
    },
  },
  {
    id: '6',
    opponent: {
      username: 'SmashMaster',
      profilePic: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    sport: 'Pickleball',
    court: {
      name: 'Downtown Pickleball Court #1',
      location: 'Downtown Sports Complex',
    },
    status: 'disputed',
    timestamp: '3 days ago',
    score: '11-9, 8-11, 11-7',
    result: 'win',
    acceptanceStatus: {
      userAccepted: true,
      opponentAccepted: true,
      courtChanged: false,
    },
  },
];

export default function MatchesScreen() {
  const [activeTab, setActiveTab] = useState<'accept' | 'to-log' | 'to-verify' | 'disputed'>('accept');
  const [selectedMatch, setSelectedMatch] = useState<Match | null>(null);
  const [logModalVisible, setLogModalVisible] = useState(false);
  const [score, setScore] = useState('');
  const [comment, setComment] = useState('');
  const [reportIssue, setReportIssue] = useState(false);

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'accept':
        return <Zap size={20} color="#F97316" />;
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

  const getAcceptanceStatus = (match: Match) => {
    if (match.acceptanceStatus.courtChanged) {
      return 'Court changed – confirm to proceed';
    }
    if (!match.acceptanceStatus.userAccepted) {
      return 'Waiting for your acceptance';
    }
    if (!match.acceptanceStatus.opponentAccepted) {
      return 'Waiting for opponent to accept';
    }
    return 'Both players accepted';
  };

  const getActionButtonText = (status: string, match?: Match) => {
    switch (status) {
      case 'accept':
        if (match && !match.acceptanceStatus.userAccepted) {
          return 'Accept Match';
        }
        return 'Waiting...';
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

  const getSportEmoji = (sport: string) => {
    switch (sport) {
      case 'Pickleball':
        return '🥒';
      case 'Badminton':
        return '🏸';
      case 'Table Tennis':
        return '🏓';
      default:
        return '🏆';
    }
  };

  const filteredMatches = mockMatches.filter(match => match.status === activeTab);

  const AcceptMatchCard = ({ match }: { match: Match }) => (
    <View style={styles.matchCard}>
      <View style={styles.matchHeader}>
        <View style={styles.opponentInfo}>
          <Image source={{ uri: match.opponent.profilePic }} style={styles.opponentAvatar} />
          <View style={styles.opponentDetails}>
            <Text style={styles.opponentName}>{match.opponent.username}</Text>
            <View style={styles.matchMeta}>
              <Text style={styles.sportEmoji}>{getSportEmoji(match.sport)}</Text>
              <Text style={styles.sportText}>{match.sport}</Text>
            </View>
          </View>
        </View>
        {getStatusIcon(match.status)}
      </View>

      <View style={styles.matchDetails}>
        <View style={styles.detailRow}>
          <MapPin size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.court.name}</Text>
        </View>
        <View style={styles.detailRow}>
          <Calendar size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.court.location}</Text>
        </View>
        <View style={styles.statusContainer}>
          <Text style={styles.statusText}>{getAcceptanceStatus(match)}</Text>
        </View>
      </View>

      <View style={styles.actionButtonsRow}>
        {!match.acceptanceStatus.userAccepted ? (
          <TouchableOpacity
            style={[styles.actionButton, { backgroundColor: '#F97316', flex: 1, marginRight: 8 }]}
            onPress={() => {
              // Handle accept match
            }}
          >
            <Text style={styles.actionButtonText}>Accept Match</Text>
          </TouchableOpacity>
        ) : (
          <View style={[styles.disabledButton, { flex: 1, marginRight: 8 }]}>
            <Text style={styles.disabledButtonText}>Accepted ✓</Text>
          </View>
        )}
        
        <TouchableOpacity
          style={[styles.secondaryButton, { flex: 1, marginLeft: 8 }]}
          onPress={() => {
            // Handle change court
          }}
        >
          <Text style={styles.secondaryButtonText}>Change Court</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const ToLogMatchCard = ({ match }: { match: Match }) => (
    <View style={styles.matchCard}>
      <View style={styles.matchHeader}>
        <View style={styles.opponentInfo}>
          <Image source={{ uri: match.opponent.profilePic }} style={styles.opponentAvatar} />
          <View style={styles.opponentDetails}>
            <Text style={styles.opponentName}>{match.opponent.username}</Text>
            <View style={styles.matchMeta}>
              <Text style={styles.sportEmoji}>{getSportEmoji(match.sport)}</Text>
              <Text style={styles.sportText}>{match.sport}</Text>
            </View>
          </View>
        </View>
        {getStatusIcon(match.status)}
      </View>

      <View style={styles.matchDetails}>
        <View style={styles.detailRow}>
          <MapPin size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.court.name}</Text>
        </View>
        <View style={styles.detailRow}>
          <Calendar size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.court.location}</Text>
        </View>
        <View style={styles.detailRow}>
          <Clock size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.timestamp}</Text>
        </View>
      </View>

      <View style={styles.actionButtonsRow}>
        <TouchableOpacity
          style={[styles.actionButton, { backgroundColor: '#F97316', flex: 1, marginRight: 8 }]}
          onPress={() => {
            setSelectedMatch(match);
            setLogModalVisible(true);
          }}
        >
          <Text style={styles.actionButtonText}>Log Result</Text>
        </TouchableOpacity>
        
        <TouchableOpacity
          style={[styles.secondaryButton, { flex: 1, marginLeft: 8 }]}
          onPress={() => {
            // Handle change court - returns to Accept tab
          }}
        >
          <Text style={styles.secondaryButtonText}>Change Court</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const StandardMatchCard = ({ match }: { match: Match }) => (
    <View style={styles.matchCard}>
      <View style={styles.matchHeader}>
        <View style={styles.opponentInfo}>
          <Image source={{ uri: match.opponent.profilePic }} style={styles.opponentAvatar} />
          <View style={styles.opponentDetails}>
            <Text style={styles.opponentName}>{match.opponent.username}</Text>
            <View style={styles.matchMeta}>
              <Text style={styles.sportEmoji}>{getSportEmoji(match.sport)}</Text>
              <Text style={styles.sportText}>{match.sport}</Text>
            </View>
          </View>
        </View>
        {getStatusIcon(match.status)}
      </View>

      <View style={styles.matchDetails}>
        <View style={styles.detailRow}>
          <MapPin size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.court.name}</Text>
        </View>
        <View style={styles.detailRow}>
          <Calendar size={16} color="#64748B" />
          <Text style={styles.detailText}>{match.court.location}</Text>
        </View>
        <View style={styles.detailRow}>
          <Clock size={16} color="#64748B" />
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
          if (match.status === 'to-verify') {
            // Handle verify
          } else if (match.status === 'disputed') {
            // Handle view dispute
          }
        }}
      >
        <Text style={styles.actionButtonText}>{getActionButtonText(match.status, match)}</Text>
      </TouchableOpacity>
    </View>
  );

  const renderMatchCard = (match: Match) => {
    switch (match.status) {
      case 'accept':
        return <AcceptMatchCard key={match.id} match={match} />;
      case 'to-log':
        return <ToLogMatchCard key={match.id} match={match} />;
      default:
        return <StandardMatchCard key={match.id} match={match} />;
    }
  };

  const getActionButtonColor = (status: string) => {
    switch (status) {
      case 'accept':
        return '#F97316';
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
      <View style={styles.tabRowWrapper}>
        <ScrollView 
          horizontal 
          showsHorizontalScrollIndicator={false}
          style={styles.tabScrollView}
          contentContainerStyle={styles.tabScrollContent}
        >
          {[
            { key: 'accept', label: 'Accept', count: mockMatches.filter(m => m.status === 'accept').length },
            { key: 'to-log', label: 'Log', count: mockMatches.filter(m => m.status === 'to-log').length },
            { key: 'to-verify', label: 'Verify', count: mockMatches.filter(m => m.status === 'to-verify').length },
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
                  <Text style={styles.tabBadgeText}>
                    {tab.count}
                  </Text>
                </View>
              )}
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Matches List */}
      <ScrollView style={styles.matchesList} showsVerticalScrollIndicator={false}>
        {filteredMatches.length > 0 ? (
          filteredMatches.map((match) => renderMatchCard(match))
        ) : (
          <View style={styles.emptyState}>
            <Trophy size={48} color="#D1D5DB" />
            <Text style={styles.emptyStateText}>
              {activeTab === 'accept' && 'No matches to accept'}
              {activeTab === 'to-log' && 'No matches to log'}
              {activeTab === 'to-verify' && 'No matches to verify'}
              {activeTab === 'disputed' && 'No disputed matches'}
            </Text>
            <Text style={styles.emptyStateSubtext}>
              {activeTab === 'accept' 
                ? 'Challenge players to see matches here' 
                : activeTab === 'to-log'
                ? 'Accept challenges to log results'
                : activeTab === 'to-verify'
                ? 'Log match results to verify them'
                : 'All disputes resolved!'}
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
                  <Text style={styles.modalSubtext}>{selectedMatch.sport} • {selectedMatch.court.name}</Text>
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
  tabScrollContainer: {
    marginTop: 16,
  },
  tabRowWrapper: {
    paddingHorizontal: 20,
    flexShrink: 1,
  },
  tabScrollView: {},
  tabScrollContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  tabContainer: {
    paddingHorizontal: 20,
    paddingVertical: 0,
    flexDirection: 'row',
  },
  tab: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 0,
    paddingHorizontal: 16,
    borderRadius: 20,
    marginRight: 12,
    backgroundColor: '#F8FAFC',
    borderWidth: 0,
  },
  activeTab: {
    backgroundColor: '#2563EB',
    borderColor: 'transparent',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    elevation: 5,
  },
  tabText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#64748B',
  },
  activeTabText: {
    fontFamily: 'Inter-SemiBold',
    color: '#FFFFFF',
  },
  tabBadge: {
    width: 20,
    height: 20,
    borderRadius: 10,
    marginLeft: 6,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F97316',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.3)',
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
  sportEmoji: {
    fontSize: 16,
    marginRight: 6,
  },
  sportText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
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
  statusContainer: {
    marginTop: 8,
    padding: 8,
    backgroundColor: '#F8FAFC',
    borderRadius: 8,
  },
  statusText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
    textAlign: 'center',
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
  actionButtonsRow: {
    flexDirection: 'row',
    alignItems: 'center',
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
  secondaryButton: {
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    backgroundColor: '#FFFFFF',
  },
  secondaryButtonText: {
    fontSize: 14,
    fontFamily: 'Inter-SemiBold',
    color: '#64748B',
  },
  disabledButton: {
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignItems: 'center',
    backgroundColor: '#F1F5F9',
  },
  disabledButtonText: {
    fontSize: 14,
    fontFamily: 'Inter-SemiBold',
    color: '#10B981',
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