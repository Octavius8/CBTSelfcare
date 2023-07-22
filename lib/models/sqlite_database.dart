import 'package:sqflite/sqflite.dart';
import '../config/database_configs.dart';
import 'dart:async';

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
    // Insert some records in a transaction
    await this.database.transaction((txn) async {
      await txn.rawDelete('DELETE FROM prompt');
      int id0 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data1) VALUES("CONVERSATION", "Mood Tracker", "A conversation to monitor and correct unhelpful thoughts.",\'["Hi, the purpose of this chat is to give you a healthy place to rant while also acting as a mood tracker.","What is the situation?","What are you doing?"]\')');

      int id1 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data4) VALUES("MENTAL_HYGIENE", "Social Media Audit", "Go through your social media, and other feeds, and check to see if you are following people or pages that reinforce your draining thoughts and emotions.","1")');
      int id2 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data4) VALUES("MENTAL_HYGIENE", "Clean Your Workspace", "The mind tends to take on the form of its environment. Now is a chance to clean out your workspace and arrange all your tools.","2")');
      int id3 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data4) VALUES("MENTAL_HYGIENE", "Reach Out To Someone You Care About", "Maintaining your relationships is a great way to boost your mental health. Humans are social creatures by nature and by talking to someone you care about you what what what what.","3")');
      int id4 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data1,extra_data2,extra_data3,extra_data4) VALUES("LECTURE", "Getting Started", "The mind tends to take on the form of its environment. Now is a chance to clean out your workspace and arrange all your tools.","https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4","0","","1")');
      print('inserted1: $id1');
    });

    return true;
  }

  Future<bool> disconnect() async {
    await this.database.close();
    return true;
  }

  Future<int> count() async {
    // Count the records
    int count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM prompt'))!;
    assert(count == 2);
    return count;
  }
}
