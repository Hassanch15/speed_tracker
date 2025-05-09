package com.example.speed_tracker

class KalmanLatLong(private val qMetersPerSecond: Float) {
    private var timestamp: Long = 0
    private var variance = -1.0
    private var lat = 0.0
    private var lng = 0.0

    fun process(
        lat_measurement: Double,
        lng_measurement: Double,
        accuracy: Float,
        timestamp: Long,
        speed: Double
    ) {
        if (accuracy < 0.0f) return

        if (variance < 0) {
            this.timestamp = timestamp
            lat = lat_measurement
            lng = lng_measurement
            variance = (accuracy * accuracy).toDouble()
        } else {
            val timeInc = (timestamp - this.timestamp) / 1000.0
            if (timeInc > 0) {
                variance += timeInc * qMetersPerSecond * qMetersPerSecond
                this.timestamp = timestamp
            }

            val k = variance / (variance + accuracy * accuracy)
            lat += k * (lat_measurement - lat)
            lng += k * (lng_measurement - lng)
            variance *= (1 - k)
        }
    }
}