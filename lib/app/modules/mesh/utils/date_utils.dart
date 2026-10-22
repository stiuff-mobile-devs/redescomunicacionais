String toJsIso(DateTime date) {
  return DateTime.fromMillisecondsSinceEpoch(
    date.millisecondsSinceEpoch,
    isUtc: true,
  ).toIso8601String();
}
