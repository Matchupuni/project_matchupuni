import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Toggle this boolean to switch between the 172 IP and localhost
  static const bool useLocalhost = false;

  static const String _defaultIp = 'http://172.20.10.3:3000';

  static String get baseUrl {
    if (!useLocalhost) {
      return _defaultIp;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {
      // Platform check will throw on Web, but kIsWeb already handled it.
    }
    return 'http://127.0.0.1:3000';
  }
}
