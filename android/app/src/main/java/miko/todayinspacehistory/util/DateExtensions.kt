package miko.todayinspacehistory.util

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.GregorianCalendar
import java.util.Locale

/** English month name for NASA search queries (locale-independent). */
fun Date.monthName(): String {
    val formatter = SimpleDateFormat("MMMM", Locale.US)
    return formatter.format(this)
}

fun todayDayMonthComponents(): List<String> {
    val now = Date()
    val calendar = GregorianCalendar()
    val day = calendar.get(Calendar.DAY_OF_MONTH).toString()
    val month = now.monthName()
    return listOf(day, month)
}

fun todayDayLabel(locale: Locale = Locale.getDefault()): String {
    val formatter = SimpleDateFormat("d MMMM", locale)
    return formatter.format(Date())
}
