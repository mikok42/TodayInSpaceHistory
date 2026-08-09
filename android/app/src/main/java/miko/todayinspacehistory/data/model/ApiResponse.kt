package miko.todayinspacehistory.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.util.Calendar

@Serializable
data class ApiResponse(
    val collection: Collection,
)

@Serializable
data class Collection(
    val links: List<Links>? = null,
    val href: String? = null,
    val items: List<Item>? = null,
)

@Serializable
data class Links(
    val prompt: String? = null,
    val rel: String? = null,
    val href: String? = null,
)

@Serializable
data class Item(
    val data: List<SearchResult>? = null,
    val links: List<ItemLinks>? = null,
    val href: String? = null,
) {
    /** True when `date_created` falls on today's month and day (any year). */
    val matchesTodaysAnniversary: Boolean
        get() {
            val raw = data?.firstOrNull()?.dateCreated ?: return false
            if (raw.length < 10) return false
            val parts = raw.take(10).split("-")
            if (parts.size != 3) return false
            val month = parts[1].toIntOrNull() ?: return false
            val day = parts[2].toIntOrNull() ?: return false
            val calendar = Calendar.getInstance()
            return month == calendar.get(Calendar.MONTH) + 1 &&
                day == calendar.get(Calendar.DAY_OF_MONTH)
        }
}

@Serializable
data class ItemLinks(
    val rel: String? = null,
    val href: String? = null,
    val render: String? = null,
)

@Serializable
data class SearchResult(
    val center: String? = null,
    @SerialName("date_created") val dateCreated: String? = null,
    val description: String? = null,
    val keywords: List<String>? = null,
    @SerialName("media_type") val mediaType: String? = null,
    @SerialName("nasa_id") val nasaId: String? = null,
    val title: String? = null,
)
