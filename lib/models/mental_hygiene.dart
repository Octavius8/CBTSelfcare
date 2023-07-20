import "sqlite_database.dart";
import "prompt.dart";

class MentalHygiene {
  Future<List<Prompt>> getList() async {
    List<Prompt> finalList = [];
    SqliteDatabase db = new SqliteDatabase();
    await db.connect();
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
    return finalList;
  }
}
