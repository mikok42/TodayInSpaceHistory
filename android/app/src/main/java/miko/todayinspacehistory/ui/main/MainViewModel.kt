package miko.todayinspacehistory.ui.main

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import miko.todayinspacehistory.data.DescriptiveError
import miko.todayinspacehistory.data.ImageProviderService
import miko.todayinspacehistory.data.ImageProviderServiceImpl
import miko.todayinspacehistory.data.TodaysImage
import miko.todayinspacehistory.util.AnalyticsTimer
import miko.todayinspacehistory.util.decodedHTMLEntities
import miko.todayinspacehistory.util.todayDayLabel

data class MainUiState(
    val title: String? = null,
    val description: String? = null,
    val imageUrl: String? = null,
    val dayLabel: String = todayDayLabel(),
    val isLoading: Boolean = false,
)

class MainViewModel(
    private val imageProvider: ImageProviderService = ImageProviderServiceImpl(),
    private val timer: AnalyticsTimer = AnalyticsTimer(reportName = "downloading"),
) : ViewModel() {

    private val _uiState = MutableStateFlow(MainUiState())
    val uiState: StateFlow<MainUiState> = _uiState.asStateFlow()

    fun fetchData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            timer.startTimer()
            try {
                val payload = imageProvider.loadTodaysImage()
                apply(payload)
            } catch (error: Exception) {
                val message = (error as? DescriptiveError)?.description ?: error.toString()
                Log.e(TAG, message)
            } finally {
                timer.endTimer()
                timer.reportToAnalytics()
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }

    private fun apply(payload: TodaysImage) {
        val imageUrl = payload.imageUrls.firstOrNull {
            it.contains("large") || it.contains("medium") || it.contains("original")
        }
        val result = payload.item.data?.firstOrNull()
        _uiState.update {
            it.copy(
                imageUrl = imageUrl,
                title = result?.title?.decodedHTMLEntities,
                description = result?.description?.decodedHTMLEntities,
            )
        }
    }

    companion object {
        private const val TAG = "MainViewModel"
    }
}
