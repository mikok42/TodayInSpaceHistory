package miko.todayinspacehistory.helpers

import miko.todayinspacehistory.support.TestFixtures
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ItemAnniversaryTests {
    @Test
    fun matchesTodaysAnniversary() {
        val item = TestFixtures.item(dateCreated = TestFixtures.todaysAnniversaryDateCreated)
        assertTrue(item.matchesTodaysAnniversary)
    }

    @Test
    fun doesNotMatchOtherDay() {
        val item = TestFixtures.item(dateCreated = TestFixtures.nonAnniversaryDateCreated)
        assertFalse(item.matchesTodaysAnniversary)
    }

    @Test
    fun invalidOrShortDateReturnsFalse() {
        assertFalse(TestFixtures.item(dateCreated = "bad").matchesTodaysAnniversary)
        assertFalse(TestFixtures.item(dateCreated = null).matchesTodaysAnniversary)
        assertFalse(TestFixtures.item(dateCreated = "2020-01").matchesTodaysAnniversary)
    }
}
