package miko.todayinspacehistory.util

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

fun Date.monthName(locale: Locale = Locale.US): String {
    val formatter = SimpleDateFormat("MMMM", locale)
    return formatter.format(this)
}

fun todayDayMonthComponents(locale: Locale = Locale.US): List<String> {
    val now = Date()
    val calendar = Calendar.getInstance()
    val day = calendar.get(Calendar.DAY_OF_MONTH).toString()
    val month = now.monthName(locale)
    return listOf(day, month)
}

fun todayDayLabel(locale: Locale = Locale.getDefault()): String {
    val formatter = SimpleDateFormat("d MMMM", locale)
    return formatter.format(Date())
}
