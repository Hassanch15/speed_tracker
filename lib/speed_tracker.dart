import 'package:flutter/services.dart';

class SpeedTracker {
  static const _channel = MethodChannel('speed_tracker');

  static Future<void> start() async {
    await _channel.invokeMethod('startTracking');
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stopTracking');
  }

  static void listen(void Function(double speed) onSpeedChanged) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSpeedChanged') {
        final speed = (call.arguments as num).toDouble();
        onSpeedChanged(speed);
      }
    });
  }
}
