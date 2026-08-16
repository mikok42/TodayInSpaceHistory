package miko.todayinspacehistory.util

import android.os.SystemClock
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.analytics.ktx.logEvent
import com.google.firebase.ktx.Firebase

class AnalyticsTimer(
    private val reportName: String,
    private val onReport: (name: String, durationMs: Long) -> Unit = { name, durationMs ->
        Firebase.analytics.logEvent(name) {
            param("duration_ms", durationMs)
        }
    },
) {
    private var startTimeMs: Long = 0
    private var endTimeMs: Long = 0
    private val durationMs: Long
        get() = endTimeMs - startTimeMs

    fun startTimer() {
        startTimeMs = SystemClock.elapsedRealtime()
    }

    fun endTimer() {
        endTimeMs = SystemClock.elapsedRealtime()
    }

    fun reportToAnalytics() {
        onReport(reportName, durationMs)
    }
}
