import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'journal_note.dart';

class JournalDao {
  // Patrón Singleton
  static final JournalDao instance = JournalDao._internal();
  static Database? _database;

  JournalDao._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'journal_notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            content TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Obtener todas las notas (Lista)
  Future<List<JournalNote>> getNotes() async {
    final db = await database;
    final result = await db.query('notes', orderBy: 'id DESC');
    return result.map((json) => JournalNote.fromMap(json)).toList();
  }

  // Crear una nota
  Future<int> insertNote(JournalNote note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Borrar una nota
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
