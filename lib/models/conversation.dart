import "dart:ffi";

import "sqlite_database.dart";
import "prompt.dart";
import "../utils/logger.dart";
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

  Future<bool> saveAnswers(List<String> answers) async {
    String jsonList = jsonEncode(answers);

    SqliteDatabase db = new SqliteDatabase();
    await db.connect();
    var row = {
      'prompt_id': prompt?.prompt_id ?? "",
      'prompt_name': prompt?.name ?? "",
      'version_number': "1",
      'description': jsonList,
      'extra_data1': "",
      'extra_data2': "",
      'extra_data3': "",
      'extra_data4': "",
    };
    await db.database.insert('prompt_answers', row);
    await countAnswers();
    return true;
  }

  Future<bool> extractAnswers(String path) async {
    String finalString = prompt?.extra_data1 ?? "";
    SqliteDatabase db = new SqliteDatabase();
    await db.connect();
    List list = await db.query(
        "select * from prompt_answers where prompt_name='${prompt?.name}'");
    Log.debug("Conversation | extractAnswers",
        "Number of responses is :" + list.length.toString());
    list.forEach((item) {
      print("Testing- " + item["description"] + "\n");
      finalString +=
          "\n" + (item["date_created"] + " | " + item["description"]);
    });
    Log.debug("Conversation | extractAnswers() | ", finalString);

    //Write to file
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());

    path = path + "/cbt_${prompt?.name.replaceAll(" ", "_")}_$date.txt";
    Log.debug("Conversation | extractAnswers", "Path is $path");
    final myFile = File(path);
    // If data.txt doesn't exist, it will be created automatically

    await myFile.writeAsString(finalString);
    return true;
  }

  Future<int> countAnswers() async {
    int count = 0;
    SqliteDatabase db = new SqliteDatabase();
    await db.connect();
    var list = await db.query("select * from prompt_answers");
    Iterable.castFrom(list).forEach((item) {
      print("Prompt Answer: " + jsonEncode(item));
      count++;
    });
    return count;
  }
}
