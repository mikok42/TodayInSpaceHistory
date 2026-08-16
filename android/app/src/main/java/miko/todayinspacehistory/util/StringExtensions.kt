package miko.todayinspacehistory.util

import androidx.core.text.HtmlCompat

val String.decodedHTMLEntities: String
    get() = HtmlCompat
        .fromHtml(this, HtmlCompat.FROM_HTML_MODE_LEGACY)
        .toString()
        .trim('\n')

/** Rewrites only the `http://` scheme prefix; leaves `https://` unchanged. */
val String.rewritingHTTPSchemeToHTTPS: String
    get() = if (startsWith("http://", ignoreCase = true)) {
        "https://" + drop("http://".length)
    } else {
        this
    }
