import 'package:scoped_model/scoped_model.dart';
import 'TasksModel.dart';
import 'TasksEntry.dart';
import 'Tasks.dart';
import 'TasksDBWorker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book/BaseModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_book/utils.dart';

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget child, TasksModel model) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              model.entryBeingEdited = Task();
              model.setStackIndex(1);
            },
          ),
          body: ListView.builder(
              // a ScopedModel wrapping a Scaffold
              itemCount: tasksModel.entryList.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = tasksModel.entryList[index];
                return Container(
                    child: ListTile(
                        leading: Checkbox(
                            value: task.completed,
                            onChanged: (value) async {
                              print(value);
                              task.completed = value;
                              await TasksDBWorker.db.update(task);
                              tasksModel.loadData(TasksDBWorker.db);
                            }),
                        title: Text("${task.description}",
                            style: task.completed
                                ? TextStyle(
                                    color: Theme.of(context).disabledColor,
                                    decoration: TextDecoration.lineThrough)
                                : TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color)),
                        subtitle: Text("${task.dueDate}"),
                        onTap: () {
                          print('this is a test');
                          task.completed = true;
                        }));
              }));
    });
  }
}
