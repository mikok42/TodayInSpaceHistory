package miko.todayinspacehistory.helpers

import miko.todayinspacehistory.util.monthName
import miko.todayinspacehistory.util.todayDayMonthComponents
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.GregorianCalendar
import java.util.Locale

class DateExtensionTests {
    @Test
    fun monthIsEnglishRegardlessOfLocale() {
        val previous = Locale.getDefault()
        try {
            Locale.setDefault(Locale("pl", "PL"))
            val date = GregorianCalendar().apply {
                clear()
                set(2026, Calendar.AUGUST, 9, 12, 0, 0)
            }.time

            val polish = SimpleDateFormat("MMMM", Locale("pl", "PL")).format(date)
            assertNotEquals("August", polish)
            assertEquals("August", date.monthName())
            assertEquals(listOf("9", "August"), todayDayMonthComponents(date))
        } finally {
            Locale.setDefault(previous)
        }
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
