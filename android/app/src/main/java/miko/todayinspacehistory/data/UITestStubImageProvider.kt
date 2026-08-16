package miko.todayinspacehistory.data

import miko.todayinspacehistory.data.model.Item
import miko.todayinspacehistory.data.model.SearchResult

object UITestLaunchArgument {
    const val STUB = "UITestStub"
}

/** Deterministic provider used when the app is launched with `UITestStub`. */
class UITestStubImageProvider : ImageProviderService {
    override suspend fun loadTodaysImage(): TodaysImage {
        val result = SearchResult(
            center = null,
            dateCreated = "1969-07-20T00:00:00Z",
            description = STUB_DESCRIPTION,
            keywords = null,
            mediaType = "image",
            nasaId = "stub",
            title = STUB_TITLE,
        )
        val item = Item(
            data = listOf(result),
            links = null,
            href = "https://example.com/asset.json",
        )
        return TodaysImage(item = item, imageUrls = listOf(STUB_IMAGE_URL))
    }

    companion object {
        const val STUB_TITLE = "Stub Title"
        const val STUB_DESCRIPTION = "Stub Description"
        const val STUB_IMAGE_URL = "https://example.com/images/large.jpg"
    }
}
