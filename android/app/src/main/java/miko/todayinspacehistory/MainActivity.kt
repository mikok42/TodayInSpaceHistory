package miko.todayinspacehistory

import android.os.Bundle
import androidx.activity.ComponentActivity
import miko.todayinspacehistory.coordinator.MainCoordinator

class MainActivity : ComponentActivity() {
    private var coordinator: MainCoordinator? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val coordinator = MainCoordinator(this)
        this.coordinator = coordinator
        coordinator.start()
    }
}
