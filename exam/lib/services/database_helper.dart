import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/rental.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  final Logger logger = Logger();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    logger.i("Init DB");
    String path = join(await getDatabasesPath(), 'rentals_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE rentals(id INTEGER PRIMARY KEY, date TEXT, amount REAL, type TEXT, category TEXT, description TEXT)',
        );
      },
    );
  }

  Future<void> insertRental(Rental rental) async {
    logger.i("Insert rental ${rental.id}");
    final db = await database;
    await db.insert(
      'rentals',
      rental.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRentals(List<Rental> rentals) async {
    logger.i("Insert rentals count: ${rentals.length}");
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('rentals'); // Clear old data for simplicity as we fetch all
      for (var rental in rentals) {
        await txn.insert(
          'rentals',
          rental.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Rental>> getRentals() async {
    logger.i("Get rentals");
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('rentals');
    return List.generate(maps.length, (i) {
      return Rental.fromJson(maps[i]);
    });
  }

  Future<Rental?> getRental(int id) async {
    logger.i("Get rental $id");
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rentals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Rental.fromJson(maps.first);
    }
    return null;
  }
  
  Future<void> deleteRental(int id) async {
    logger.i("Delete rental $id");
    final db = await database;
    await db.delete(
      'rentals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
