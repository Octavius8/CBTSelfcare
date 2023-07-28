import "sqlite_database.dart";
import "prompt.dart";
import "../utils/logger.dart";
import 'dart:convert';

class Conversation {
  List<String> conversationList = [];
  Prompt? prompt;
  Future<Prompt?> init(String conversation_tag) async {
    SqliteDatabase db = new SqliteDatabase();
    await db.connect();
    var list = await db
        .query("select * from prompt where extra_data2='$conversation_tag'");
    Prompt? finalPrompt;
    list.forEach((element) {
      this.prompt = new Prompt(
          prompt_id: element["prompt_id"],
          category: element["category"],
          name: element["name"],
          description: element["description"],
          extra_data1: element["extra_data1"] ?? "",
          extra_data2: element["extra_data2"] ?? "",
          extra_data3: element["extra_data3"] ?? "",
          extra_data4: element["extra_data4"] ?? "");
    });
    Log.debug("Conversation | init",
        "extra data1 value is : " + (prompt?.extra_data1 ?? ""));
    List<dynamic> tempList = jsonDecode(prompt?.extra_data1 ?? "");
    conversationList.add(prompt?.description ?? "");
    tempList.forEach((element) {
      conversationList.add(element.toString());
    });
  }
}
