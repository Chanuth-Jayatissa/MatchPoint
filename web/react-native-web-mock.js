// Comprehensive React Native web mock
// This file provides web-compatible implementations for React Native's native modules

// Re-export everything from react-native-web for standard components
export * from 'react-native-web';

// Mock UIManager with dummy implementations
export const UIManager = {
  hasViewManagerConfig: () => false,
  getViewManagerConfig: () => ({}),
  dispatchViewManagerCommand: () => {},
  measure: () => {},
  measureInWindow: () => {},
  measureLayout: () => {},
  measureLayoutRelativeToParent: () => {},
  setJSResponder: () => {},
  clearJSResponder: () => {},
  configureNextLayoutAnimation: () => {},
  sendAccessibilityEvent: () => {},
  showPopupMenu: () => {},
  dismissPopupMenu: () => {},
  setLayoutAnimationEnabledExperimental: () => {},
  removeSubviewsFromContainerWithID: () => {},
  replaceExistingNonRootView: () => {},
  setChildren: () => {},
  manageChildren: () => {},
  blur: () => {},
  focus: () => {},
  findSubviewIn: () => {},
  getConstantsForViewManager: () => ({}),
  getDefaultEventTypes: () => [],
  lazilyLoadView: () => {},
  createView: () => {},
  updateView: () => {},
  removeRootView: () => {},
  removeSubviewsFromContainerWithID: () => {},
};

// Mock NativeModules
export const NativeModules = {
  UIManager,
  DeviceInfo: {},
  PlatformConstants: {
    forceTouchAvailable: false,
    interfaceIdiom: 'pad',
    isTesting: false,
    osVersion: '16.0',
    reactNativeVersion: { major: 0, minor: 72, patch: 0 },
    systemName: 'iOS',
  },
  SourceCode: {
    scriptURL: null,
  },
  StatusBarManager: {
    HEIGHT: 20,
    getHeight: () => Promise.resolve(20),
  },
  KeyboardObserver: {
    addListener: () => ({ remove: () => {} }),
    removeListeners: () => {},
  },
  DevSettings: {
    addMenuItem: () => {},
    reload: () => {},
  },
  Timing: {
    createTimer: () => {},
    deleteTimer: () => {},
    setSendIdleEvents: () => {},
  },
  AppState: {
    addEventListener: () => ({ remove: () => {} }),
    getCurrentAppState: () => Promise.resolve({ app_state: 'active' }),
  },
  AsyncLocalStorage: {
    multiGet: () => Promise.resolve([]),
    multiSet: () => Promise.resolve(),
    multiRemove: () => Promise.resolve(),
    multiMerge: () => Promise.resolve(),
    clear: () => Promise.resolve(),
    getAllKeys: () => Promise.resolve([]),
  },
  I18nManager: {
    allowRTL: () => {},
    forceRTL: () => {},
    swapLeftAndRightInRTL: () => {},
    getConstants: () => ({
      isRTL: false,
      doLeftAndRightSwapInRTL: false,
    }),
  },
  DeviceEventManager: {
    invokeDefaultBackPressHandler: () => {},
  },
  BlobModule: {
    getConstants: () => ({}),
    addNetworkingHandler: () => {},
    addWebSocketHandler: () => {},
    removeWebSocketHandler: () => {},
    sendOverWebSocket: () => {},
    createFromParts: () => {},
    release: () => {},
  },
  WebSocketModule: {
    connect: () => {},
    send: () => {},
    sendBinary: () => {},
    ping: () => {},
    close: () => {},
    addListener: () => ({ remove: () => {} }),
  },
  NetworkingModule: {
    sendRequest: () => {},
    abortRequest: () => {},
    clearCookies: () => {},
    addListener: () => ({ remove: () => {} }),
  },
  Appearance: {
    getColorScheme: () => 'light',
    addChangeListener: () => ({ remove: () => {} }),
  },
  LogBox: {
    install: () => {},
    uninstall: () => {},
    ignoreLogs: () => {},
  },
};

// Mock Platform
export const Platform = {
  OS: 'web',
  Version: '1.0',
  isPad: false,
  isTVOS: false,
  isTV: false,
  isTesting: false,
  select: (obj) => obj.web || obj.default,
  constants: {
    reactNativeVersion: { major: 0, minor: 72, patch: 0 },
    Version: '1.0',
    Release: '1.0',
    Serial: 'unknown',
    Fingerprint: 'unknown',
    Model: 'web',
    ServerHost: undefined,
    uiMode: 'normal',
    Brand: 'generic',
    Manufacturer: 'unknown',
  },
};

// Mock other commonly used native modules
export const AccessibilityInfo = {
  addEventListener: () => ({ remove: () => {} }),
  announceForAccessibility: () => {},
  fetch: () => Promise.resolve(false),
  isBoldTextEnabled: () => Promise.resolve(false),
  isGrayscaleEnabled: () => Promise.resolve(false),
  isInvertColorsEnabled: () => Promise.resolve(false),
  isReduceMotionEnabled: () => Promise.resolve(false),
  isReduceTransparencyEnabled: () => Promise.resolve(false),
  isScreenReaderEnabled: () => Promise.resolve(false),
  setAccessibilityFocus: () => {},
  sendAccessibilityEvent: () => {},
};

export const Alert = {
  alert: (title, message, buttons) => {
    if (typeof window !== 'undefined') {
      window.alert(`${title}\n${message || ''}`);
    }
  },
  prompt: (title, message, callbackOrButtons) => {
    if (typeof window !== 'undefined') {
      const result = window.prompt(`${title}\n${message || ''}`);
      if (typeof callbackOrButtons === 'function') {
        callbackOrButtons(result);
      }
    }
  },
};

export const Linking = {
  addEventListener: () => ({ remove: () => {} }),
  canOpenURL: () => Promise.resolve(true),
  getInitialURL: () => Promise.resolve(null),
  openURL: (url) => {
    if (typeof window !== 'undefined') {
      window.open(url, '_blank');
    }
    return Promise.resolve();
  },
  openSettings: () => Promise.resolve(),
  sendIntent: () => Promise.resolve(),
};

export const Share = {
  share: () => Promise.resolve({ action: 'sharedAction' }),
};

export const Vibration = {
  vibrate: () => {},
  cancel: () => {},
};

// Mock DeviceEventEmitter
export const DeviceEventEmitter = {
  addListener: () => ({ remove: () => {} }),
  emit: () => {},
  removeAllListeners: () => {},
  removeSubscription: () => {},
};

// Mock NativeEventEmitter
export const NativeEventEmitter = class {
  constructor() {}
  addListener() {
    return { remove: () => {} };
  }
  emit() {}
  removeAllListeners() {}
  removeSubscription() {}
};

// Mock PermissionsAndroid
export const PermissionsAndroid = {
  PERMISSIONS: {},
  RESULTS: {
    GRANTED: 'granted',
    DENIED: 'denied',
    NEVER_ASK_AGAIN: 'never_ask_again',
  },
  check: () => Promise.resolve('denied'),
  request: () => Promise.resolve('denied'),
  requestMultiple: () => Promise.resolve({}),
};

// Mock BackHandler
export const BackHandler = {
  addEventListener: () => ({ remove: () => {} }),
  exitApp: () => {},
  removeEventListener: () => {},
};

// Mock ToastAndroid
export const ToastAndroid = {
  show: () => {},
  showWithGravity: () => {},
  showWithGravityAndOffset: () => {},
  SHORT: 'short',
  LONG: 'long',
  TOP: 'top',
  BOTTOM: 'bottom',
  CENTER: 'center',
};

// Mock ActionSheetIOS
export const ActionSheetIOS = {
  showActionSheetWithOptions: () => {},
  showShareActionSheetWithOptions: () => {},
};

// Mock Settings
export const Settings = {
  get: () => null,
  set: () => {},
  watchKeys: () => ({ remove: () => {} }),
  clearWatch: () => {},
};

// Mock PushNotificationIOS
export const PushNotificationIOS = {
  addEventListener: () => ({ remove: () => {} }),
  requestPermissions: () => Promise.resolve({}),
  abandonPermissions: () => {},
  checkPermissions: () => {},
  getInitialNotification: () => Promise.resolve(null),
  getApplicationIconBadgeNumber: () => {},
  setApplicationIconBadgeNumber: () => {},
  cancelAllLocalNotifications: () => {},
  removeAllDeliveredNotifications: () => {},
  getDeliveredNotifications: () => {},
  removeDeliveredNotifications: () => {},
  setNotificationCategories: () => {},
  getNotificationCategories: () => {},
  addNotificationRequest: () => {},
  getPendingNotificationRequests: () => {},
  removePendingNotificationRequests: () => {},
  removeAllPendingNotificationRequests: () => {},
  getScheduledLocalNotifications: () => {},
  cancelLocalNotifications: () => {},
  presentLocalNotification: () => {},
  scheduleLocalNotification: () => {},
};