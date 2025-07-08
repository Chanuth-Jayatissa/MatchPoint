import { Tabs } from 'expo-router';
import { BlurView } from 'expo-blur';
import { Platform, View, TouchableOpacity, Text } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Chrome as Home, Trophy, Users, MessageCircle, User } from 'lucide-react-native';

// Custom tab bar component for premium floating design
function CustomTabBar({ state, descriptors, navigation }: any) {
  const insets = useSafeAreaInsets();

  const getIconComponent = (routeName: string, color: string, size: number) => {
    const iconProps = {
      size: size - 1,
      color,
      strokeWidth: 1.8,
    };

    let IconComponent;
    switch (routeName) {
      case 'index':
        IconComponent = Home;
        break;
      case 'matches':
        IconComponent = Trophy;
        break;
      case 'community':
        IconComponent = Users;
        break;
      case 'messages':
        IconComponent = MessageCircle;
        break;
      case 'profile':
        IconComponent = User;
        break;
      default:
        IconComponent = Home;
    }

    return <IconComponent {...iconProps} />;
  };

  const handleTabPress = (route: any, index: number) => {
    // Haptic feedback
    if (Platform.OS !== 'web') {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }

    const event = navigation.emit({
      type: 'tabPress',
      target: route.key,
      canPreventDefault: true,
    });

    if (!event.defaultPrevented) {
      navigation.navigate(route.name);
    }
  };

  // Calculate bottom margin based on safe area
  const bottomMargin = Math.max(insets.bottom + 12, 16);

  return (
    <View style={[styles.tabBarContainer, { bottom: bottomMargin }]}>
      {Platform.OS === 'ios' ? (
        <BlurView
          intensity={35}
          tint="light"
          style={styles.blurContainer}
        >
          <View style={styles.overlayBackground} />
          <View style={styles.tabBarContent}>
            {state.routes.map((route: any, index: number) => {
              const { options } = descriptors[route.key];
              const label = options.tabBarLabel !== undefined 
                ? options.tabBarLabel 
                : options.title !== undefined 
                ? options.title 
                : route.name;

              const isFocused = state.index === index;

              return (
                <TouchableOpacity
                  key={route.key}
                  onPress={() => handleTabPress(route, index)}
                  style={styles.tabItem}
                  activeOpacity={0.8}
                  accessibilityRole="button"
                  accessibilityState={isFocused ? { selected: true } : {}}
                  accessibilityLabel={`${label} tab`}
                >
                  <View style={styles.tabContent}>
                    {getIconComponent(
                      route.name,
                      isFocused ? '#F97316' : '#1D4ED8',
                      22
                    )}
                    <Text
                      style={[
                        styles.tabLabel,
                        {
                          color: isFocused ? '#F97316' : '#1D4ED8',
                          fontWeight: isFocused ? '600' : '500',
                        },
                      ]}
                      numberOfLines={1}
                      adjustsFontSizeToFit={true}
                      minimumFontScale={0.8}
                    >
                      {label}
                    </Text>
                  </View>
                </TouchableOpacity>
              );
            })}
          </View>
        </BlurView>
      ) : (
        <View style={[styles.blurContainer, styles.androidBackground]}>
          <View style={styles.overlayBackground} />
          <View style={styles.tabBarContent}>
            {state.routes.map((route: any, index: number) => {
              const { options } = descriptors[route.key];
              const label = options.tabBarLabel !== undefined 
                ? options.tabBarLabel 
                : options.title !== undefined 
                ? options.title 
                : route.name;

              const isFocused = state.index === index;

              return (
                <TouchableOpacity
                  key={route.key}
                  onPress={() => handleTabPress(route, index)}
                  style={styles.tabItem}
                  activeOpacity={0.8}
                  accessibilityRole="button"
                  accessibilityState={isFocused ? { selected: true } : {}}
                  accessibilityLabel={`${label} tab`}
                >
                  <View style={styles.tabContent}>
                    {getIconComponent(
                      route.name,
                      isFocused ? '#F97316' : '#1D4ED8',
                      22
                    )}
                    <Text
                      style={[
                        styles.tabLabel,
                        {
                          color: isFocused ? '#F97316' : '#1D4ED8',
                          fontWeight: isFocused ? '600' : '500',
                        },
                      ]}
                      numberOfLines={1}
                      adjustsFontSizeToFit={true}
                      minimumFontScale={0.8}
                    >
                      {label}
                    </Text>
                  </View>
                </TouchableOpacity>
              );
            })}
          </View>
        </View>
      )}
    </View>
  );
}

export default function TabLayout() {
  return (
    <Tabs
      tabBar={(props) => <CustomTabBar {...props} />}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
        }}
      />
      <Tabs.Screen
        name="matches"
        options={{
          title: 'Matches',
        }}
      />
      <Tabs.Screen
        name="social"
        options={{
          title: 'Social',
        }}
      />
      <Tabs.Screen
        name="messages"
        options={{
          title: 'Messages',
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
        }}
      />
    </Tabs>
  );
}

const styles = {
  tabBarContainer: {
    position: 'absolute',
    left: 18,
    right: 18,
    height: 76,
    borderRadius: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.10,
    shadowRadius: 16,
    elevation: 20,
  },
  blurContainer: {
    flex: 1,
    borderRadius: 24,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.2)',
  },
  androidBackground: {
    backgroundColor: 'rgba(255,255,255,0.90)',
  },
  overlayBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(255,255,255,0.90)',
    borderRadius: 24,
  },
  tabBarContent: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingHorizontal: 2,
    paddingVertical: 8,
    zIndex: 1,
  },
  tabItem: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    minHeight: 48,
    minWidth: 48,
    paddingHorizontal: 2,
  },
  tabContent: {
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1,
    paddingVertical: 6,
    paddingHorizontal: 4,
  },
  tabLabel: {
    fontSize: 10,
    fontFamily: 'Inter-Medium',
    marginTop: 2,
    textAlign: 'center',
    letterSpacing: 0.1,
  },
};