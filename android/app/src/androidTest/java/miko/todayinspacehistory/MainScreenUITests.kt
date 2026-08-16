package miko.todayinspacehistory

import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.AndroidComposeTestRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import coil3.ImageLoader
import coil3.SingletonImageLoader
import coil3.annotation.DelicateCoilApi
import coil3.asImage
import coil3.test.FakeImageLoaderEngine
import miko.todayinspacehistory.data.UITestLaunchArgument
import miko.todayinspacehistory.data.UITestStubImageProvider
import miko.todayinspacehistory.util.AccessibilityIdentifiers
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TestWatcher
import org.junit.runner.Description
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainScreenUITests {

    @get:Rule(order = 0)
    val coilRule = FakeCoilRule()

    @get:Rule(order = 1)
    val composeRule: AndroidComposeTestRule<ActivityScenarioRule<MainActivity>, MainActivity> =
        AndroidComposeTestRule(
            activityRule = ActivityScenarioRule(stubIntent()),
            activityProvider = { rule ->
                var activity: MainActivity? = null
                rule.scenario.onActivity { activity = it }
                requireNotNull(activity)
            },
        )

    @Test
    fun smokeShowsChrome() {
        composeRule.onNodeWithTag(AccessibilityIdentifiers.TITLE)
            .assertTextEquals("Today In Space History")
        composeRule.onNodeWithTag(AccessibilityIdentifiers.REFRESH).assertExists()
        composeRule.onNodeWithTag(AccessibilityIdentifiers.DAY_LABEL).assertExists()
    }

    @Test
    fun stubbedContentAppears() {
        composeRule.waitForTag(AccessibilityIdentifiers.IMAGE_TITLE)
        composeRule.onNodeWithTag(AccessibilityIdentifiers.IMAGE_TITLE)
            .assertTextEquals(UITestStubImageProvider.STUB_TITLE)
        composeRule.onNodeWithTag(AccessibilityIdentifiers.DESCRIPTION)
            .assertTextEquals(UITestStubImageProvider.STUB_DESCRIPTION)
    }

    @Test
    fun refreshKeepsStubbedContent() {
        composeRule.waitForTag(AccessibilityIdentifiers.IMAGE_TITLE)
        composeRule.onNodeWithTag(AccessibilityIdentifiers.REFRESH).performClick()
        composeRule.waitForTag(AccessibilityIdentifiers.IMAGE_TITLE)
        composeRule.onNodeWithTag(AccessibilityIdentifiers.IMAGE_TITLE)
            .assertTextEquals(UITestStubImageProvider.STUB_TITLE)
        composeRule.onNodeWithTag(AccessibilityIdentifiers.DESCRIPTION)
            .assertTextEquals(UITestStubImageProvider.STUB_DESCRIPTION)
    }

    private fun AndroidComposeTestRule<*, *>.waitForTag(tag: String) {
        waitUntil(timeoutMillis = 5_000) {
            onAllNodesWithTag(tag).fetchSemanticsNodes().isNotEmpty()
        }
    }

    private companion object {
        fun stubIntent(): Intent {
            return Intent(
                ApplicationProvider.getApplicationContext(),
                MainActivity::class.java,
            ).putExtra(UITestLaunchArgument.STUB, true)
        }
    }
}

@OptIn(DelicateCoilApi::class)
class FakeCoilRule : TestWatcher() {
    override fun starting(description: Description) {
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        val engine = FakeImageLoaderEngine.Builder()
            .default(ColorDrawable(Color.LTGRAY).asImage())
            .build()
        val loader = ImageLoader.Builder(context)
            .components { add(engine) }
            .build()
        SingletonImageLoader.setUnsafe(loader)
    }
}
