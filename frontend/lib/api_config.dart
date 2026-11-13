import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Web and Windows desktop
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return 'http://localhost:8080';
    }
    // Android emulator
    return 'http://10.0.2.2:8080';
  }
}
