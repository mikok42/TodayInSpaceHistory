package miko.todayinspacehistory.helpers

import miko.todayinspacehistory.util.rewritingHTTPSchemeToHTTPS
import org.junit.Assert.assertEquals
import org.junit.Test

class StringHTTPSchemeTests {
    @Test
    fun rewritesHttpSchemeOnly() {
        assertEquals(
            "https://cdn.example.com/large.jpg",
            "http://cdn.example.com/large.jpg".rewritingHTTPSchemeToHTTPS,
        )
        assertEquals(
            "https://cdn.example.com/original.jpg",
            "https://cdn.example.com/original.jpg".rewritingHTTPSchemeToHTTPS,
        )
    }
}
