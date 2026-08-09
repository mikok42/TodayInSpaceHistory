package miko.todayinspacehistory.data.network

import miko.todayinspacehistory.util.todayDayMonthComponents
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

enum class Endpoints(val path: String) {
    Search("/search"),
    Asset("/asset/"),
    Captions("/captions/"),
    Album("/album/");

    val queryParams: Map<String, String>
        get() = when (this) {
            Search -> mapOf(
                "description" to todayDayMonthComponents().joinToString(" "),
                "media_type" to "image",
            )
            Asset, Captions, Album -> emptyMap()
        }

    val url: String?
        get() = when (this) {
            Search -> {
                val query = queryParams.entries.joinToString("&") { (key, value) ->
                    val encoded = URLEncoder.encode(value, StandardCharsets.UTF_8)
                    "$key=$encoded"
                }
                "${ApiConstants.BASE_URL}$path?$query"
            }
            Asset, Captions, Album -> null
        }

    val method: HttpMethod
        get() = HttpMethod.GET
}
