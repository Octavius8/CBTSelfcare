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
      int id1 = await txn.rawInsert(
          'INSERT INTO prompt(category, name, description,extra_data1,extra_data2) VALUES("MENTAL_HYGIENE", "Social Media Audit", "Go through your social media","","")');
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
