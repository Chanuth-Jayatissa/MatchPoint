import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

// Utility function as suggested by the original comments
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
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Home Screen</Text>
      </View>
      <View style={styles.content}>
        <Text style={styles.welcomeText}>Welcome to your Bolt Expo app!</Text>
        <Text style={styles.subText}>This is the home screen.</Text>
        <Text style={styles.emojiExample}>Example sport emoji: {getSportEmoji('Pickleball')}</Text>
      </View>
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
    fontWeight: 'bold',
    color: '#0F172A',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  welcomeText: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 10,
    textAlign: 'center',
  },
  subText: {
    fontSize: 16,
    color: '#64748B',
    textAlign: 'center',
  },
  emojiExample: {
    fontSize: 18,
    fontWeight: '500',
    marginTop: 20,
  },
});