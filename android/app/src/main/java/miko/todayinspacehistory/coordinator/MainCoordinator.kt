package miko.todayinspacehistory.coordinator

import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import miko.todayinspacehistory.data.UITestLaunchArgument
import miko.todayinspacehistory.data.UITestStubImageProvider
import miko.todayinspacehistory.ui.main.MainScreen
import miko.todayinspacehistory.ui.main.MainViewModel
import miko.todayinspacehistory.util.AnalyticsTimer

class MainCoordinator(
    private val activity: ComponentActivity,
    private val useStub: Boolean = activity.intent.getBooleanExtra(UITestLaunchArgument.STUB, false),
) : Coordinator {
    override val childCoordinators: MutableList<Coordinator> = mutableListOf()

    override fun start() {
        activity.enableEdgeToEdge()
        val stubViewModel = if (useStub) {
            MainViewModel(
                imageProvider = UITestStubImageProvider(),
                timer = AnalyticsTimer(reportName = "downloading") { _, _ -> },
            )
        } else {
            null
        }
        activity.setContent {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color.Black,
            ) {
                if (stubViewModel != null) {
                    MainScreen(viewModel = stubViewModel)
                } else {
                    MainScreen()
                }
            }
        }
    }
}
