import 'Links.dart';
import 'LinksModel.dart';
import 'package:sqflite/sqflite.dart';

abstract class LinksDBWorker {
  static final LinksDBWorker db = _SqfliteLinksDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(Link link);

  /// Update the given note of this database.
  Future<void> update(Link link);

  /// Delete the specified note.
  Future<void> delete(int id);

  /// Return the specified note, or null.
  Future<Link> get(int id);

  /// Return all the notes of this database.
  Future<List<Link>> getAll();
}

class _SqfliteLinksDBWorker implements LinksDBWorker {
  static const String DB_NAME = 'links.db';
  static const String TBL_NAME = 'links';
  static const String KEY_ID = '_id';
  static const String KEY_TITLE = 'title';
  static const String KEY_CONTENT = 'content';
  static const String KEY_COLOR = 'color';

  Database _db;

  _SqfliteLinksDBWorker._();

  Future<Database> get database async => _db ??= await _init();
  Future<Database> _init() async {
    print("DB WORKING");
    return await openDatabase(DB_NAME, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS $TBL_NAME ("
          "$KEY_ID INTEGER PRIMARY KEY,"
          "$KEY_TITLE TEXT,"
          "$KEY_CONTENT TEXT,"
          "$KEY_COLOR TEXT"
          ")");
    });
  }

  @override
  Future<int> create(Link link) async {
    print('link being created');
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_CONTENT, $KEY_COLOR) "
        "VALUES (?, ?, ?)",
        [link.title, link.content, link.color]);
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(Link link) async {
    print('updating..');
    Database db = await database;
    await db.update(TBL_NAME, _noteToMap(link),
        where: "$KEY_ID = ?", whereArgs: [link.id]);
  }

  @override
  Future<Link> get(int id) async {
    Database db = await database;
    var values =
        await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _noteFromMap(values.first);
  }

  @override
  Future<List<Link>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _noteFromMap(m)).toList() : [];
  }

  Link _noteFromMap(Map map) {
    return Link()
      ..id = map[KEY_ID]
      ..title = map[KEY_TITLE]
      ..content = map[KEY_CONTENT]
      ..color = map[KEY_COLOR];
  }

  Map<String, dynamic> _noteToMap(Link link) {
    return Map<String, dynamic>()
      ..[KEY_ID] = link.id
      ..[KEY_TITLE] = link.title
      ..[KEY_CONTENT] = link.content
      ..[KEY_COLOR] = link.color;
  }
}
