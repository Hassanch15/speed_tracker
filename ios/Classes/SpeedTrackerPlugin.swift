import Flutter
import UIKit
import CoreLocation

public class SpeedTrackerPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private var channel: FlutterMethodChannel?
    private var locationManager: CLLocationManager?
    private var lastReportedSpeed: Double = 0.0
    private var isDeviceMoving: Bool = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SpeedTrackerPlugin()
        instance.channel = FlutterMethodChannel(name: "speed_tracker", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: instance.channel!)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startTracking":
            startTracking()
            result(nil)
        case "stopTracking":
            stopTracking()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startTracking() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager?.activityType = .automotiveNavigation
            locationManager?.allowsBackgroundLocationUpdates = true
        }

        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }

    private func stopTracking() {
        locationManager?.stopUpdatingLocation()
        lastReportedSpeed = 0.0
        isDeviceMoving = false
        channel?.invokeMethod("onSpeedChanged", arguments: 0.0)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }

        let rawSpeed = max(0.0, location.speed) // m/s
        let speedKmh = rawSpeed * 3.6           // convert to km/h

        // Motion detection via speed magnitude
        isDeviceMoving = rawSpeed > 0.2

        let reportedSpeed = isDeviceMoving && speedKmh > 0.5 ? speedKmh : 0.0

        // Only report if there's a change
        if abs(reportedSpeed - lastReportedSpeed) > 0.3 {
            lastReportedSpeed = reportedSpeed
            channel?.invokeMethod("onSpeedChanged", arguments: reportedSpeed)
        }
    }
}