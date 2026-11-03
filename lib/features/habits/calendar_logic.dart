int daysInMonth(DateTime month) {
  return DateTime(month.year, month.month + 1, 0).day;
}

Set<int> completedDaysOfMonth(List<DateTime> completedDates, DateTime month) {
  return completedDates
      .where((date) => date.year == month.year && date.month == month.month)
      .map((date) => date.day)
      .toSet();
}

List<int?> monthCells(DateTime month) {
  final blanks = DateTime(month.year, month.month, 1).weekday - 1;

  return [
    for (var i = 0; i < blanks; i++) null,
    for (var day = 1; day <= daysInMonth(month); day++) day,
  ];
}
