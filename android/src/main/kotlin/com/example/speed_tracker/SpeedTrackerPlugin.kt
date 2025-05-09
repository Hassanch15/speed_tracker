package com.example.speed_tracker

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.os.Looper
import com.google.android.gms.location.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import kotlin.math.sqrt

class SpeedTrackerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var fusedLocationClient: FusedLocationProviderClient? = null
    private lateinit var locationRequest: LocationRequest
    private var lastLocation: Location? = null

    private var sensorManager: SensorManager? = null
    private var accelerometerListener: SensorEventListener? = null
    private var isDeviceMoving = false
    private var currentSpeed = 0.0

    private val kalmanFilter = KalmanLatLong(3.0f)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "speed_tracker")
        channel.setMethodCallHandler(this)

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startTracking" -> {
                startTracking()
                result.success(null)
            }
            "stopTracking" -> {
                stopTracking()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    @SuppressLint("MissingPermission")
    private fun startTracking() {
        startAccelerometer()

        locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000L)
            .setMinUpdateIntervalMillis(500)
            .setMaxUpdateDelayMillis(1000)
            .build()

        fusedLocationClient?.requestLocationUpdates(
            locationRequest,
            locationCallback,
            Looper.getMainLooper()
        )
    }

    private fun stopTracking() {
        fusedLocationClient?.removeLocationUpdates(locationCallback)
        stopAccelerometer()
    }

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(locationResult: LocationResult) {
            val location = locationResult.lastLocation ?: return

            // Filter location with Kalman
            kalmanFilter.process(
                location.latitude,
                location.longitude,
                location.accuracy,
                location.time,
                location.speed.toDouble()
            )

            if (isDeviceMoving) {
                currentSpeed = location.speed.toDouble() * 3.6 // m/s to km/h
                if (currentSpeed < 0.5) currentSpeed = 0.0
            } else {
                currentSpeed = 0.0
            }

            channel.invokeMethod("onSpeedChanged", currentSpeed)
        }
    }

    private fun startAccelerometer() {
        val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        accelerometerListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                if (event == null) return

                val ax = event.values[0]
                val ay = event.values[1]
                val az = event.values[2]

                val magnitude = sqrt(ax * ax + ay * ay + az * az)
                isDeviceMoving = magnitude > 1.05 // adjust threshold as needed
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(
            accelerometerListener,
            accelerometer,
            SensorManager.SENSOR_DELAY_UI
        )
    }

    private fun stopAccelerometer() {
        sensorManager?.unregisterListener(accelerometerListener)
        accelerometerListener = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopTracking()
        channel.setMethodCallHandler(null)
    }
}