package miko.todayinspacehistory.services

import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.Url
import io.ktor.http.headersOf
import kotlinx.coroutines.test.runTest
import miko.todayinspacehistory.data.Errors
import miko.todayinspacehistory.data.network.NetworkClientImpl
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class NetworkClientTests {

    private val nasaSearchJson = """
        {"collection":{"items":[{"href":"https://images-assets.nasa.gov/image/MSFC-1601301/collection.json","data":[{"center":"MSFC","date_created":"2014-03-16T00:00:00Z","description":"A &amp; B","media_type":"image","nasa_id":"MSFC-1601301","title":"Apollo"}]}]}}
    """.trimIndent()

    @Test
    fun searchDecodesNASASnakeCaseFields() = runTest {
        val captured = mutableListOf<Url>()
        val client = NetworkClientImpl(stubClient(HttpStatusCode.OK, nasaSearchJson, captured))

        val response = client.search()
        val result = response.collection.items?.first()?.data?.first()

        assertEquals("2014-03-16T00:00:00Z", result?.dateCreated)
        assertEquals("image", result?.mediaType)
        assertEquals("MSFC-1601301", result?.nasaId)
        assertEquals("Apollo", result?.title)
    }

    @Test
    fun searchUsesNASASearchQuery() = runTest {
        val captured = mutableListOf<Url>()
        val client = NetworkClientImpl(stubClient(HttpStatusCode.OK, nasaSearchJson, captured))

        client.search()

        assertNASASearchURL(captured.single())
    }

    @Test
    fun searchThrowsOnNotFound() = runTest {
        val captured = mutableListOf<Url>()
        val client = NetworkClientImpl(stubClient(HttpStatusCode.NotFound, """{"error":"nope"}""", captured))

        assertUnacceptableStatusCode(404) { client.search() }
        assertNASASearchURL(captured.single())
    }

    @Test
    fun searchThrowsOnServerError() = runTest {
        val captured = mutableListOf<Url>()
        val client = NetworkClientImpl(stubClient(HttpStatusCode.InternalServerError, "", captured))

        assertUnacceptableStatusCode(500) { client.search() }
        assertNASASearchURL(captured.single())
    }

    @Test
    fun fetchImageUrlsThrowsOnNotFound() = runTest {
        val captured = mutableListOf<Url>()
        val client = NetworkClientImpl(stubClient(HttpStatusCode.NotFound, "", captured))

        assertUnacceptableStatusCode(404) {
            client.fetchImageUrls("https://example.com/a.json")
        }
        assertEquals("https://example.com/a.json", captured.single().toString())
    }

    @Test
    fun searchThrowsDecodingFailedOnMalformedBody() = runTest {
        val captured = mutableListOf<Url>()
        val client = NetworkClientImpl(stubClient(HttpStatusCode.OK, "not json", captured))

        try {
            client.search()
            fail("Expected DecodingFailed")
        } catch (error: Errors.NetworkClient.DecodingFailed) {
            assertEquals("[NetworkClient] Failed to decode response: ${error.underlying.message}", error.description)
        }
        assertNASASearchURL(captured.single())
    }

    private fun stubClient(
        status: HttpStatusCode,
        body: String,
        captured: MutableList<Url>,
    ): HttpClient {
        val engine = MockEngine { request ->
            captured += request.url
            respond(
                content = body,
                status = status,
                headers = headersOf(HttpHeaders.ContentType, "application/json"),
            )
        }
        return HttpClient(engine) {
            expectSuccess = true
        }
    }

    private fun assertNASASearchURL(url: Url) {
        assertEquals("images-api.nasa.gov", url.host)
        assertEquals("/search", url.encodedPath)
        assertEquals("image", url.parameters["media_type"])
        val description = url.parameters["description"]
        assertNotNull(description)
        val englishMonths = listOf(
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December",
        )
        assertTrue(
            "Expected English month in description, got $description",
            englishMonths.any { description!!.contains(it) },
        )
        val day = description!!.split(" ").first()
        assertNotNull("Expected numeric day in description, got $description", day.toIntOrNull())
    }

    private suspend fun assertUnacceptableStatusCode(expected: Int, block: suspend () -> Unit) {
        try {
            block()
            fail("Expected UnacceptableStatusCode($expected)")
        } catch (error: Errors.NetworkClient.UnacceptableStatusCode) {
            assertEquals(expected, error.statusCode)
        }
    }
}
