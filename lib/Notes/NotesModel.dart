import 'package:scoped_model/scoped_model.dart';
import '../BaseModel.dart';
import 'Notes.dart';
import 'NotesEntry.dart';
import 'NotesList.dart';

NotesModel notesModel = NotesModel();

class Note {
  int id;
  String title;
  String content;
  String color;

  String toString() => "{title=$title, content=$content, color=$color }";
}

class NotesModel extends BaseModel<Note> {
  String color;

  void setColor(String color) {
    this.color = color;
    notifyListeners();
  }
}
