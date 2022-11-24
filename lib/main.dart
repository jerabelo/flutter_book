import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_book/Tasks/Tasks.dart';
import 'package:flutter_book/Tasks/TasksDBWorker.dart';
import 'package:flutter_book/contacts/Contacts.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import 'Notes/Notes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'contacts/Avatar.dart';
import 'contacts/ContactsEntry.dart';
import 'contacts/ContactsDBWorker.dart';
import 'contacts/ContactsModel.dart';
import 'contacts/ContactsList.dart';
import "utils.dart" as utils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    Avatar.docsDir = await getApplicationDocumentsDirectory();
    runApp(FlutterBook());
  }

  startMeUp();
  //adding the contacts code
  //Open notes.db
  //Database db = await openDatabase('notes.db');
  //query to insert info into notes table from tasksDBWorker.dart
  //int id = await db.rawInsert(
  //"INSERT INTO notes (title, content, color) VALUES (?, ?, ?)",
  //["Learn sqflite", "Write notes database", "green"]);
  //await db.delete("notes", where: "_id = ?", whereArgs: [id]);

  // Trying to get database working
  //var databasesPath = await getDatabasesPath();
  //print(databasesPath);
  // String path = join(databasesPath, 'demo.db');

  //print(path);
}

mixin TestWidgetsFlutterBinding {}

class ConfigModel extends Model {
  Color _color = Colors.red;
  Color get color => _color;
  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }
}

class ScopedModelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Scoped Model')),
      body: ScopedModel<ConfigModel>(
        model: ConfigModel(),
        child: Column(
          children: <Widget>[ScopedModelUpdater(), ScopedModelText('hello')],
        ),
      ),
    );
  }
}

class ScopedModelText extends StatelessWidget {
  final text;

  ScopedModelText(this.text);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ConfigModel>(
      builder: (BuildContext context, Widget child, ConfigModel config) =>
          Text('$Text', style: TextStyle(color: config.color)),
    );
  }
}

class ScopedModelUpdater extends StatelessWidget {
  static const _colors = const [Colors.red, Colors.green, Colors.blue];

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ConfigModel>(
        builder: (BuildContext context, Widget child, ConfigModel config) =>
            DropdownButton<Color>(
                value: config.color,
                items: _colors
                    .map<DropdownMenuItem<Color>>((Color color) =>
                        DropdownMenuItem<Color>(
                          value: color,
                          child:
                              Container(width: 100, height: 20, color: color),
                        ))
                    .toList(),
                onChanged: (Color color) => config.setColor(color)));
  }
}

class _Dummy extends StatelessWidget {
  final _title;

  _Dummy(this._title);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_title));
  }
}

class FlutterBook extends StatelessWidget {
  static const _TABS = [
    const {'icon': Icons.person_outline, 'name': 'Appointments'},
    const {'icon': Icons.contacts, 'name': 'Contacts'},
    const {'icon': Icons.note, 'name': 'Notes'},
    const {'icon': Icons.assignment_turned_in, 'name': 'Tasks'},
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FlutterBook',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
            length: _TABS.length,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: Center(child: Text('FlutterBook')),
                  bottom: TabBar(
                    tabs: _TABS
                        .map((tab) => Tab(
                              icon: Icon(tab['icon'] as IconData),
                              text: tab['name'].toString(),
                            ))
                        .toList(),
                  ),
                ),
                //TODO MAKE LIST THE PARENT NOT THE CHILD
                body: TabBarView(
                    //model: NotesModel(),
                    children: [
                      _Dummy('Something else'),
                      Contacts(),
                      Notes(),
                      Tasks(),
                    ]))));
  }
}
