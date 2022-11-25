import 'package:sqflite/sqflite.dart';
import 'AppointmentsModel.dart';

abstract class AppointmentsDBWorker {
  static final AppointmentsDBWorker db = _SqfliteAppointmentsDBWorker._();

  /// Create and add the given note in this database.
  Future<int> create(Appointment appointment);

  /// Update the given note of this database.
  Future<void> update(Appointment task);

  /// Delete the specified note.
  Future<void> delete(int id);

  /// Return the specified note, or null.
  Future<Appointment> get(int id);

  /// Return all the notes of this database.
  Future<List<Appointment>> getAll();
}

class _SqfliteAppointmentsDBWorker implements AppointmentsDBWorker {
  static const String DB_NAME = 'appointments.db';
  static const String TBL_NAME = 'appointments';
  static const String KEY_ID = 'id';
  static const String KEY_TITLE = 'title';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_DATE = 'date';
  static const String KEY_TIME = 'time';

  Database _db;

  _SqfliteAppointmentsDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(DB_NAME, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS $TBL_NAME ("
          "$KEY_ID INTEGER PRIMARY KEY,"
          "$KEY_TITLE TEXT,"
          "$KEY_DESCRIPTION TEXT,"
          "$KEY_DATE TEXT,"
          "$KEY_TIME TEXT"
          ")");
    });
  }

  @override
  Future<int> create(Appointment appointment) async {
    print('appt being created');
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_DESCRIPTION, $KEY_DATE, $KEY_TIME) "
        "VALUES (?, ?, ?)",
        [
          appointment.title,
          appointment.description,
          appointment.date,
          appointment.time
        ]);
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<void> update(Appointment appointment) async {
    print('updating..');
    Database db = await database;
    await db.update(TBL_NAME, _taskToMap(appointment),
        where: "$KEY_ID = ?", whereArgs: [appointment.id]);
  }

  @override
  Future<Appointment> get(int id) async {
    Database db = await database;
    var values =
        await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _taskFromMap(values.first);
  }

  @override
  Future<List<Appointment>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _taskFromMap(m)).toList() : [];
  }

  Appointment _taskFromMap(Map map) {
    return Appointment()
      ..id = map[KEY_ID]
      ..title = map[KEY_TITLE]
      ..description = map[KEY_DESCRIPTION]
      ..date = map[KEY_DATE]
      ..time = map[KEY_TIME];
  }

  Map<String, dynamic> _taskToMap(Appointment appointment) {
    return Map<String, dynamic>()
      ..[KEY_ID] = appointment.id
      ..[KEY_TITLE] = appointment.title
      ..[KEY_DESCRIPTION] = appointment.description
      ..[KEY_DATE] = appointment.date
      ..[KEY_TIME] = appointment.time;
  }
}
