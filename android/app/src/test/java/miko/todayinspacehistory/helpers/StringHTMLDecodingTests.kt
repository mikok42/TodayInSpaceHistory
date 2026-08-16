package miko.todayinspacehistory.helpers

import miko.todayinspacehistory.util.decodedHTMLEntities
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class StringHTMLDecodingTests {
    @Test
    fun decodesNamedEntity() {
        assertEquals("&", "&amp;".decodedHTMLEntities)
    }

    @Test
    fun decodesNumericEntity() {
        // &#0146; is the Windows-1252-style curly apostrophe; HTML decode yields U+2019.
        assertEquals("\u2019", "&#0146;".decodedHTMLEntities)
    }

    @Test
    fun plainTextUnchangedAsideFromTrimming() {
        assertEquals("hello", "hello".decodedHTMLEntities)
    }
}
