package miko.todayinspacehistory.helpers

import miko.todayinspacehistory.support.TestFixtures
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ItemAnniversaryTests {
    @Test
    fun matchesHardcodedAnniversaryDate() {
        val item = TestFixtures.item(dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED)
        assertTrue(item.matchesAnniversary(TestFixtures.july20_2026()))
    }

    @Test
    fun doesNotMatchOtherDay() {
        val item = TestFixtures.item(dateCreated = TestFixtures.ANNIVERSARY_DATE_CREATED)
        assertFalse(item.matchesAnniversary(TestFixtures.august9_2026()))
    }

    @Test
    fun invalidOrShortDateReturnsFalse() {
        val now = TestFixtures.july20_2026()
        assertFalse(TestFixtures.item(dateCreated = "bad").matchesAnniversary(now))
        assertFalse(TestFixtures.item(dateCreated = null).matchesAnniversary(now))
        assertFalse(TestFixtures.item(dateCreated = "2020-01").matchesAnniversary(now))
    }
}
