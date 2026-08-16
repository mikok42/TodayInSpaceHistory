package miko.todayinspacehistory.data

import miko.todayinspacehistory.data.model.Item
import miko.todayinspacehistory.data.network.NetworkClient
import miko.todayinspacehistory.data.network.NetworkClientImpl
import miko.todayinspacehistory.util.rewritingHTTPSchemeToHTTPS

data class TodaysImage(
    val item: Item,
    val imageUrls: List<String>,
)

interface ImageProviderService {
    suspend fun loadTodaysImage(): TodaysImage
}

class ImageProviderServiceImpl(
    private val client: NetworkClient = NetworkClientImpl(),
) : ImageProviderService {

    override suspend fun loadTodaysImage(): TodaysImage {
        val response = client.search()
        val items = response.collection.items.orEmpty()
        val todaysItems = items.filter { it.matchesTodaysAnniversary }
        val pool = if (todaysItems.isEmpty()) items else todaysItems
        val item = pool.randomOrNull()
            ?: throw Errors.ImageProvider.NoItems
        val href = item.href
            ?: throw Errors.ImageProvider.MissingAssetURL
        val rawUrls = client.fetchImageUrls(href)
        val imageUrls = rawUrls.map { it.rewritingHTTPSchemeToHTTPS }
        return TodaysImage(item = item, imageUrls = imageUrls)
    }
}
