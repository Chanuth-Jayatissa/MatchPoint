const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Enable TypeScript support
config.resolver.sourceExts.push('ts', 'tsx');

// Add TTF and SVG support for fonts and icons
config.resolver.assetExts.push('ttf', 'svg');

// Ensure proper module resolution for web platform
config.resolver.resolverMainFields = ['react-native', 'browser', 'main'];
config.resolver.platforms = ['ios', 'android', 'native', 'web'];

module.exports = config;