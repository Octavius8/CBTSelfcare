import 'prompt.dart';
import '../utils/logger.dart';
import 'sqlite_database.dart';
import 'dart:async';

class Lecture {
  Future<Prompt?> getCurrentLecture() async {
    String logPrefix = "Lecture | getCurrentLecture()";

    Log.debug(logPrefix, "Starting...");
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
    Log.debug("getCurrentLecture", "Returning latest lecture");

    return tempPrompt;
  }

  Future<Prompt?> getLecture(int prompt_id) async {
    String logPrefix = "Lecture | getLecture()";

    Log.debug("Lecture | getLecture()", "Starting... prompt_id: $prompt_id ");
    SqliteDatabase db = new SqliteDatabase();
    Log.debug(logPrefix, "Connecting to DB");
    await db.connect();
    Log.debug(logPrefix, "Selecting the data from the db");

    // extra_data2 is a flag 0 watched, 1 watched
    List<Map> listmap = await db.query(
        "select * from prompt where category='LECTURE' and extra_data3='$prompt_id';");

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
    Log.debug(logPrefix, "Returning lecture");

    return tempPrompt;
  }

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
        "select * from prompt where category='LECTURE' and extra_data2='0' order by extra_data4 limit 2;");

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
        "Returning next lecture");

    return tempPrompt;
  }

  Future<Prompt?> getPreviousLecture() async {
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
        "select * from prompt where category='LECTURE' and extra_data2='1' order by extra_data4;");

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
        "Returning next lecture");

    return tempPrompt;
  }
}
