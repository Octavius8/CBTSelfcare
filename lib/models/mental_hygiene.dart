import "sqlite_database.dart";
import "prompt.dart";
import "../utils/logger.dart";

class MentalHygiene {
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
    await db.serverSync();
    List<Map> listmap =
        await db.query("select * from prompt where category='MENTAL_HYGIENE';");

    listmap.forEach((element) {
      Prompt tempPrompt = new Prompt(
          category: element["category"],
          name: element["name"],
          description: element["description"],
          extra_data1: element["extra_data1"],
          extra_data2: element["extra_data2"]);
      finalList.add(tempPrompt);
    });
    Log.debug(this.runtimeType.toString() + "|" + StackTrace.current.toString(),
        "Returning final list:" + finalList.length.toString() + " Items");
    return finalList;
  }
}
