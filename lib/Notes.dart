import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import 'NotesEntry.dart';
import 'NotesModel.dart' show NotesModel, notesModel;
import 'NotesList.dart';

class Notes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget child, NotesModel model) {
      return IndexedStack(
        index: model.stackIndex,
        children: <Widget>[
          NotesList(),
          NotesEntry(),
        ],
      );
    });
  }
}
