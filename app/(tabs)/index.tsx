import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity, 
  Modal,
  Image,
  ScrollView,
  Switch,
  Dimensions,
  Platform,
  Animated,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import * as Location from 'expo-location';
import { 
  Filter, 
  MapPin, 
  X,
  Trophy,
  Star,
  Zap,
  Check
} from 'lucide-react-native';
import { router } from 'expo-router';
import { useFocusEffect } from 'expo-router';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

interface Player {
  id: string;
  username: string;
  profilePic: string;
  sport: string;
  rating: number;
  availableNow: boolean;
  respectScore: number;
  location: string;
  recentMatches: number;
  zone: string;
}

interface PlayZone {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  players: Player[];
  isUserZone: boolean;
}

interface Court {
  id: string;
  name: string;
  sports: string[];
  location: string;
  image?: string;
  latitude: number;
  longitude: number;
}

const mockPlayers: Player[] = [
  {
    id: '1',
    username: 'PickleballAce_23',
    profilePic: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    sport: 'Pickleball',
    rating: 1850,
    availableNow: true,
    respectScore: 92,
    location: 'Downtown Courts',
    recentMatches: 15,
    zone: 'Downtown Sports Complex'
  },
  {
    id: '2',
    username: 'BadmintonPro',
    profilePic: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    sport: 'Badminton',
    rating: 1650,
    availableNow: true,
    respectScore: 88,
    location: 'University Gym',
    recentMatches: 22,
    zone: 'University Recreation Center'
  },
  {
    id: '3',
    username: 'PingPongKing',
    profilePic: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    sport: 'Table Tennis',
    rating: 1720,
    availableNow: false,
    respectScore: 95,
    location: 'Community Center',
    recentMatches: 8,
    zone: 'Community Sports Hub'
  },
  {
    id: '4',
    username: 'CourtCrusher',
    profilePic: 'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    sport: 'Pickleball',
    rating: 1920,
    availableNow: true,
    respectScore: 96,
    location: 'Downtown Courts',
    recentMatches: 28,
    zone: 'Downtown Sports Complex'
  },
];

const mockPlayZones: PlayZone[] = [
  {
    id: '1',
    name: 'Downtown Sports Complex',
    latitude: 40.7128,
    longitude: -74.0060,
    players: [mockPlayers[0], mockPlayers[3]],
    isUserZone: true
  },
  {
    id: '2',
    name: 'University Recreation Center',
    latitude: 40.7589,
    longitude: -73.9851,
    players: [mockPlayers[1]],
    isUserZone: false
  },
  {
    id: '3',
    name: 'Community Sports Hub',
    latitude: 40.6892,
    longitude: -74.0445,
    players: [mockPlayers[2]],
    isUserZone: false
  },
];

const mockCourts: Court[] = [
  {
    id: '1',
    name: 'Downtown Pickleball Court #1',
    sports: ['Pickleball'],
    location: 'Downtown Sports Complex',
    image: 'https://images.pexels.com/photos/209977/pexels-photo-209977.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
    latitude: 40.7128,
    longitude: -74.0060,
  },
  {
    id: '2',
    name: 'University Badminton Hall',
    sports: ['Badminton'],
    location: 'University Recreation Center',
    image: 'https://images.pexels.com/photos/1263348/pexels-photo-1263348.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
    latitude: 40.7589,
    longitude: -73.9851,
  },
  {
    id: '3',
    name: 'Community Ping Pong Room',
    sports: ['Table Tennis'],
    location: 'Community Sports Hub',
    image: 'https://images.pexels.com/photos/274422/pexels-photo-274422.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
    latitude: 40.6892,
    longitude: -74.0445,
  },
  {
    id: '4',
    name: 'Elite Pickleball Academy Court A',
    sports: ['Pickleball'],
    location: 'Downtown Sports Complex',
    image: 'https://images.pexels.com/photos/1263349/pexels-photo-1263349.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
    latitude: 40.7130,
    longitude: -74.0058,
  },
  {
    id: '5',
    name: 'Recreation Center Multi-Court',
    sports: ['Badminton', 'Table Tennis'],
    location: 'University Recreation Center',
    image: 'https://images.pexels.com/photos/863988/pexels-photo-863988.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
    latitude: 40.7591,
    longitude: -73.9849,
  },
];

export default function HomeScreen() {
  const { bottom: bottomPadding } = useSafeAreaInsets();
  const [filtersVisible, setFiltersVisible] = useState(false);
  const [selectedZone, setSelectedZone] = useState<PlayZone | null>(null);
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  const [courtMode, setCourtMode] = useState(false);
  const [selectedCourt, setSelectedCourt] = useState<Court | null>(null);
  const [challengingPlayer, setChallengingPlayer] = useState<Player | null>(null);
  const [showToast, setShowToast] = useState(false);
  const [toastMessage, setToastMessage] = useState('');
  const [userLocation, setUserLocation] = useState<Location.LocationObject | null>(null);
  const [locationPermission, setLocationPermission] = useState<Location.PermissionStatus | null>(null);
  
  const [filters, setFilters] = useState({
    sports: ['Pickleball', 'Badminton', 'Table Tennis'],
    availableNow: false,
  });

  const drawerAnimation = useRef(new Animated.Value(0)).current;
  const courtDrawerAnimation = useRef(new Animated.Value(0)).current;
  const playerCardAnimation = useRef(new Animated.Value(0)).current;
  const toastAnimation = useRef(new Animated.Value(0)).current;
  const mapRef = useRef<MapView>(null);

  const userZone = mockPlayZones.find(zone => zone.isUserZone);

  // Reset selectedZone when the Home tab comes into focus
  useFocusEffect(
    React.useCallback(() => {
      setSelectedZone(null);
    }, [])
  );

  // Request location permissions and get user location
  useEffect(() => {
    let isMounted = true;

    (async () => {
      if (Platform.OS === 'web') {
        // Skip location on web for now
        return;
      }

      let { status } = await Location.requestForegroundPermissionsAsync();
      if (isMounted) {
        setLocationPermission(status);
      }
      
      if (status !== 'granted') {
        console.log('Permission to access location was denied');
        return;
      }

      try {
        let location = await Location.getCurrentPositionAsync({});
        if (isMounted) {
          setUserLocation(location);
        }
      } catch (error) {
        console.log('Error getting location:', error);
      }
    })();

    return () => {
      isMounted = false;
    };
  }, []);

  // Center map on user's play zone when component mounts or when returning from court mode
  useEffect(() => {
    if (userZone && mapRef.current) {
      const timer = setTimeout(() => {
        mapRef.current?.animateToRegion({
          latitude: userZone.latitude,
          longitude: userZone.longitude,
          latitudeDelta: 0.05,
          longitudeDelta: 0.05,
        }, 1000);
      }, 500); // Small delay to ensure map is ready

      return () => clearTimeout(timer);
    }
  }, [userZone, courtMode]); // Re-center when exiting court mode

  // Get the region to display - always center on user's play zone
  const getMapRegion = () => {
    if (userZone) {
      return {
        latitude: userZone.latitude,
        longitude: userZone.longitude,
        latitudeDelta: 0.05,
        longitudeDelta: 0.05,
      };
    }
    
    // Fallback to default region if no user zone
    return {
      latitude: 40.7128,
      longitude: -74.0060,
      latitudeDelta: 0.0922,
      longitudeDelta: 0.0421,
    };
  };

  const getSportIcon = (sport: string) => {
    return <Trophy size={16} color="#F97316" />;
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

  const showDrawer = (zone: PlayZone) => {
    setSelectedZone(zone);
    Animated.spring(drawerAnimation, {
      toValue: 1,
      useNativeDriver: true,
      tension: 100,
      friction: 8,
    }).start();

    // Animate map to focus on the selected zone, adjusting for drawer visibility
    if (mapRef.current) {
      // Calculate vertical offset to keep the selected zone visible above the drawer
      // The drawer covers ~60% of screen height, so we shift the map center up significantly
      // to ensure the selected marker is clearly visible above the drawer
      const verticalOffset = -0.0085; // Negative offset to position marker optimally above drawer
      
      mapRef.current.animateToRegion({
        latitude: zone.latitude + verticalOffset,
        longitude: zone.longitude,
        latitudeDelta: 0.02,
        longitudeDelta: 0.02,
      }, 1000);
    }
  };

  const hideDrawer = () => {
    Animated.spring(drawerAnimation, {
      toValue: 0,
      useNativeDriver: true,
      tension: 100,
      friction: 8,
    }).start(() => {
      setSelectedZone(null);
    });

    // Return map to user's play zone
    if (mapRef.current && userZone) {
      mapRef.current.animateToRegion({
        latitude: userZone.latitude,
        longitude: userZone.longitude,
        latitudeDelta: 0.05,
        longitudeDelta: 0.05,
      }, 1000);
    }
  };

  const showCourtDrawer = (court: Court) => {
    setSelectedCourt(court);
    Animated.spring(courtDrawerAnimation, {
      toValue: 1,
      useNativeDriver: true,
      tension: 100,
      friction: 8,
    }).start();

    // Animate map to focus on the selected court, adjusting for drawer visibility
    if (mapRef.current) {
      // Calculate vertical offset to keep the selected court visible above the drawer
      // The drawer covers ~60% of screen height, so we shift the map center up
      // to ensure the selected marker is clearly visible above the drawer
      const verticalOffset = -0.004; // Reduced offset for better court marker visibility
      
      mapRef.current.animateToRegion({
        latitude: court.latitude + verticalOffset,
        longitude: court.longitude,
        latitudeDelta: 0.015,
        longitudeDelta: 0.015,
      }, 1000);
    }
  };

  const hideCourtDrawer = () => {
    Animated.spring(courtDrawerAnimation, {
      toValue: 0,
      useNativeDriver: true,
      tension: 100,
      friction: 8,
    }).start(() => {
      setSelectedCourt(null);
    });

    // Return map to user's play zone when closing court drawer
    if (mapRef.current && userZone) {
      mapRef.current.animateToRegion({
        latitude: userZone.latitude,
        longitude: userZone.longitude,
        latitudeDelta: 0.05,
        longitudeDelta: 0.05,
      }, 1000);
    }
  };

  const showToastMessage = (message: string) => {
    setToastMessage(message);
    setShowToast(true);
    Animated.sequence([
      Animated.timing(toastAnimation, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.delay(2500),
      Animated.timing(toastAnimation, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true,
      }),
    ]).start(() => {
      setShowToast(false);
    });
  };

  const showPlayerCard = (player: Player) => {
    setSelectedPlayer(player);
    Animated.spring(playerCardAnimation, {
      toValue: 1,
      useNativeDriver: true,
      tension: 100,
      friction: 8,
    }).start();
  };

  const hidePlayerCard = () => {
    Animated.spring(playerCardAnimation, {
      toValue: 0,
      useNativeDriver: true,
      tension: 100,
      friction: 8,
    }).start(() => {
      setSelectedPlayer(null);
    });
  };

  const handleChallenge = (player: Player) => {
    hidePlayerCard();
    setChallengingPlayer(player);
    setCourtMode(true);
  };

  const handleCourtSelect = (court: Court) => {
    if (challengingPlayer) {
      // Hide court drawer
      hideCourtDrawer();
      
      // Reset states
      setCourtMode(false);
      setChallengingPlayer(null);
      
      // Navigate to Matches tab immediately
      router.push('/(tabs)/matches');
    }
  };

  const resetToPlayerMode = () => {
    setCourtMode(false);
    setChallengingPlayer(null);
    hideCourtDrawer();
    
    // Return map to user's play zone
    if (mapRef.current && userZone) {
      mapRef.current.animateToRegion({
        latitude: userZone.latitude,
        longitude: userZone.longitude,
        latitudeDelta: 0.05,
        longitudeDelta: 0.05,
      }, 1000);
    }
  };

  const filteredZones = mockPlayZones.map(zone => ({
    ...zone,
    players: zone.players.filter(player => {
      const sportMatch = filters.sports.includes(player.sport);
      const availabilityMatch = !filters.availableNow || player.availableNow;
      return sportMatch && availabilityMatch;
    })
  })).filter(zone => zone.players.length > 0);

  const filteredCourts = mockCourts.filter(court => 
    court.sports.some(sport => filters.sports.includes(sport))
  );

  const MiniPlayerCard = ({ player }: { player: Player }) => (
    <TouchableOpacity
      style={styles.miniPlayerCard}
      onPress={() => showPlayerCard(player)}
    >
      <Image source={{ uri: player.profilePic }} style={styles.miniPlayerAvatar} />
      <Text style={styles.miniPlayerName} numberOfLines={1}>{player.username}</Text>
      <View style={styles.miniPlayerMeta}>
        {getSportIcon(player.sport)}
        {player.availableNow && <View style={styles.availabilityDot} />}
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Find Players Nearby</Text>
        <TouchableOpacity 
          style={styles.filterButton}
          onPress={() => setFiltersVisible(true)}
        >
          <Filter size={24} color="#1D4ED8" />
        </TouchableOpacity>
      </View>

      {/* Your Play Zone Badge */}
      {userZone && !courtMode && (
        <View style={styles.playZoneBadgeContainer}>
          <TouchableOpacity 
            style={styles.playZoneBadge}
            onPress={() => {
              if (mapRef.current && userZone) {
                mapRef.current.animateToRegion({
                  latitude: userZone.latitude,
                  longitude: userZone.longitude,
                  latitudeDelta: 0.02,
                  longitudeDelta: 0.02,
                }, 1000);
              }
            }}
          >
            <Text style={styles.playZoneBadgeText}>Your Play Zone: {userZone.name}</Text>
          </TouchableOpacity>
        </View>
      )}

      {/* Court Mode Header */}
      {courtMode && challengingPlayer && (
        <View style={styles.courtModeHeader}>
          <TouchableOpacity 
            style={styles.backButton}
            onPress={resetToPlayerMode}
          >
            <X size={20} color="#1D4ED8" />
          </TouchableOpacity>
          <Text style={styles.courtModeTitle}>
            Select Court for Challenge vs {challengingPlayer.username}
          </Text>
        </View>
      )}

      {/* Map Container */}
      <View style={styles.mapContainer}>
        {Platform.OS === 'web' ? (
          // Fallback for web - show placeholder
          <View style={[styles.mapPlaceholder, courtMode && styles.mapDimmed]}>
            <MapPin size={48} color="#1D4ED8" />
            <Text style={styles.mapText}>Interactive Map View</Text>
            <Text style={styles.mapSubtext}>
              {courtMode ? 'Select a court to challenge' : 'Tap zones to see players'}
            </Text>
            {userZone && (
              <Text style={styles.playZoneText}>
                Centered on: {userZone.name}
              </Text>
            )}
            <Text style={styles.webNote}>
              Map functionality requires native platform
            </Text>
          </View>
        ) : (
          <MapView
            ref={mapRef}
            style={styles.map}
            provider={PROVIDER_GOOGLE}
            initialRegion={getMapRegion()}
            showsUserLocation={locationPermission === 'granted'}
            showsMyLocationButton={false}
            showsCompass={false}
            toolbarEnabled={false}
          >
            {/* Zone Markers (Normal Mode Only) */}
            {!courtMode && filteredZones.map((zone) => (
              <Marker
                key={`zone-${zone.id}`}
                coordinate={{
                  latitude: zone.latitude,
                  longitude: zone.longitude,
                }}
                onPress={() => showDrawer(zone)}
                anchor={{ x: 0.5, y: 1 }}
              >
                <View style={styles.teardropMarker}>
                  <View style={[
                    styles.teardropBody,
                    { backgroundColor: zone.isUserZone ? '#1D4ED8' : '#F97316' }
                  ]}>
                    <MapPin size={14} color="#FFFFFF" strokeWidth={2} />
                  </View>
                  <View style={styles.playerCountBadge}>
                    <Text style={styles.playerCountText}>{zone.players.length}</Text>
                  </View>
                </View>
              </Marker>
            ))}

            {/* Court Markers (Court Mode Only) */}
            {courtMode && filteredCourts.map((court) => (
              <Marker
                key={`court-${court.id}`}
                coordinate={{
                  latitude: court.latitude,
                  longitude: court.longitude,
                }}
                onPress={() => showCourtDrawer(court)}
                anchor={{ x: 0.5, y: 1 }}
              >
                <View style={styles.teardropMarker}>
                  <View style={[styles.teardropBody, { backgroundColor: '#10B981' }]}>
                    <Trophy size={12} color="#FFFFFF" strokeWidth={2} />
                  </View>
                </View>
              </Marker>
            ))}
          </MapView>
        )}
      </View>

      {/* Zone Players Drawer */}
      {selectedZone && !courtMode && (
        <Animated.View
          style={[
            styles.drawer,
            {
              transform: [{
                translateY: drawerAnimation.interpolate({
                  inputRange: [0, 1],
                  outputRange: [screenHeight, 0],
                })
              }]
            }
          ]}
        >
          <View style={styles.drawerHandle} />
          <View style={styles.drawerHeader}>
            <Text style={styles.drawerTitle}>{selectedZone.name}</Text>
            <TouchableOpacity onPress={hideDrawer}>
              <X size={24} color="#64748B" />
            </TouchableOpacity>
          </View>
          
          <ScrollView style={styles.drawerContent} showsVerticalScrollIndicator={false}>
            {selectedZone.players.length > 0 ? (
              <View style={styles.playersGrid}>
                {selectedZone.players.map((player) => (
                  <MiniPlayerCard key={player.id} player={player} />
                ))}
              </View>
            ) : (
              <View style={styles.emptyState}>
                <MapPin size={48} color="#D1D5DB" />
                <Text style={styles.emptyStateText}>No players nearby right now</Text>
                <Text style={styles.emptyStateSubtext}>Try adjusting filters or check back later!</Text>
                <TouchableOpacity
                  style={styles.adjustFiltersButton}
                  onPress={() => {
                    hideDrawer();
                    setFiltersVisible(true);
                  }}
                >
                  <Text style={styles.adjustFiltersButtonText}>Adjust Filters</Text>
                </TouchableOpacity>
              </View>
            )}
          </ScrollView>
        </Animated.View>
      )}

      {/* Court Selection Drawer */}
      {selectedCourt && courtMode && (
        <Animated.View
          style={[
            styles.courtDrawer,
            {
              transform: [{
                translateY: courtDrawerAnimation.interpolate({
                  inputRange: [0, 1],
                  outputRange: [screenHeight, 0],
                })
              }]
            }
          ]}
        >
          <View style={styles.drawerHandle} />
          <View style={styles.drawerHeader}>
            <Text style={styles.drawerTitle}>Select Court</Text>
            <TouchableOpacity onPress={hideCourtDrawer}>
              <X size={24} color="#64748B" />
            </TouchableOpacity>
          </View>
          
          <ScrollView 
            cstyle={styles.courtDrawerContent}
            contentContainerStyle={{
              flexGrow: 1,
              paddingHorizontal: 20,
              paddingTop: 16,
              paddingBottom: 100,
            }}
            showsVerticalScrollIndicator={false}
          >
            <Text style={styles.courtName}>{selectedCourt.name}</Text>
            
            <View style={styles.courtSports}>
              {selectedCourt.sports.map((sport, index) => (
                <View key={index} style={styles.sportChip}>
                  <Text style={styles.sportEmoji}>{getSportEmoji(sport)}</Text>
                  <Text style={styles.sportChipText}>{sport}</Text>
                </View>
              ))}
            </View>
            
            <Text style={styles.courtLocation}>{selectedCourt.location}</Text>
            
            {selectedCourt.image && (
              <Image source={{ uri: selectedCourt.image }} style={styles.courtImage} />
            )}
            
            <TouchableOpacity
              style={styles.selectCourtButton}
              onPress={() => handleCourtSelect(selectedCourt)}
            >
              <Text style={styles.selectCourtButtonText}>Select This Court</Text>
            </TouchableOpacity>
          </ScrollView>
        </Animated.View>
      )}

      {/* Full Player Card Overlay */}
      {selectedPlayer && (
        <Animated.View
          style={[
            styles.playerCardOverlay,
            {
              opacity: playerCardAnimation,
              transform: [{
                translateY: playerCardAnimation.interpolate({
                  inputRange: [0, 1],
                  outputRange: [screenHeight, 0],
                })
              }]
            }
          ]}
        >
          <View style={styles.fullPlayerCard}>
            <TouchableOpacity
              style={styles.closeButton}
              onPress={hidePlayerCard}
            >
              <X size={24} color="#64748B" />
            </TouchableOpacity>
            
            <ScrollView  
              cstyle={styles.playerCardContent}
              contentContainerStyle={{
                flexGrow: 1,
                paddingHorizontal: 20,
                paddingTop: 16,
                paddingBottom: 120,
              }}
              showsVerticalScrollIndicator={false}
            >
              showsVerticalScrollIndicator={false}>
              <Image source={{ uri: selectedPlayer.profilePic }} style={styles.fullPlayerAvatar} />
              <Text style={styles.fullPlayerName}>{selectedPlayer.username}</Text>
              <Text style={styles.fullPlayerLocation}>{selectedPlayer.zone}</Text>
              
              <View style={styles.playerStats}>
                <View style={styles.statItem}>
                  {getSportIcon(selectedPlayer.sport)}
                  <Text style={styles.statText}>Rating: {selectedPlayer.rating}</Text>
                </View>
                
                <View style={styles.statItem}>
                  <Star size={16} color="#F59E0B" />
                  <Text style={styles.statText}>Respect: {selectedPlayer.respectScore}/100</Text>
                </View>
                
                <Text style={styles.recentMatchesText}>Recent matches: {selectedPlayer.recentMatches}</Text>
              </View>
              
              <TouchableOpacity
                style={styles.challengeButton}
                onPress={() => handleChallenge(selectedPlayer)}
              >
                <Zap size={20} color="#FFFFFF" />
                <Text style={styles.challengeButtonText}>Challenge Player</Text>
              </TouchableOpacity>
            </ScrollView>
          </View>
        </Animated.View>
      )}

      {/* Filters Modal */}
      <Modal
        visible={filtersVisible}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setFiltersVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.filtersModal}>
            <View style={styles.filtersHeader}>
              <Text style={styles.filtersTitle}>Filters</Text>
              <TouchableOpacity onPress={() => setFiltersVisible(false)}>
                <X size={24} color="#64748B" />
              </TouchableOpacity>
            </View>
            
            <View style={styles.filtersDivider} />
            
            <View style={styles.filtersContent}>
              <Text style={styles.filterSectionTitle}>Sports</Text>
              <View style={styles.sportsChips}>
                {['Pickleball', 'Badminton', 'Table Tennis'].map((sport) => (
                  <TouchableOpacity
                    key={sport}
                    style={[
                      styles.sportFilterChip,
                      filters.sports.includes(sport) && styles.sportFilterChipSelected
                    ]}
                    onPress={() => {
                      setFilters(prev => ({
                        ...prev,
                        sports: prev.sports.includes(sport)
                          ? prev.sports.filter(s => s !== sport)
                          : [...prev.sports, sport]
                      }));
                    }}
                  >
                    <Text style={[
                      styles.sportFilterChipText,
                      filters.sports.includes(sport) && styles.sportFilterChipTextSelected
                    ]}>
                      {sport}
                    </Text>
                    {filters.sports.includes(sport) && (
                      <Check size={16} color="#FFFFFF" />
                    )}
                  </TouchableOpacity>
                ))}
              </View>
              
              <View style={styles.availabilityFilter}>
                <Text style={styles.filterLabel}>Available Now</Text>
                <Switch
                  value={filters.availableNow}
                  onValueChange={(value) => setFilters(prev => ({ ...prev, availableNow: value }))}
                  trackColor={{ false: '#D1D5DB', true: '#1D4ED8' }}
                  thumbColor="#FFFFFF"
                />
              </View>
            </View>
            
            <View style={styles.filtersFooter}>
              <TouchableOpacity
                style={styles.resetButton}
                onPress={() => setFilters({ sports: ['Pickleball', 'Badminton', 'Table Tennis'], availableNow: false })}
              >
                <Text style={styles.resetButtonText}>Reset</Text>
              </TouchableOpacity>
              
              <TouchableOpacity
                style={styles.applyButton}
                onPress={() => setFiltersVisible(false)}
              >
                <Text style={styles.applyButtonText}>Apply Filters</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Toast Notification */}
      {showToast && (
        <Animated.View
          style={[
            styles.toast,
            {
              opacity: toastAnimation,
              transform: [{
                translateY: toastAnimation.interpolate({
                  inputRange: [0, 1],
                  outputRange: [100, 0],
                })
              }]
            }
          ]}
        >
          <Text style={styles.toastText}>{toastMessage}</Text>
        </Animated.View>
      )}
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
  filterButton: {
    padding: 8,
  },
  playZoneBadgeContainer: {
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  playZoneBadge: {
    backgroundColor: '#1D4ED8',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    alignSelf: 'flex-start',
  },
  playZoneBadgeText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontFamily: 'Inter-Medium',
  },
  courtModeHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: '#F8FAFC',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  backButton: {
    marginRight: 12,
    padding: 4,
  },
  courtModeTitle: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    flex: 1,
  },
  mapContainer: {
    flex: 1,
    position: 'relative',
  },
  map: {
    flex: 1,
  },
  mapPlaceholder: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F8FAFC',
  },
  mapText: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginTop: 12,
  },
  mapSubtext: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginTop: 4,
    textAlign: 'center',
  },
  playZoneText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#1D4ED8',
    marginTop: 8,
    textAlign: 'center',
  },
  webNote: {
    fontSize: 12,
    fontFamily: 'Inter-Regular',
    color: '#94A3B8',
    marginTop: 8,
    textAlign: 'center',
  },
  // Clean teardrop markers
  teardropMarker: {
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  teardropBody: {
    width: 36,
    height: 36,
    borderRadius: 18,
    borderTopLeftRadius: 18,
    borderTopRightRadius: 18,
    borderBottomLeftRadius: 18,
    borderBottomRightRadius: 2,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 3,
    borderColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
    elevation: 8,
    transform: [{ rotate: '45deg' }],
  },
  playerCountBadge: {
    position: 'absolute',
    top: -6,
    right: -6,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    width: 24,
    height: 24,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#1D4ED8',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 6,
  },
  playerCountText: {
    fontSize: 11,
    fontFamily: 'Inter-Bold',
    color: '#1D4ED8',
  },
  drawer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: screenHeight * 0.6,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 10,
  },
  courtDrawer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: screenHeight * 0.6,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 10,
  },
  drawerHandle: {
    width: 40,
    height: 4,
    backgroundColor: '#D1D5DB',
    borderRadius: 2,
    alignSelf: 'center',
    marginTop: 8,
    marginBottom: 16,
  },
  drawerHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  drawerTitle: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
  },
  drawerContent: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 16,
  },
  courtDrawerContent: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 120,
  },
  playersGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  miniPlayerCard: {
    width: (screenWidth - 60) / 2,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    borderWidth: 1,
    borderColor: '#F1F5F9',
  },
  miniPlayerAvatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    marginBottom: 12,
  },
  miniPlayerName: {
    fontSize: 14,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginBottom: 8,
    textAlign: 'center',
  },
  miniPlayerMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  availabilityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#10B981',
    marginLeft: 8,
  },
  courtName: {
    fontSize: 20,
    fontFamily: 'Inter-Bold',
    color: '#0F172A',
    marginBottom: 16,
  },
  courtSports: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 16,
  },
  sportChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F8FAFC',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    marginRight: 8,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  sportEmoji: {
    fontSize: 16,
    marginRight: 6,
  },
  sportChipText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
  },
  courtLocation: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginBottom: 16,
  },
  courtImage: {
    width: '100%',
    height: 150,
    borderRadius: 12,
    marginBottom: 24,
  },
  selectCourtButton: {
    backgroundColor: '#F97316',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    marginBottom: 20,
  },
  selectCourtButtonText: {
    fontSize: 16,
    fontFamily: 'Inter-Bold',
    color: '#FFFFFF',
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyStateText: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginTop: 16,
    marginBottom: 8,
    textAlign: 'center',
  },
  emptyStateSubtext: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    textAlign: 'center',
    marginBottom: 24,
  },
  adjustFiltersButton: {
    backgroundColor: '#1D4ED8',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 12,
  },
  adjustFiltersButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontFamily: 'Inter-SemiBold',
  },
  playerCardOverlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: screenHeight * 0.6,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 10,
    zIndex: 1000,
  },
  fullPlayerCard: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingTop: 20,
  },
  closeButton: {
    position: 'absolute',
    top: 20,
    right: 20,
    zIndex: 1,
    backgroundColor: '#F8FAFC',
    borderRadius: 20,
    padding: 8,
  },
  playerCardContent: {
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  fullPlayerAvatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    alignSelf: 'center',
    marginBottom: 16,
    marginTop: 20,
  },
  fullPlayerName: {
    fontSize: 24,
    fontFamily: 'Inter-Bold',
    color: '#0F172A',
    textAlign: 'center',
    marginBottom: 8,
  },
  fullPlayerLocation: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    textAlign: 'center',
    marginBottom: 24,
  },
  playerStats: {
    backgroundColor: '#F8FAFC',
    borderRadius: 16,
    padding: 20,
    marginBottom: 24,
  },
  statItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  statText: {
    fontSize: 16,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
    marginLeft: 8,
  },
  recentMatchesText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#64748B',
    marginTop: 8,
  },
  challengeButton: {
    flexDirection: 'row',
    backgroundColor: '#F97316',
    borderRadius: 12,
    paddingVertical: 16,
    paddingHorizontal: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  challengeButtonText: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#FFFFFF',
    marginLeft: 8,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  filtersModal: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '70%',
  },
  filtersHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 16,
  },
  filtersTitle: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
  },
  filtersDivider: {
    height: 1,
    backgroundColor: '#E5E7EB',
    marginHorizontal: 20,
  },
  filtersContent: {
    padding: 20,
  },
  filterSectionTitle: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#0F172A',
    marginBottom: 16,
  },
  sportsChips: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 24,
  },
  sportFilterChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#64748B',
    marginRight: 8,
    marginBottom: 8,
  },
  sportFilterChipSelected: {
    backgroundColor: '#1D4ED8',
    borderColor: '#1D4ED8',
  },
  sportFilterChipText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#0F172A',
  },
  sportFilterChipTextSelected: {
    color: '#FFFFFF',
    marginRight: 6,
  },
  availabilityFilter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
  },
  filterLabel: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#0F172A',
  },
  filtersFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 20,
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
  },
  resetButton: {
    paddingVertical: 12,
    paddingHorizontal: 24,
  },
  resetButtonText: {
    fontSize: 16,
    fontFamily: 'Inter-Medium',
    color: '#64748B',
  },
  applyButton: {
    backgroundColor: '#1D4ED8',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 12,
  },
  applyButtonText: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#FFFFFF',
  },
  toast: {
    position: 'absolute',
    bottom: 100,
    left: 20,
    right: 20,
    backgroundColor: '#10B981',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 5,
  },
  toastText: {
    fontSize: 14,
    fontFamily: 'Inter-SemiBold',
    color: '#FFFFFF',
    textAlign: 'center',
  },
});