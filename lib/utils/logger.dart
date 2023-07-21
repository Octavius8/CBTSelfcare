class Log {
  static void debug(String prefix, String text) {
    var currentTime = getCurrentTime();
    String entry = ('DEBUG | $currentTime | $prefix | $text');
    saveEntry(entry);
  }

  static void info(String prefix, String text) {
    var currentTime = getCurrentTime();
    String entry = ('INFO | $currentTime | $prefix | $text');
    saveEntry(entry);
  }

  static void error(String prefix, String text) {
    var currentTime = getCurrentTime();
    String entry = ('ERROR | $currentTime | $prefix | $text');
    saveEntry(entry);
  }

  static String getCurrentTime() {
    DateTime now = DateTime.now();
    var currentTime =
        new DateTime(now.year, now.month, now.day, now.hour, now.minute);
    return '$currentTime';
  }

  static void saveEntry(String entry) {
    print(entry);
  }
}
