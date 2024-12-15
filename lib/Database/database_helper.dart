import 'dart:async';
import 'package:mymovies_app/Models/movies_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'movies.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movies(
            id INTEGER PRIMARY KEY,
            title TEXT,
            posterURL TEXT,
            imdbId TEXT,
            localPosterPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE favourites(
            id INTEGER PRIMARY KEY,
            title TEXT,
            posterURL TEXT,
            imdbId TEXT,
            localPosterPath TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> insertMovie(MoviesModel movie) async {
    final db = await database;
    await db.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFavourite(MoviesModel movie) async {
    final db = await database;
    await db.insert(
      'favourites',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MoviesModel>> fetchMovies() async {
    final db = await database;
    final result = await db.query('movies');
    return result.map((movie) => MoviesModel.fromMap(movie)).toList();
  }

  Future<List<MoviesModel>> fetchFavourites() async {
    final db = await database;
    final result = await db.query('favourites');
    return result.map((movie) => MoviesModel.fromMap(movie)).toList();
  }

  Future<void> deleteFavourite(int id) async {
    final db = await database;
    await db.delete('favourites', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearMovies() async {
    final db = await database;
    await db.delete('movies');
  }
}
