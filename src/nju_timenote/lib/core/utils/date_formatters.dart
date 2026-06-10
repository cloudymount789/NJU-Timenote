String formatMonthDay(DateTime date) {
  return '${date.month}.${date.day.toString().padLeft(2, '0')}';
}

String formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String formatDateTimeShort(DateTime date) {
  return '${formatMonthDay(date)} ${formatTime(date)}';
}

String formatTodoDuration(DateTime start, DateTime end) {
  return '${formatDateTimeShort(start)} - ${formatTime(end)}';
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
