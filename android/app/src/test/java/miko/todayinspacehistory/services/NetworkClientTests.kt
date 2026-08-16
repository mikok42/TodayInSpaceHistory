package miko.todayinspacehistory.services

import io.ktor.client.HttpClient
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.headersOf
import kotlinx.coroutines.test.runTest
import miko.todayinspacehistory.data.Errors
import miko.todayinspacehistory.data.network.NetworkClientImpl
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.Test

class NetworkClientTests {

    @Test
    fun searchDecodesSuccessfulResponse() = runTest {
        val json = """
            {"collection":{"items":[{"href":"https://example.com/a.json","data":[{"title":"Apollo"}]}]}}
        """.trimIndent()
        val client = NetworkClientImpl(stubClient(HttpStatusCode.OK, json))

        val response = client.search()

        assertEquals(1, response.collection.items?.size)
        assertEquals("Apollo", response.collection.items?.first()?.data?.first()?.title)
    }

    @Test
    fun searchThrowsOnNotFound() = runTest {
        val client = NetworkClientImpl(stubClient(HttpStatusCode.NotFound, """{"error":"nope"}"""))

        assertUnacceptableStatusCode(404) { client.search() }
    }

    @Test
    fun searchThrowsOnServerError() = runTest {
        val client = NetworkClientImpl(stubClient(HttpStatusCode.InternalServerError, ""))

        assertUnacceptableStatusCode(500) { client.search() }
    }

    @Test
    fun fetchImageUrlsThrowsOnNotFound() = runTest {
        val client = NetworkClientImpl(stubClient(HttpStatusCode.NotFound, ""))

        assertUnacceptableStatusCode(404) {
            client.fetchImageUrls("https://example.com/a.json")
        }
    }

    @Test
    fun searchThrowsDecodingFailedOnMalformedBody() = runTest {
        val client = NetworkClientImpl(stubClient(HttpStatusCode.OK, "not json"))

        try {
            client.search()
            fail("Expected DecodingFailed")
        } catch (error: Errors.NetworkClient.DecodingFailed) {
            assertEquals("[NetworkClient] Failed to decode response: ${error.underlying.message}", error.description)
        }
    }

    private fun stubClient(status: HttpStatusCode, body: String): HttpClient {
        val engine = MockEngine {
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

    private suspend fun assertUnacceptableStatusCode(expected: Int, block: suspend () -> Unit) {
        try {
            block()
            fail("Expected UnacceptableStatusCode($expected)")
        } catch (error: Errors.NetworkClient.UnacceptableStatusCode) {
            assertEquals(expected, error.statusCode)
        }
    }
}
