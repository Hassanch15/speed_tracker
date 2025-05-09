import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'speed_tracker_method_channel.dart';

abstract class SpeedTrackerPlatform extends PlatformInterface {
  /// Constructs a SpeedTrackerPlatform.
  SpeedTrackerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SpeedTrackerPlatform _instance = MethodChannelSpeedTracker();

  /// The default instance of [SpeedTrackerPlatform] to use.
  ///
  /// Defaults to [MethodChannelSpeedTracker].
  static SpeedTrackerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SpeedTrackerPlatform] when
  /// they register themselves.
  static set instance(SpeedTrackerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
