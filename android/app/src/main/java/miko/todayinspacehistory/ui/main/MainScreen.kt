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
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import coil3.compose.AsyncImage
import miko.todayinspacehistory.util.Constants

@Composable
fun MainScreen(
    viewModel: MainViewModel = viewModel(),
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        viewModel.fetchData()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .padding(Constants.LABELS_MARGINS.dp),
    ) {
        Header(onRefresh = viewModel::fetchData)
        Spacer(modifier = Modifier.height(Constants.LABELS_MARGINS.dp))
        Text(
            text = state.dayLabel,
            color = Color.White,
            fontSize = 30.sp,
            fontFamily = FontFamily.SansSerif,
            fontWeight = FontWeight.Light,
        )
        Spacer(modifier = Modifier.height(Constants.LABELS_MARGINS.dp))
        ImageSection(
            imageUrl = state.imageUrl,
            title = state.title,
            isLoading = state.isLoading,
        )
        Spacer(modifier = Modifier.height(Constants.LABELS_MARGINS.dp))
        Text(
            text = state.description.orEmpty(),
            color = Color.White,
            fontSize = 20.sp,
            fontFamily = FontFamily.SansSerif,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState()),
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
            modifier = Modifier.weight(1f),
        )
        TextButton(onClick = onRefresh) {
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
    val shape = RoundedCornerShape(50.dp)
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(300.dp)
            .clip(shape),
        contentAlignment = Alignment.Center,
    ) {
        when {
            imageUrl != null -> {
                AsyncImage(
                    model = imageUrl,
                    contentDescription = title,
                    contentScale = ContentScale.Crop,
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
                            .padding(start = 0.dp, end = 20.dp, bottom = 20.dp)
                            .fillMaxWidth()
                            .background(Color.White.copy(alpha = 0.5f))
                            .padding(8.dp),
                    )
                }
            }
            isLoading -> CircularProgressIndicator(color = Color.White)
        }
    }
}
