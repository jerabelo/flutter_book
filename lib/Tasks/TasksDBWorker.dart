import 'package:flutter_book/Tasks/TasksModel.dart';
import 'package:sqflite/sqflite.dart';

abstract class TasksDBWorker {
  static final TasksDBWorker db = _SqfliteTasksDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(Task task);

  /// Update the given note of this database.
  Future<void> update(Task task);

  /// Delete the specified note.
  Future<void> delete(int id);

  /// Return the specified note, or null.
  Future<Task> get(int id);

  /// Return all the notes of this database.
  Future<List<Task>> getAll();
}

class _SqfliteTasksDBWorker implements TasksDBWorker {
  static const String DB_NAME = 'tasks.db';
  static const String TBL_NAME = 'tasks';
  static const String KEY_ID = 'id';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_DUEDATE = 'dueDate';
  static const String KEY_COMPLETED = 'completed';

  Database _db;

  _SqfliteTasksDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    print("Task DB WORKING");
    return await openDatabase(DB_NAME, version: 2, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS $TBL_NAME ("
          "$KEY_ID INTEGER PRIMARY KEY, "
          "$KEY_DESCRIPTION TEXT, "
          "$KEY_DUEDATE TEXT, "
          "$KEY_COMPLETED INTEGER"
          ")");
    });
  }

  @override
  Future<int> create(Task task) async {
    print('task being created');
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_DESCRIPTION, $KEY_DUEDATE, $KEY_COMPLETED) "
        "VALUES (?, ?, ?)",
        [task.description, task.dueDate, task.completed ? 1 : 0]);
    print(id);
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(Task task) async {
    print('updating..');
    Database db = await database;
    await db.update(TBL_NAME, _taskToMap(task),
        where: "$KEY_ID = ?", whereArgs: [task.id]);
  }

  @override
  Future<Task> get(int id) async {
    Database db = await database;
    var values =
        await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _taskFromMap(values.first);
  }

  @override
  Future<List<Task>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _taskFromMap(m)).toList() : [];
  }

  Task _taskFromMap(Map map) {
    return Task()
      ..id = map[KEY_ID]
      ..description = map[KEY_DESCRIPTION]
      ..dueDate = map[KEY_DUEDATE]
      ..completed = map[KEY_COMPLETED] == 0 ? false : true;
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return Map<String, dynamic>()
      ..[KEY_ID] = task.id
      ..[KEY_DESCRIPTION] = task.description
      ..[KEY_DUEDATE] = task.dueDate
      ..[KEY_COMPLETED] = task.completed;
  }
}
