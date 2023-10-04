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
  Future<bool> connect({bool reset = false}) async {
    Log.debug("SqliteDatabase | Connect()", "Starting connection function...");
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + DatabaseConfigs.db_name;

    // Delete the database
    if (reset) await deleteDatabase(path);

    // open the database
    try {
      this.database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        //log the new installation :)
        Api api = new Api();
        api.logActivity("NEW_INSTALLATION");

        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE prompt (prompt_id INTEGER PRIMARY KEY, category TEXT, name TEXT,  version TEXT, description TEXT,extra_data1 TEXT, extra_data2 TEXT,extra_data3 TEXT, extra_data4 TEXT)');
        await db.execute(
            'CREATE TABLE prompt_answers (prompt_responses_id INTEGER PRIMARY KEY, prompt_id INTEGER,prompt_name TEXT, version_number TEXT, description TEXT,extra_data1 TEXT, extra_data2 TEXT,extra_data3 TEXT, extra_data4 TEXT,date_created DATETIME DEFAULT CURRENT_TIMESTAMP)');
        await db.execute(
            'CREATE TABLE config (prompt_id INTEGER PRIMARY KEY, config_name TEXT, config_value TEXT, date_created DATETIME DEFAULT CURRENT_TIMESTAMP)');
      });
    } catch (ex) {
      Log.error("SqliteDatabase | Connect()",
          "Failed to connect to database: " + ex.toString());
    }
    if (this.database.isOpen) {
      Log.debug("SqliteDatabase | Connect()", "Database openned successfully");
    } else {
      Log.debug("SqliteDatabase | Connect()", "Database connection failed");
    }
    Log.debug("SqliteDatabase | Connect()", "Finished Connection Function.");
    return true;
  }

  /*
   * Query
   * Description: Run a query on the database that returns data
   * Parameters: sql : The SQL query you want to run
   */
  Future<List<Map>> query(sql) async {
    Log.debug("SqliteDatabase | query", "Starting query: " + sql);
    List<Map> list = await database.rawQuery(sql);
    Log.debug("SqliteDatabase | query", "Response is: " + jsonEncode(list));
    return list;
  }

  /*
   * serverSync
   * Description: bulk update the table values
   * Parameters: 
   */
  Future<bool> serverSync(String uid) async {
    // Prompt table update
    Api api = new Api();
    //Todo: Verify db version number first
    try {
      api.logActivity("LOGIN");
      String api_response = await api.postRequest(method: "getPrompts") ?? "";
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
          Log.debug(
              "SqliteDatabase | serverSync()", "New entry being processed");

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
    } catch (ex) {
      Log.error("ServerSync", "Sync failed: " + ex.toString());
    }
    return true;
  }

  Future<String> getConfig(String configname) async {
    String response = "";
    List<Map> data =
        await query("Select * from config where config_name='$configname'");
    if (data.length != 0) {
      response = data[0]['config_value'];
    } else {
      response = "";
    }
    return response;
  }

  Future<bool> setConfig(String configname, String configvalue) async {
    try {
      var value = await query(
          "update config set config_value='$configvalue' where config_name='$configname';");
      Log.debug(
          "SqliteDatabase | setConfig",
          "query is :" +
              "update config set config_value='$configvalue' where config_name='$configname';");
      Log.debug("SqliteDatabase | setConfig", "Successfully updated hehe");
      String temp = await getConfig(configname);
      if (configvalue != temp) {
        //Not in DB INsert
        await query(
            "insert into config(config_name,config_value) values('$configname','$configvalue');");
      }
    } catch (e) {
      Log.error("SqliteDatabase | setConfig",
          "Something went wrong updating config. " + e.toString());
    }

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
