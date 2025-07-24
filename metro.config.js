const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

// Add TTF support for fonts
config.resolver.assetExts.push('ttf');

// Add custom resolver to handle native-only modules on web
config.resolver.resolverMainFields = ['react-native', 'browser', 'main'];
config.resolver.platforms = ['ios', 'android', 'native', 'web'];

// Add custom resolver function to handle native modules for web
const originalResolver = config.resolver.resolveRequest;
config.resolver.resolveRequest = (context, moduleName, platform) => {
  // Handle react-native module imports for web platform
  if (platform === 'web' && moduleName === 'react-native') {
    return {
      filePath: path.resolve(__dirname, 'web/react-native-web-mock.js'),
      type: 'sourceFile',
    };
  }

  // Handle specific native-only modules for web
  if (platform === 'web') {
    if (
      moduleName === 'react-native-maps' || 
      moduleName === 'expo-location'
    ) {
      return {
        filePath: path.resolve(__dirname, 'web/empty.js'),
        type: 'sourceFile',
      };
    }
    
    // Handle react-native-reanimated for web
    if (moduleName === 'react-native-reanimated') {
      try {
        return {
          filePath: require.resolve('react-native-reanimated/lib/module/reanimated2/index.web.js'),
          type: 'sourceFile',
        };
      } catch (e) {
        // Fallback if web version not found
        return {
          filePath: require.resolve('react-native-reanimated'),
          type: 'sourceFile',
        };
      }
    }
    
    // Handle react-native-gesture-handler for web
    if (moduleName === 'react-native-gesture-handler') {
      try {
        return {
          filePath: require.resolve('react-native-gesture-handler/lib/module/index.web.js'),
          type: 'sourceFile',
        };
      } catch (e) {
        // Fallback if web version not found
        return {
          filePath: require.resolve('react-native-gesture-handler'),
          type: 'sourceFile',
        };
      }
    }
  }
  
  // Use default resolver for other cases
  if (originalResolver) {
    return originalResolver(context, moduleName, platform);
  }
  
  return context.resolveRequest(context, moduleName, platform);
};

module.exports = config;