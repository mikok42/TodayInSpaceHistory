package miko.todayinspacehistory.ui.subviews

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import miko.todayinspacehistory.data.DescriptiveError

@Composable
fun ErrorView(
    error: DescriptiveError,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier.fillMaxSize().padding(16.dp)) {
        Text(text = error.title, color = Color.White)
        Text(text = error.description, color = Color.White)
        TextButton(onClick = onDismiss) {
            Text(text = "Dismiss", color = Color.White)
        }
    }
}
