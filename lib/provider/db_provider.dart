import 'dart:io';


import 'package:person_info_app/models/person.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBProvider {
  late Database database;

  Future<bool> initDB() async {
    try {
      final String databaseName = "PERSONINFO.db";
      final String databasePath = await getDatabasesPath();
      final String path = join(databasePath, databaseName);

      if (!await Directory(dirname(path)).exists()) {
        await Directory(dirname(path)).create(recursive: true);
      }

      database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          print("Database Create");
          String sql = "CREATE TABLE $TABLE_PERSON ("
              "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_NAME TEXT,"
            "$COLUMN_PHONE TEXT"
              ")";
          await db.execute(sql);
        },
      
        onOpen: (Database db) async {
          print("Database version: ${await db.getVersion()}");
        },
      );
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future close() async => database.close();

  Future<List<Person>> getPersons() async {
    List<Map<String, dynamic>> maps = await database.query(
      TABLE_PERSON,
      columns: [COLUMN_ID, COLUMN_NAME, COLUMN_PHONE],
    );



    if (maps.length > 0) {
      return maps.map((p) => Person.fromMap(p)).toList();
    }
    return [];
  }

  Future<Person?> getPerson(int id) async {
    List<Map<String, dynamic>> maps = await database.query(
      TABLE_PERSON,
      columns: [COLUMN_ID, COLUMN_NAME, COLUMN_PHONE],
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return Person.fromMap(maps.first);
    }
    return null;
  }

  Future<Person> insertPerson(Person person) async {
    person.id = await database.insert(TABLE_PERSON, person.toMap());
   
    return person;
  }

  Future<int> updatePerson(Person person) async {
    print(person.id);
    return await database.update(
      TABLE_PERSON,
      person.toMap(),
      where: "$COLUMN_ID = ?",
      whereArgs: [person.id],
    );
  }

  Future<int> deletePerson(int id) async {
    return await database.delete(
      TABLE_PERSON,
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    String sql = "Delete from $TABLE_PERSON";
    return await database.rawDelete(sql);
  }
}
