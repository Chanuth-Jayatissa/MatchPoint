import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Star, Trophy, Users, Calendar } from 'lucide-react-native';

// Add the missing getSportEmoji function
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

export default function HomeScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        <View style={styles.header}>
          <Text style={styles.title}>Welcome Back!</Text>
          <Text style={styles.subtitle}>Ready for your next match?</Text>
        </View>

        <View style={styles.statsContainer}>
          <View style={styles.statItem}>
            <Trophy size={24} color="#F59E0B" />
            <Text style={styles.statNumber}>12</Text>
            <Text style={styles.statLabel}>Wins</Text>
          </View>
          
          <View style={styles.statItem}>
            <Star size={24} color="#F59E0B" />
            <Text style={styles.statNumber}>4.8</Text>
            <Text style={styles.statLabel}>Rating</Text>
          </View>
          
          <View style={styles.statItem}>
            <Users size={24} color="#F59E0B" />
            <Text style={styles.statNumber}>8</Text>
            <Text style={styles.statLabel}>Friends</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent Matches</Text>
          
          <TouchableOpacity style={styles.matchCard}>
            <View style={styles.matchHeader}>
              <Text style={styles.sportEmoji}>{getSportEmoji('Pickleball')}</Text>
              <View style={styles.matchInfo}>
                <Text style={styles.matchSport}>Pickleball</Text>
                <Text style={styles.matchDate}>Today, 2:00 PM</Text>
              </View>
              <View style={styles.matchResult}>
                <Text style={styles.resultText}>Won</Text>
              </View>
            </View>
          </TouchableOpacity>

          <TouchableOpacity style={styles.matchCard}>
            <View style={styles.matchHeader}>
              <Text style={styles.sportEmoji}>{getSportEmoji('Badminton')}</Text>
              <View style={styles.matchInfo}>
                <Text style={styles.matchSport}>Badminton</Text>
                <Text style={styles.matchDate}>Yesterday, 6:30 PM</Text>
              </View>
              <View style={styles.matchResult}>
                <Text style={styles.resultText}>Lost</Text>
              </View>
            </View>
          </TouchableOpacity>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Quick Actions</Text>
          
          <TouchableOpacity style={styles.actionButton}>
            <Calendar size={20} color="#FFFFFF" />
            <Text style={styles.actionButtonText}>Schedule Match</Text>
          </TouchableOpacity>
          
          <TouchableOpacity style={[styles.actionButton, styles.secondaryButton]}>
            <Users size={20} color="#3B82F6" />
            <Text style={[styles.actionButtonText, styles.secondaryButtonText]}>Find Players</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  scrollView: {
    flex: 1,
  },
  header: {
    padding: 20,
    paddingTop: 10,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 16,
    color: '#6B7280',
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingHorizontal: 20,
    paddingVertical: 20,
    backgroundColor: '#FFFFFF',
    marginHorizontal: 20,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  statItem: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
    marginTop: 8,
  },
  statLabel: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 4,
  },
  section: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 16,
  },
  matchCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.05,
    shadowRadius: 2.22,
    elevation: 3,
  },
  matchHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  sportEmoji: {
    fontSize: 32,
    marginRight: 12,
  },
  matchInfo: {
    flex: 1,
  },
  matchSport: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1F2937',
  },
  matchDate: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 2,
  },
  matchResult: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    backgroundColor: '#10B981',
  },
  resultText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#3B82F6',
    paddingVertical: 16,
    paddingHorizontal: 24,
    borderRadius: 12,
    marginBottom: 12,
  },
  actionButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginLeft: 8,
  },
  secondaryButton: {
    backgroundColor: '#EFF6FF',
    borderWidth: 1,
    borderColor: '#3B82F6',
  },
  secondaryButtonText: {
    color: '#3B82F6',
  },
});