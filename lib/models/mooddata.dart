class MoodData {
  MoodData(this.date, this.value);

  final String date;
  final double value;

  @override
  String toString() {
    return date + "-" + value.toString();
  }
}
