package miko.todayinspacehistory.ui.subviews

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import miko.todayinspacehistory.util.AccessibilityIdentifiers

private val PlaceholderColor = Color(0xFF2C2C2C)

/**
 * Image slot carrying no styling of its own: the caller owns size, shape and clipping.
 * Coil resolves both remote URLs and local files, so a single branch covers each.
 */
@Composable
fun Photo(
    url: String?,
    modifier: Modifier = Modifier,
    isLoading: Boolean = false,
    contentDescription: String? = null,
) {
    Box(modifier = modifier, contentAlignment = Alignment.Center) {
        when {
            isLoading && url == null -> CircularProgressIndicator(
                color = Color.White,
                modifier = Modifier.testTag(AccessibilityIdentifiers.LOADING),
            )

            url != null -> AsyncImage(
                model = url,
                contentDescription = contentDescription,
                contentScale = ContentScale.Crop,
                error = ColorPainter(PlaceholderColor),
                modifier = Modifier.fillMaxSize(),
            )

            else -> Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(PlaceholderColor),
            )
        }
    }
}

@Preview
@Composable
private fun PhotoLoadingPreview() {
    Photo(
        url = null,
        isLoading = true,
        modifier = Modifier
            .fillMaxSize()
            .height(200.dp),
    )
}

@Preview
@Composable
private fun PhotoMissingPreview() {
    Photo(
        url = null,
        modifier = Modifier
            .fillMaxSize()
            .height(200.dp),
    )
}
