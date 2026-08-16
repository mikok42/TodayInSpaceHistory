package miko.todayinspacehistory.support

import miko.todayinspacehistory.data.model.ApiResponse
import miko.todayinspacehistory.data.model.Collection
import miko.todayinspacehistory.data.model.Item
import miko.todayinspacehistory.data.model.SearchResult
import java.util.Calendar
import java.util.GregorianCalendar

object TestFixtures {
    const val ANNIVERSARY_DATE_CREATED = "1969-07-20T20:17:40Z"
    const val OTHER_DATE_CREATED = "1971-08-16T00:00:00Z"

    fun july20_2026(): Calendar {
        return GregorianCalendar().apply {
            clear()
            set(2026, Calendar.JULY, 20, 12, 0, 0)
        }
    }

    fun august9_2026(): Calendar {
        return GregorianCalendar().apply {
            clear()
            set(2026, Calendar.AUGUST, 9, 12, 0, 0)
        }
    }

    fun item(
        title: String? = "Title",
        description: String? = "Description",
        dateCreated: String?,
        href: String? = "https://example.com/asset.json",
    ): Item {
        val result = SearchResult(
            center = null,
            dateCreated = dateCreated,
            description = description,
            keywords = null,
            mediaType = "image",
            nasaId = "id",
            title = title,
        )
        return Item(data = listOf(result), links = null, href = href)
    }

    fun apiResponse(items: List<Item>): ApiResponse {
        return ApiResponse(
            collection = Collection(
                links = null,
                href = null,
                items = items,
            ),
        )
    }
}
