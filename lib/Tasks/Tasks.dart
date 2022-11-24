import 'package:flutter/material.dart';
import 'TasksDBWorker.dart';
import 'TasksEntry.dart';
import 'TasksList.dart';
import 'TasksModel.dart';
import 'package:scoped_model/scoped_model.dart';

class Tasks extends StatelessWidget {
  Tasks() {
    tasksModel.loadData(TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext context, Widget child, TasksModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[TasksList(), TasksEntry()],
          );
        }));
  }
}
