package miko.todayinspacehistory.support

import miko.todayinspacehistory.data.Errors
import miko.todayinspacehistory.data.model.ApiResponse
import miko.todayinspacehistory.data.network.NetworkClient

class MockNetworkClient : NetworkClient {
    var searchResult: Result<ApiResponse> = Result.failure(Errors.ImageProvider.NoItems)
    var fetchImagesResult: Result<List<String>> = Result.success(emptyList())
    private val _fetchImagesUrls = mutableListOf<String>()
    val fetchImagesUrls: List<String>
        get() = _fetchImagesUrls.toList()

    override suspend fun search(): ApiResponse {
        return searchResult.getOrThrow()
    }

    override suspend fun fetchImageUrls(url: String): List<String> {
        _fetchImagesUrls += url
        return fetchImagesResult.getOrThrow()
    }
}
