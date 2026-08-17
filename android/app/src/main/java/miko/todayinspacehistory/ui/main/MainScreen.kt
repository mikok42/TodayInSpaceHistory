package miko.todayinspacehistory.ui.main

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import miko.todayinspacehistory.ui.subviews.ErrorView
import miko.todayinspacehistory.ui.subviews.Photo
import miko.todayinspacehistory.util.AccessibilityIdentifiers
import miko.todayinspacehistory.util.StyleConstants

@Composable
fun MainScreen(
    viewModel: MainViewModel = viewModel(factory = MainViewModel.Factory),
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    val error = state.error

    if (error != null) {
        ErrorView(
            error = error,
            onDismiss = viewModel::dismissError,
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black),
        )
        return
    }

    LaunchedEffect(Unit) {
        if (state.imageUrl == null) {
            viewModel.fetchData()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .padding(StyleConstants.LABELS_MARGINS.dp),
    ) {
        Header(onRefresh = viewModel::fetchData)
        Spacer(modifier = Modifier.height(StyleConstants.LABELS_MARGINS.dp))
        Text(
            text = state.dayLabel,
            color = Color.White,
            fontSize = 30.sp,
            fontFamily = FontFamily.SansSerif,
            fontWeight = FontWeight.Light,
            modifier = Modifier.testTag(AccessibilityIdentifiers.DAY_LABEL),
        )
        Spacer(modifier = Modifier.height(StyleConstants.LABELS_MARGINS.dp))
        ImageSection(
            imageUrl = state.imageUrl,
            title = state.title,
            isLoading = state.isLoading,
        )
        Spacer(modifier = Modifier.height(StyleConstants.LABELS_MARGINS.dp))
        Text(
            text = state.description.orEmpty(),
            color = Color.White,
            fontSize = 20.sp,
            fontFamily = FontFamily.SansSerif,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .testTag(AccessibilityIdentifiers.DESCRIPTION),
        )
    }
}

@Composable
private fun Header(onRefresh: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = "Today In Space History",
            color = Color.White,
            fontSize = 25.sp,
            fontFamily = FontFamily.SansSerif,
            fontWeight = FontWeight.Light,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier
                .weight(1f)
                .testTag(AccessibilityIdentifiers.TITLE),
        )
        TextButton(
            onClick = onRefresh,
            modifier = Modifier.testTag(AccessibilityIdentifiers.REFRESH),
        ) {
            Text(
                text = "↺",
                color = Color.White,
                fontSize = 25.sp,
            )
        }
    }
}

@Composable
private fun ImageSection(
    imageUrl: String?,
    title: String?,
    isLoading: Boolean,
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(300.dp)
            .clip(RoundedCornerShape(16.dp)),
        contentAlignment = Alignment.Center,
    ) {
        Photo(
            url = imageUrl,
            isLoading = isLoading,
            contentDescription = title,
            modifier = Modifier.fillMaxSize(),
        )
        if (title != null) {
            Text(
                text = title,
                color = Color.Black,
                fontSize = 15.sp,
                fontFamily = FontFamily.SansSerif,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(end = 20.dp, bottom = 20.dp)
                    .fillMaxWidth()
                    .background(Color.White.copy(alpha = 0.5f))
                    .padding(12.dp)
                    .testTag(AccessibilityIdentifiers.IMAGE_TITLE),
            )
        }
    }
}
