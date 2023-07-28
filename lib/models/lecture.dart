import 'prompt.dart';
import '../utils/logger.dart';
import 'sqlite_database.dart';
import 'dart:async';

class Lecture {
  Future<Prompt?> getNextLecture() async {
    String logPrefix = "Lecture | getNextLecture()";

    Log.debug("Lecture | getNextLecture()", "Starting...");
    SqliteDatabase db = new SqliteDatabase();
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Connecting to DB");
    await db.connect();
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Selecting the data from the db");

    // extra_data2 is a flag 0 watched, 1 watched
    List<Map> listmap = await db.query(
        "select * from prompt where category='LECTURE' and extra_data2='0' order by extra_data4 limit 1;");

    Prompt? tempPrompt;
    listmap.forEach((element) {
      tempPrompt = new Prompt(
          prompt_id: element["prompt_id"],
          category: element["category"],
          name: element["name"],
          description: element["description"],
          extra_data1: element["extra_data1"] ?? "",
          extra_data2: element["extra_data2"] ?? "",
          extra_data3: element["extra_data3"] ?? "",
          extra_data4: element["extra_data4"] ?? "");
    });
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Returning latest lecture");

    return tempPrompt;
  }
}
