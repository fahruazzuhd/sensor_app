
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sensor_app/src/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  //inisialisasi beberapa variabel yang dibutuhkan
  final String tableName = 'userTable';
  final String columnId = 'id';
  final String columnEmail = 'email';
  final String columnPassword = 'password';

  DbHelper._internal();
  factory DbHelper() => _instance;

  //cek apakah database ada
  Future<Database?> get _db  async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'user.db');
    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  //membuat tabel dan field-fieldnya
  Future<void> _onCreate(Database db, int version) async {
    var sql = "CREATE TABLE $tableName("
        "$columnId INTEGER PRIMARY KEY, "
        "$columnEmail TEXT,"
        "$columnPassword TEXT)";
    await db.execute(sql);
  }

  //insert ke database
  Future<int?> saveUsers(Users users) async {
    var dbClient = await _db;
    return await dbClient!.insert(tableName, users.toMap());
  }

  //read database
  Future<List?> getAllUsers() async {
    var dbClient = await _db;
    var result = await dbClient!.query(tableName, columns: [
      columnId,
      columnEmail,
      columnPassword
    ]);

    return result.toList();
  }

  //update database
  Future<int?> updateUsers(Users users) async {
    var dbClient = await _db;
    return await dbClient!.update(tableName, users.toMap(), where: '$columnId = ?', whereArgs: [users.id]);
  }

  //hapus database
  Future<int?> deleteUsers(int id) async {
    var dbClient = await _db;
    return await dbClient!.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }
}