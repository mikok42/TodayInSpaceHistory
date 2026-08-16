package miko.todayinspacehistory.helpers

import miko.todayinspacehistory.util.monthName
import miko.todayinspacehistory.util.todayDayMonthComponents
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Calendar
import java.util.GregorianCalendar

class DateExtensionTests {
    @Test
    fun monthIsEnglishRegardlessOfLocale() {
        val calendar = GregorianCalendar()
        calendar.set(2026, Calendar.AUGUST, 9, 12, 0, 0)
        val date = calendar.time

        assertEquals("August", date.monthName())
    }

    @Test
    fun todayDayMonthComponentsHasDayAndEnglishMonth() {
        val parts = todayDayMonthComponents()
        assertEquals(2, parts.size)
        assertFalse(parts[0].isEmpty())

        val englishMonths = setOf(
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December",
        )
        assertTrue(
            "Expected English month name, got ${parts[1]}",
            englishMonths.contains(parts[1]),
        )
    }
}
