package miko.todayinspacehistory.data

sealed interface DescriptiveError {
    val description: String
}

object Errors {
    sealed class NetworkClient : Exception(), DescriptiveError {
        data class InvalidURL(val endpointOrPath: String) : NetworkClient() {
            override val description: String
                get() = "[NetworkClient] Failed to build URL from: $endpointOrPath"
        }

        data class RequestFailed(val underlying: Throwable) : NetworkClient() {
            override val description: String
                get() = "[NetworkClient] Network request failed: ${underlying.message}"
        }

        data class DecodingFailed(val underlying: Throwable) : NetworkClient() {
            override val description: String
                get() = "[NetworkClient] Failed to decode response: ${underlying.message}"
        }
    }

    sealed class ImageProvider : Exception(), DescriptiveError {
        data object NoItems : ImageProvider() {
            override val description: String
                get() = "[ImageProvider] NASA returned no images for today's date."
        }

        data object MissingAssetURL : ImageProvider() {
            override val description: String
                get() = "[ImageProvider] Selected item is missing an asset list URL (href)."
        }
    }
}
