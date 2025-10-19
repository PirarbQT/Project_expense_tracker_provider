import 'package:sqflite/sqflite.dart';
import '../models/language.dart';
import 'app_database.dart';

class LanguageDao {
  static const table = 'languages';

  Future<int> insert(Language lang) async {
    final db = await AppDatabase.instance.database;
    return db.insert(table, lang.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> update(Language lang) async {
    final db = await AppDatabase.instance.database;
    return db.update(
      table,
      lang.toMap(),
      where: 'id = ?',
      whereArgs: [lang.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Language>> getAll(
      {String? search, String sortBy = 'name', bool asc = true}) async {
    final db = await AppDatabase.instance.database;
    final order = asc ? 'ASC' : 'DESC';
    String where = '';
    List<Object?> args = [];

    if (search != null && search.trim().isNotEmpty) {
      where = 'WHERE name LIKE ? OR isoCode LIKE ? OR nativeName LIKE ?';
      final key = '%${search.trim()}%';
      args = [key, key, key];
    }

    final rows = await db.rawQuery('''
      SELECT * FROM $table
      $where
      ORDER BY $sortBy $order
    ''', args);

    return rows.map((e) => Language.fromMap(e)).toList();
  }

  Future<bool> existsByNameOrIso(String name, String iso,
      {int? excludeId}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      table,
      where: excludeId == null
          ? '(name = ? OR isoCode = ?)'
          : '(name = ? OR isoCode = ?) AND id <> ?',
      whereArgs:
          excludeId == null ? [name, iso] : [name, iso, excludeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
