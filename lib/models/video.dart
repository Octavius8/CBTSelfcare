import "sqlite_database.dart";
import "prompt.dart";
import "../utils/logger.dart";

class Video {
  Future<List<Prompt>> getList() async {
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Starting...");
    List<Prompt> finalList = [];
    SqliteDatabase db = new SqliteDatabase();
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Connecting to DB");
    await db.connect();
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Selecting the data from the db");
    List<Map> listmap =
        await db.query("select * from prompt where category='LECTURE';");

    listmap.forEach((element) {
      Prompt tempPrompt = new Prompt(
          prompt_id: element["prompt_id"],
          category: element["category"],
          name: element["name"],
          description: element["description"],
          extra_data1: element["extra_data1"] ?? "",
          extra_data2: element["extra_data2"] ?? "",
          extra_data3: element["extra_data3"] ?? "",
          extra_data4: element["extra_data4"] ?? "");
      finalList.add(tempPrompt);
    });
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Returning final list:" + finalList.length.toString() + " Items");
    return finalList;
  }
}
