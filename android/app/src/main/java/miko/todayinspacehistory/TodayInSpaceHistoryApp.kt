package miko.todayinspacehistory

import android.app.Application
import com.google.firebase.FirebaseApp

class TodayInSpaceHistoryApp : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)
    }
}
