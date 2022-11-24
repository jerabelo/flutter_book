import 'package:scoped_model/scoped_model.dart';
import 'NotesModel.dart';
import 'NotesEntry.dart';
import 'Notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book/BaseModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotesList extends StatelessWidget {
  Color _toColor(String NoteColor) {
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
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
          onPressed: () {
            model.entityBeingEdited = Note();
            model.setColor(null);
            model.setStackIndex(1);
          },
        ),
        body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: model.entityList.length,
          itemBuilder: (BuildContext context, int index) {
            Note note = model.entityList[index];
            Color color = _toColor(note.color);
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Card(
                elevation: 8,
                color: color,
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  onTap: () {
                    model.entityBeingEdited = note;
                    model.setColor(model.entityBeingEdited.color);
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
