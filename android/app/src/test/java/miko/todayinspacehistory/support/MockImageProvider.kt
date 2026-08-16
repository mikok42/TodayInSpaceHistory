package miko.todayinspacehistory.support

import miko.todayinspacehistory.data.ImageProviderService
import miko.todayinspacehistory.data.TodaysImage

class MockImageProvider(
    private val result: Result<TodaysImage>,
) : ImageProviderService {
    override suspend fun loadTodaysImage(): TodaysImage {
        return result.getOrThrow()
    }
}
