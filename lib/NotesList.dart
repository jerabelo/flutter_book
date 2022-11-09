import 'package:flutter_book/NotesModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesEntry.dart';
import 'Notes.dart';
import 'package:flutter/material.dart';

class NotesList extends StatelessWidget {
  Color _toColor(String? NoteColor) {
    Color color = Colors.red;
    switch (NoteColor) {
      case 'red':
        color = Colors.red;
        break;
      case 'green':
        color = Colors.green;
        break;
      case 'blue':
        color = Colors.blue;
        break;
      case 'yellow':
        color = Colors.yellow;
        break;
      case 'grey':
        color = Colors.grey;
        break;
      case 'purple':
        color = Colors.purple;
        break;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget child, NotesModel model) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
          onPressed: () {
            model.noteBeingEdited = Note();
            model.setColor(null);
            model.setStackIndex(1);
          },
        ),
        body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: model.noteList.length,
          itemBuilder: (BuildContext context, int index) {
            Note note = model.noteList[index];
            Color color = _toColor(note.color);
            return Container(
              height: 200,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Card(
                elevation: 8,
                color: color,
                child: ListTile(
                  title: Text(note.title!),
                  subtitle: Text(note.content!),
                  onTap: () {
                    model.noteBeingEdited = note;
                    model.setColor(model.noteBeingEdited!.color);
                    model.setStackIndex(1);
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
