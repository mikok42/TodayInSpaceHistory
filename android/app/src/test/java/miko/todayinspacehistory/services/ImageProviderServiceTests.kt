package miko.todayinspacehistory.services

import kotlinx.coroutines.test.runTest
import miko.todayinspacehistory.data.Errors
import miko.todayinspacehistory.data.ImageProviderServiceImpl
import miko.todayinspacehistory.support.MockNetworkClient
import miko.todayinspacehistory.support.TestFixtures
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class ImageProviderServiceTests {
    @Test
    fun prefersAnniversaryItems() = runTest {
        val client = MockNetworkClient()
        val anniversary = TestFixtures.item(
            title = "Anniversary",
            dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED,
            href = "https://example.com/a.json",
        )
        val other = TestFixtures.item(
            title = "Other",
            dateCreated = TestFixtures.OTHER_DATE_CREATED,
            href = "https://example.com/o.json",
        )
        client.searchResult = Result.success(TestFixtures.apiResponse(listOf(other, anniversary)))
        client.fetchImagesResult = Result.success(listOf("https://images.example.com/large.jpg"))

        val service = ImageProviderServiceImpl(client = client, now = { TestFixtures.july20_2026() })
        val result = service.loadTodaysImage()

        assertEquals("Anniversary", result.item.data?.first()?.title)
        assertEquals(listOf("https://example.com/a.json"), client.fetchImagesUrls)
        assertEquals(listOf("https://images.example.com/large.jpg"), result.imageUrls)
    }

    @Test
    fun fallsBackWhenNoAnniversaryMatches() = runTest {
        val client = MockNetworkClient()
        val other = TestFixtures.item(
            title = "Fallback",
            dateCreated = TestFixtures.OTHER_DATE_CREATED,
            href = "https://example.com/f.json",
        )
        client.searchResult = Result.success(TestFixtures.apiResponse(listOf(other)))
        client.fetchImagesResult = Result.success(listOf("http://images.example.com/medium.jpg"))

        val service = ImageProviderServiceImpl(client = client, now = { TestFixtures.july20_2026() })
        val result = service.loadTodaysImage()

        assertEquals("Fallback", result.item.data?.first()?.title)
        assertEquals(listOf("https://images.example.com/medium.jpg"), result.imageUrls)
    }

    @Test
    fun throwsNoItems() = runTest {
        val client = MockNetworkClient()
        client.searchResult = Result.success(TestFixtures.apiResponse(emptyList()))
        val service = ImageProviderServiceImpl(client = client, now = { TestFixtures.july20_2026() })

        try {
            service.loadTodaysImage()
            fail("Expected noItems")
        } catch (error: Errors.ImageProvider.NoItems) {
            assertTrue(true)
        }
    }

    @Test
    fun throwsMissingAssetURL() = runTest {
        val client = MockNetworkClient()
        val item = TestFixtures.item(
            dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED,
            href = null,
        )
        client.searchResult = Result.success(TestFixtures.apiResponse(listOf(item)))
        val service = ImageProviderServiceImpl(client = client, now = { TestFixtures.july20_2026() })

        try {
            service.loadTodaysImage()
            fail("Expected missingAssetURL")
        } catch (error: Errors.ImageProvider.MissingAssetURL) {
            assertTrue(true)
        }
    }

    @Test
    fun rewritesOnlyHTTPScheme() = runTest {
        val client = MockNetworkClient()
        val item = TestFixtures.item(
            dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED,
            href = "https://example.com/a.json",
        )
        client.searchResult = Result.success(TestFixtures.apiResponse(listOf(item)))
        client.fetchImagesResult = Result.success(
            listOf(
                "http://cdn.example.com/large.jpg",
                "https://cdn.example.com/original.jpg",
            ),
        )

        val service = ImageProviderServiceImpl(client = client, now = { TestFixtures.july20_2026() })
        val result = service.loadTodaysImage()

        assertEquals(
            listOf(
                "https://cdn.example.com/large.jpg",
                "https://cdn.example.com/original.jpg",
            ),
            result.imageUrls,
        )
    }
}
