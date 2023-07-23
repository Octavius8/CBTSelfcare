import 'package:sqflite/sqflite.dart';
import '../config/database_configs.dart';
import 'dart:async';
import '../utils/api.dart';
import 'dart:convert';
import '../utils/logger.dart';

class SqliteDatabase {
  late Database database;

  /*
   * Connect
   * Description: Establish connection to the database and initiate if necessary
   * Parameters: 
   */
  Future<bool> connect() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + DatabaseConfigs.db_name;

    // Delete the database
    //await deleteDatabase(path);

    // open the database
    this.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE prompt (prompt_id INTEGER PRIMARY KEY, category TEXT, name TEXT, description TEXT,extra_data1 TEXT, extra_data2 TEXT,extra_data3 TEXT, extra_data4 TEXT)');
    });

    return true;
  }

  /*
   * Query
   * Description: Run a query on the database that returns data
   * Parameters: sql : The SQL query you want to run
   */
  Future<List<Map>> query(sql) async {
    List<Map> list = await database.rawQuery(sql);
    return list;
  }

  /*
   * serverSync
   * Description: bulk update the table values
   * Parameters: 
   */
  Future<bool> serverSync() async {
    // Prompt table update
    Api api = new Api();
    //Todo: Verify db version number first
    String api_response = await api.postRequest(method: "getAllPrompts") ?? "";
    if (api_response == "") {
      Log.debug("SqliteDatabase | serverSync()",
          "No data fetched. Ending server syncc");
      return false;
    }
    Log.debug("SqliteDatabase | serverSync()",
        "Data fetched. Proceeding to update db");

    var json_response = jsonDecode(api_response);
    List<dynamic> responseList = json_response["data"];
    Log.debug("SqliteDatabase | serverSync",
        "Response list: " + responseList.toString());

    await this.database.transaction((txn) async {
      await txn.rawDelete('DELETE FROM prompt');
      responseList.forEach((prompt) async {
        Log.debug("SqliteDatabase | serverSync()", "New entry being processed");

        var row = {
          'prompt_id': prompt["prompt_id"],
          'category': prompt["category"],
          'name': prompt["name"],
          'description': prompt["description"],
          'extra_data1': prompt["extra_data1"],
          'extra_data2': prompt["extra_data2"],
          'extra_data3': prompt['extra_data3'],
          'extra_data4': prompt["extra_data4"],
        };
        await database.insert('prompt', row);
      });
    });

    int count = await this.count();
    Log.debug(
        "SqliteDatabase | serverSync()", "DB Count is:" + count.toString());
    return true;
  }

  Future<bool> disconnect() async {
    await this.database.close();
    return true;
  }

  Future<int> count() async {
    // Count the records
    int count = Sqflite.firstIntValue(
        await this.database.rawQuery('SELECT COUNT(*) FROM prompt'))!;
    return count;
  }
}
