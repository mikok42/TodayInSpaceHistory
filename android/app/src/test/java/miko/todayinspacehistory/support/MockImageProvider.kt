package miko.todayinspacehistory.support

import kotlinx.coroutines.CompletableDeferred
import miko.todayinspacehistory.data.ImageProviderService
import miko.todayinspacehistory.data.TodaysImage

class MockImageProvider(
    private val result: Result<TodaysImage>,
) : ImageProviderService {
    override suspend fun loadTodaysImage(): TodaysImage {
        return result.getOrThrow()
    }
}

class GatedImageProvider(
    private val result: Result<TodaysImage>,
) : ImageProviderService {
    private val gate = CompletableDeferred<Unit>()

    override suspend fun loadTodaysImage(): TodaysImage {
        gate.await()
        return result.getOrThrow()
    }

    fun release() {
        gate.complete(Unit)
    }
}
