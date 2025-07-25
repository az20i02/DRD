import 'dart:io';
import 'package:flutter/foundation.dart';

class Config {
  // Production API URL - Update this with your actual production server URL
  static const String _productionUrl = 'https://your-production-domain.com';
  
  static String get baseUrl {
    // Check if we're in debug mode
    if (kDebugMode) {
      // Development URLs
      if (kIsWeb) {
        return 'http://localhost:8000';
      }

      // For Android device/emulator, use Mac's IP address to access host machine
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
        // return 'http://192.168.1.128:8000';
      }

      // For iOS simulator, localhost works as expected
      if (Platform.isIOS) {
        return 'http://127.0.0.1:8000';
      }

      // For other platforms (macOS, Windows, Linux), use localhost
      return 'http://localhost:8000';
    } else {
      // Production URL
      return _productionUrl;
    }
  }
  
  // Environment-specific configurations
  static bool get isProduction => !kDebugMode;
  static bool get isDevelopment => kDebugMode;
  
  // API timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Other configuration constants
  static const String appName = 'DRD - Road Damage Detection';
  static const String version = '1.0.0';
}
