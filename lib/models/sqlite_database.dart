import 'package:sqflite/sqflite.dart';
import '../config/database_configs.dart';
import 'dart:async';

class SqliteDatabase {
  late Database database;

  Future<bool> connect() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + DatabaseConfigs.db_name;

    // open the database
    this.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE prompt (id INTEGER PRIMARY KEY, category TEXT, name TEXT, description TEXT,extra_data1 TEXT, extra_data2 TEXT)');
    });

    return true;
  }

  Future<List<Map>> query(sql) async {
    List<Map> list = await database.rawQuery(sql);
    return list;
  }

  Future<bool> serverSync() async {
    // Insert some records in a transaction
    await this.database.transaction((txn) async {
      await txn.rawDelete('DELETE FROM prompt');
      int id1 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data1,extra_data2) VALUES("MENTAL_HYGIENE", "Social Media Audit", "Go through your social media, and other feeds, and check to see if you are following people or pages that reinforce your draining thoughts and emotions.","","")');
      int id2 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data1,extra_data2) VALUES("MENTAL_HYGIENE", "Clean Your Workspace", "The mind tends to take on the form of its environment. Now is a chance to clean out your workspace and arrange all your tools.","","")');
      int id3 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data1,extra_data2) VALUES("MENTAL_HYGIENE", "Reach Out To Someone You Care About", "Maintaining your relationships is a great way to boost your mental health. Humans are social creatures by nature and by talking to someone you care about you what what what what.","","")');
      print('inserted1: $id1');
    });

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
