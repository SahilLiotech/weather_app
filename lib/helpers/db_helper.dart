import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherDataBaseHelper {
  static final WeatherDataBaseHelper _instance =
      WeatherDataBaseHelper._internal();

  factory WeatherDataBaseHelper() => _instance;

  static Database? _database;

  WeatherDataBaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'weather_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE weather_data (id INTEGER PRIMARY KEY AUTOINCREMENT, date INTEGER, areaName TEXT, weatherDescription TEXT, weatherIcon TEXT, temperature REAL, tempMin REAL, tempMax REAL, windSpeed REAL, humidity REAL)',
        );
      },
      version: 1,
    );
  }

  Future<int> insertWeatherModel(WeatherModel weatherModel) async {
    final db = await database;
    return await db.insert(
      'weather_data',
      weatherModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WeatherModel>> getWeatherModel() async {
    final db = await database;
    final List<Map<String, dynamic>> weatherModelMaps =
        await db.query('weather_data');
    return List.generate(weatherModelMaps.length, (i) {
      return WeatherModel.fromMap(weatherModelMaps[i]);
    });
  }

  Future<void> deleteAllWeatherModels() async {
    final db = await database;
    await db.delete('weather');
  }
}
