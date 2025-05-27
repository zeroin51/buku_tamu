import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'buku_tamu.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tamu (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            no_telepon TEXT NOT NULL,
            identitas TEXT NOT NULL,
            no_kendaraan TEXT,
            perusahaan TEXT,
            bertemu_dengan TEXT,
            keperluan TEXT,
            tanggal_masuk TEXT,
            jam_masuk TEXT,
            tanggal_keluar TEXT,
            jam_keluar TEXT
          )
        ''');
      },
    );

    return _db!;
  }
}
