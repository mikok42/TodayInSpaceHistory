package miko.todayinspacehistory.viewmodels

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import miko.todayinspacehistory.data.Errors
import miko.todayinspacehistory.data.TodaysImage
import miko.todayinspacehistory.data.UITestStubImageProvider
import miko.todayinspacehistory.support.GatedImageProvider
import miko.todayinspacehistory.support.MockImageProvider
import miko.todayinspacehistory.support.TestFixtures
import miko.todayinspacehistory.ui.main.MainViewModel
import miko.todayinspacehistory.util.AnalyticsTimer
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class MainViewModelTests {
    private val dispatcher = UnconfinedTestDispatcher()

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun fetchDataSuccessUsesStubContent() {
        val reports = mutableListOf<Pair<String, Long>>()
        val viewModel = MainViewModel(
            imageProvider = UITestStubImageProvider(),
            timer = AnalyticsTimer(reportName = "downloading") { name, durationMs ->
                reports += name to durationMs
            },
        )

        viewModel.fetchData()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertEquals(UITestStubImageProvider.STUB_IMAGE_URL, state.imageUrl)
        assertEquals(UITestStubImageProvider.STUB_TITLE, state.title)
        assertEquals(UITestStubImageProvider.STUB_DESCRIPTION, state.description)
        assertEquals(listOf("downloading"), reports.map { it.first })
        assertTrue(reports.single().second >= 0)
    }

    @Test
    fun fetchDataSuccessDecodesAndPicksPreferredImage() {
        val item = TestFixtures.item(
            title = "Apollo &amp; Friends",
            description = "Hello &#0146; world",
            dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED,
        )
        val provider = MockImageProvider(
            result = Result.success(
                TodaysImage(
                    item = item,
                    imageUrls = listOf(
                        "https://cdn.example.com/thumb.jpg",
                        "https://cdn.example.com/large.jpg",
                        "https://cdn.example.com/original.jpg",
                    ),
                ),
            ),
        )
        val reports = mutableListOf<Pair<String, Long>>()
        val viewModel = MainViewModel(
            imageProvider = provider,
            timer = AnalyticsTimer(reportName = "downloading") { name, durationMs ->
                reports += name to durationMs
            },
        )

        viewModel.fetchData()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertEquals("https://cdn.example.com/large.jpg", state.imageUrl)
        assertEquals("Apollo & Friends", state.title)
        assertNotNull(state.description)
        assertFalse(state.description?.contains("&#0146;") == true)
        assertEquals(listOf("downloading"), reports.map { it.first })
        assertTrue(reports.single().second >= 0)
    }

    @Test
    fun fetchDataFailureClearsLoadingWithoutCrashing() {
        val provider = MockImageProvider(result = Result.failure(Errors.ImageProvider.NoItems))
        val reports = mutableListOf<Pair<String, Long>>()
        val viewModel = MainViewModel(
            imageProvider = provider,
            timer = AnalyticsTimer(reportName = "downloading") { name, durationMs ->
                reports += name to durationMs
            },
        )

        viewModel.fetchData()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertNull(state.imageUrl)
        assertNull(state.title)
        assertNotNull(state.error)
        assertEquals("downloading", reports.single().first)
    }

    @Test
    fun fetchDataSetsLoadingWhileInFlight() {
        val item = TestFixtures.item(dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED)
        val provider = GatedImageProvider(
            result = Result.success(
                TodaysImage(item = item, imageUrls = listOf("https://cdn.example.com/large.jpg")),
            ),
        )
        val viewModel = MainViewModel(
            imageProvider = provider,
            timer = AnalyticsTimer(reportName = "downloading") { _, _ -> },
        )

        viewModel.fetchData()

        assertTrue(viewModel.uiState.value.isLoading)
        provider.release()
        assertFalse(viewModel.uiState.value.isLoading)
    }

    @Test
    fun fetchDataLeavesImageUrlNilWhenNoPreferredSize() {
        val item = TestFixtures.item(
            title = "Only thumbs",
            dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED,
        )
        val provider = MockImageProvider(
            result = Result.success(
                TodaysImage(
                    item = item,
                    imageUrls = listOf(
                        "https://cdn.example.com/thumb.jpg",
                        "https://cdn.example.com/small.jpg",
                    ),
                ),
            ),
        )
        val viewModel = MainViewModel(
            imageProvider = provider,
            timer = AnalyticsTimer(reportName = "downloading") { _, _ -> },
        )

        viewModel.fetchData()

        val state = viewModel.uiState.value
        assertNull(state.imageUrl)
        assertEquals("Only thumbs", state.title)
        assertFalse(state.isLoading)
    }
}
