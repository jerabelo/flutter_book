DateTime toDate(String date) {
  List<String> parts = date.split(",");
  return DateTime(
      int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}
