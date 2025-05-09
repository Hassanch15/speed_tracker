import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:speed_tracker/speed_tracker_method_channel.dart';
import 'package:speed_tracker/speed_tracker_platform_interface.dart';

class MockSpeedTrackerPlatform with MockPlatformInterfaceMixin implements SpeedTrackerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SpeedTrackerPlatform initialPlatform = SpeedTrackerPlatform.instance;

  test('$MethodChannelSpeedTracker is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSpeedTracker>());
  });

  test('getPlatformVersion', () async {
    MockSpeedTrackerPlatform fakePlatform = MockSpeedTrackerPlatform();
    SpeedTrackerPlatform.instance = fakePlatform;

    expect("1.1", '42');
  });
}
