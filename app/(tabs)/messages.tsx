import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Image,
  Modal,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MessageCircle, Send, ArrowLeft, MoveHorizontal as MoreHorizontal, Flag, UserX } from 'lucide-react-native';

interface Message {
  id: string;
  text: string;
  timestamp: string;
  isFromMe: boolean;
}

interface Thread {
  id: string;
  opponent: {
    username: string;
    profilePic: string;
  };
  lastMessage: string;
  timestamp: string;
  isUnread: boolean;
  messages: Message[];
}

const mockThreads: Thread[] = [
  {
    id: '1',
    opponent: {
      username: 'TennisAce_23',
      profilePic: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    lastMessage: 'Great match! Looking forward to the rematch.',
    timestamp: '2 min ago',
    isUnread: true,
    messages: [
      { id: '1', text: 'Hey! Ready for our match?', timestamp: '10:30 AM', isFromMe: false },
      { id: '2', text: 'Absolutely! See you at Downtown Court #1', timestamp: '10:32 AM', isFromMe: true },
      { id: '3', text: 'Perfect, I\'ll be there 15 minutes early to warm up', timestamp: '10:35 AM', isFromMe: false },
      { id: '4', text: 'Sounds good! Bring your A-game 😄', timestamp: '10:36 AM', isFromMe: true },
      { id: '5', text: 'Great match! Looking forward to the rematch.', timestamp: '2:15 PM', isFromMe: false },
    ]
  },
  {
    id: '2',
    opponent: {
      username: 'BadmintonPro',
      profilePic: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    lastMessage: 'Thanks for the tips on footwork!',
    timestamp: '1 hour ago',
    isUnread: false,
    messages: [
      { id: '1', text: 'Hi! I saw your post about footwork tips', timestamp: '9:15 AM', isFromMe: false },
      { id: '2', text: 'Sure! The key is to stay on your toes and use small, quick steps', timestamp: '9:20 AM', isFromMe: true },
      { id: '3', text: 'Also, practice the split step timing', timestamp: '9:21 AM', isFromMe: true },
      { id: '4', text: 'Thanks for the tips on footwork!', timestamp: '9:45 AM', isFromMe: false },
    ]
  },
  {
    id: '3',
    opponent: {
      username: 'PingPongKing',
      profilePic: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    },
    lastMessage: 'Let\'s play again soon!',
    timestamp: '2 days ago',
    isUnread: false,
    messages: [
      { id: '1', text: 'GG! That backhand loop was incredible', timestamp: 'Mon 3:30 PM', isFromMe: true },
      { id: '2', text: 'Thanks! You really pushed me to play better', timestamp: 'Mon 3:32 PM', isFromMe: false },
      { id: '3', text: 'Let\'s play again soon!', timestamp: 'Mon 3:35 PM', isFromMe: false },
    ]
  },
];

export default function MessagesScreen() {
  const [selectedThread, setSelectedThread] = useState<Thread | null>(null);
  const [messageText, setMessageText] = useState('');
  const [optionsVisible, setOptionsVisible] = useState(false);

  const ThreadItem = ({ thread }: { thread: Thread }) => (
    <TouchableOpacity
      style={styles.threadItem}
      onPress={() => setSelectedThread(thread)}
    >
      <Image source={{ uri: thread.opponent.profilePic }} style={styles.threadAvatar} />
      <View style={styles.threadContent}>
        <View style={styles.threadHeader}>
          <Text style={styles.threadUsername}>{thread.opponent.username}</Text>
          <Text style={styles.threadTimestamp}>{thread.timestamp}</Text>
        </View>
        <View style={styles.threadFooter}>
          <Text style={[
            styles.lastMessage,
            thread.isUnread && styles.unreadMessage
          ]} numberOfLines={1}>
            {thread.lastMessage}
          </Text>
          {thread.isUnread && <View style={styles.unreadBadge} />}
        </View>
      </View>
    </TouchableOpacity>
  );

  const MessageBubble = ({ message }: { message: Message }) => (
    <View style={[
      styles.messageBubble,
      message.isFromMe ? styles.myMessage : styles.theirMessage
    ]}>
      <Text style={[
        styles.messageText,
        message.isFromMe ? styles.myMessageText : styles.theirMessageText
      ]}>
        {message.text}
      </Text>
      <Text style={[
        styles.messageTimestamp,
        message.isFromMe ? styles.myMessageTimestamp : styles.theirMessageTimestamp
      ]}>
        {message.timestamp}
      </Text>
    </View>
  );

  const sendMessage = () => {
    if (messageText.trim() && selectedThread) {
      // In a real app, this would send the message
      setMessageText('');
    }
  };

  if (selectedThread) {
    return (
      <SafeAreaView style={styles.container}>
        {/* Chat Header */}
        <View style={styles.chatHeader}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => setSelectedThread(null)}
          >
            <ArrowLeft size={24} color="#1D4ED8" />
          </TouchableOpacity>
          
          <TouchableOpacity style={styles.chatUserInfo}>
            <Image source={{ uri: selectedThread.opponent.profilePic }} style={styles.chatAvatar} />
            <Text style={styles.chatUsername}>{selectedThread.opponent.username}</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.optionsButton}
            onPress={() => setOptionsVisible(true)}
          >
            <MoreHorizontal size={24} color="#64748B" />
          </TouchableOpacity>
        </View>

        {/* Messages */}
        <ScrollView style={styles.messagesContainer} showsVerticalScrollIndicator={false}>
          {selectedThread.messages.map((message) => (
            <MessageBubble key={message.id} message={message} />
          ))}
        </ScrollView>

        {/* Warning Message */}
        <View style={styles.warningContainer}>
          <Text style={styles.warningText}>
            This chat disappears 24h after match verification.
          </Text>
        </View>

        {/* Input Bar */}
        <KeyboardAvoidingView 
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={styles.inputContainer}
        >
          <TextInput
            style={styles.messageInput}
            placeholder="Type a message..."
            value={messageText}
            onChangeText={setMessageText}
            multiline
          />
          <TouchableOpacity
            style={[styles.sendButton, { opacity: messageText.trim() ? 1 : 0.5 }]}
            onPress={sendMessage}
            disabled={!messageText.trim()}
          >
            <Send size={20} color="#FFFFFF" />
          </TouchableOpacity>
        </KeyboardAvoidingView>

        {/* Options Modal */}
        <Modal
          visible={optionsVisible}
          transparent={true}
          animationType="fade"
          onRequestClose={() => setOptionsVisible(false)}
        >
          <TouchableOpacity
            style={styles.modalOverlay}
            activeOpacity={1}
            onPress={() => setOptionsVisible(false)}
          >
            <View style={styles.optionsMenu}>
              <TouchableOpacity style={styles.optionItem}>
                <Flag size={20} color="#EF4444" />
                <Text style={[styles.optionText, { color: '#EF4444' }]}>Report User</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.optionItem}>
                <UserX size={20} color="#EF4444" />
                <Text style={[styles.optionText, { color: '#EF4444' }]}>Block User</Text>
              </TouchableOpacity>
            </View>
          </TouchableOpacity>
        </Modal>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Messages</Text>
      </View>

      {/* Threads List */}
      <ScrollView style={styles.threadsList} showsVerticalScrollIndicator={false}>
        {mockThreads.length > 0 ? (
          mockThreads.map((thread) => (
            <ThreadItem key={thread.id} thread={thread} />
          ))
        ) : (
          <View style={styles.emptyState}>
            <MessageCircle size={48} color="#D1D5DB" />
            <Text style={styles.emptyStateText}>No messages yet</Text>
            <Text style={styles.emptyStateSubtext}>
              Start challenging players to begin conversations!
            </Text>
          </View>
        )}
      </ScrollView>
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
  threadsList: {
    flex: 1,
  },
  threadItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F1F5F9',
  },
  threadAvatar: {
    width: 50,
    height: 50,
    borderRadius: 25,
    marginRight: 12,
  },
  threadContent: {
    flex: 1,
  },
  threadHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  threadUsername: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
  },
  threadTimestamp: {
    fontSize: 12,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
  },
  threadFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  lastMessage: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    flex: 1,
  },
  unreadMessage: {
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
  },
  unreadBadge: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#F97316',
    marginLeft: 8,
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
  // Chat Screen Styles
  chatHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  backButton: {
    marginRight: 12,
  },
  chatUserInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  chatAvatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
    marginRight: 12,
  },
  chatUsername: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
  },
  optionsButton: {
    marginLeft: 12,
  },
  messagesContainer: {
    flex: 1,
    paddingHorizontal: 20,
    paddingVertical: 16,
  },
  messageBubble: {
    maxWidth: '80%',
    marginVertical: 4,
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
  },
  myMessage: {
    alignSelf: 'flex-end',
    backgroundColor: '#1D4ED8',
    borderBottomRightRadius: 6,
  },
  theirMessage: {
    alignSelf: 'flex-start',
    backgroundColor: '#F1F5F9',
    borderBottomLeftRadius: 6,
  },
  messageText: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    lineHeight: 20,
    marginBottom: 4,
  },
  myMessageText: {
    color: '#FFFFFF',
  },
  theirMessageText: {
    color: '#0F172A',
  },
  messageTimestamp: {
    fontSize: 12,
    fontFamily: 'Inter-Regular',
  },
  myMessageTimestamp: {
    color: 'rgba(255, 255, 255, 0.8)',
    textAlign: 'right',
  },
  theirMessageTimestamp: {
    color: '#64748B',
  },
  warningContainer: {
    paddingHorizontal: 20,
    paddingVertical: 8,
    backgroundColor: '#FEF3C7',
    borderTopWidth: 1,
    borderTopColor: '#F59E0B',
  },
  warningText: {
    fontSize: 12,
    fontFamily: 'Inter-Regular',
    color: '#92400E',
    textAlign: 'center',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
    backgroundColor: '#FFFFFF',
  },
  messageInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 24,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
    maxHeight: 100,
    marginRight: 12,
  },
  sendButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#F97316',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  optionsMenu: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingVertical: 8,
    minWidth: 160,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 8,
  },
  optionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  optionText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    marginLeft: 12,
  },
});