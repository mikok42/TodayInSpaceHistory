package miko.todayinspacehistory.coordinator

import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import miko.todayinspacehistory.ui.main.MainScreen

class MainCoordinator(
    private val activity: ComponentActivity,
) : Coordinator {
    override val childCoordinators: MutableList<Coordinator> = mutableListOf()

    override fun start() {
        activity.enableEdgeToEdge()
        activity.setContent {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color.Black,
            ) {
                MainScreen()
            }
        }
    }
}
