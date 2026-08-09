package miko.todayinspacehistory.util

import androidx.core.text.HtmlCompat

val String.decodedHTMLEntities: String
    get() = HtmlCompat
        .fromHtml(this, HtmlCompat.FROM_HTML_MODE_LEGACY)
        .toString()
        .trim('\n')
