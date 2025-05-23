import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'speed_tracker_platform_interface.dart';

/// An implementation of [SpeedTrackerPlatform] that uses method channels.
class MethodChannelSpeedTracker extends SpeedTrackerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('speed_tracker');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
