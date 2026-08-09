package miko.todayinspacehistory.data.network

import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.cio.CIO
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.http.HttpHeaders
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNamingStrategy
import miko.todayinspacehistory.data.Errors
import miko.todayinspacehistory.data.model.ApiResponse

interface NetworkClient {
    suspend fun search(): ApiResponse
    suspend fun fetchImageUrls(url: String): List<String>
}

class NetworkClientImpl(
    private val httpClient: HttpClient = defaultClient,
) : NetworkClient {

    private val searchJson = Json {
        ignoreUnknownKeys = true
        isLenient = true
        namingStrategy = JsonNamingStrategy.SnakeCase
    }

    private val plainJson = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    override suspend fun search(): ApiResponse {
        val url = Endpoints.Search.url
            ?: throw Errors.NetworkClient.InvalidURL(Endpoints.Search.path)
        val bodyText = getBody(url)
        return try {
            searchJson.decodeFromString(ApiResponse.serializer(), bodyText)
        } catch (error: Throwable) {
            throw Errors.NetworkClient.DecodingFailed(error)
        }
    }

    override suspend fun fetchImageUrls(url: String): List<String> {
        if (url.isBlank()) {
            throw Errors.NetworkClient.InvalidURL(url)
        }
        val bodyText = getBody(url)
        return try {
            plainJson.decodeFromString<List<String>>(bodyText)
        } catch (error: Throwable) {
            throw Errors.NetworkClient.DecodingFailed(error)
        }
    }

    private suspend fun getBody(url: String): String {
        return try {
            httpClient.get(url) {
                header(HttpHeaders.Accept, "application/json")
            }.body()
        } catch (error: Throwable) {
            throw Errors.NetworkClient.RequestFailed(error)
        }
    }

    companion object {
        val defaultClient: HttpClient by lazy {
            HttpClient(CIO) {
                expectSuccess = true
            }
        }
    }
}
