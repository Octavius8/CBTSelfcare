class MoodData {
  MoodData(this.year, this.sales);

  final String year;
  final double sales;

  @override
  String toString() {
    return year + "-" + sales.toString();
  }
}
