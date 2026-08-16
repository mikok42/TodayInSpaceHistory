package miko.todayinspacehistory.support

import miko.todayinspacehistory.data.model.ApiResponse
import miko.todayinspacehistory.data.model.Collection
import miko.todayinspacehistory.data.model.Item
import miko.todayinspacehistory.data.model.SearchResult
import java.util.Calendar
import java.util.GregorianCalendar

object TestFixtures {
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

    /** `date_created` for today's month/day in an arbitrary past year. */
    val todaysAnniversaryDateCreated: String
        get() {
            val calendar = GregorianCalendar()
            val month = calendar.get(Calendar.MONTH) + 1
            val day = calendar.get(Calendar.DAY_OF_MONTH)
            return "2001-%02d-%02dT12:00:00Z".format(month, day)
        }

    /**
     * A `date_created` that is deliberately NOT today's month+day anniversary.
     * Same month, day flipped to 1 (or 2 if today is already the 1st).
     */
    val nonAnniversaryDateCreated: String
        get() {
            val calendar = GregorianCalendar()
            val month = calendar.get(Calendar.MONTH) + 1
            val todayDay = calendar.get(Calendar.DAY_OF_MONTH)
            val day = if (todayDay == 1) 2 else 1
            return "2001-%02d-%02dT12:00:00Z".format(month, day)
        }
}
