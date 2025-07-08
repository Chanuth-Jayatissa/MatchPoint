// Empty module for web compatibility
// This file is used to replace native-only modules on web platform

export default {};

// Export common react-native-maps patterns
export const MapView = () => null;
export const Marker = () => null;
export const PROVIDER_GOOGLE = 'google';

// Location module exports for expo-location
export const requestForegroundPermissionsAsync = () => Promise.resolve({ status: 'denied' });
export const getCurrentPositionAsync = () => Promise.resolve(null);
export const LocationAccuracy = {
  Lowest: 1,
  Low: 2,
  Balanced: 3,
  High: 4,
  Highest: 5,
  BestForNavigation: 6,
};
export const LocationSubscription = {
  remove: () => {},
};