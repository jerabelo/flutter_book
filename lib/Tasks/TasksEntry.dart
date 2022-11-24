import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';
import 'Tasks.dart';
import 'TasksList.dart';
import 'TasksModel.dart';
import 'package:flutter_book/BaseModel.dart';
import 'TasksDBWorker.dart';
import 'package:flutter_book/utils.dart';

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry() {
    _descriptionEditingController.addListener(() {
      tasksModel.entryBeingEdited?.description =
          _descriptionEditingController.text;
    });
  }

  ListTile _buildDescListTile(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.title),
        title: TextFormField(
          decoration: InputDecoration(hintText: 'Description'),
          controller: _descriptionEditingController,
          validator: (String value) {
            if (value?.length == 0) {
              return 'Please enter a title';
            }
            return null;
          },
        ));
  }

  String _dueDate() {
    if (tasksModel.entryBeingEdited != null &&
        tasksModel.entryBeingEdited.hasDueDate()) {
      return tasksModel.entryBeingEdited.dueDate;
    }
    return '';
  }

  ListTile _buildDateListTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.today),
      title: Text("Due Date"),
      subtitle: Text(_dueDate()),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        color: Colors.blue,
        onPressed: () async {
          String chosenDate = await selectDate(
              context, tasksModel, tasksModel.entryBeingEdited.dueDate);
          if (chosenDate != null) {
            tasksModel.entryBeingEdited.dueDate = chosenDate;
          }
        },
      ),
    );
  }

  Row _buildControlButtons(BuildContext context, TasksModel model) {
    return Row(
      children: [
        Container(
          width: 300,
          child: ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              model.setStackIndex(0);
            },
          ),
        ),
        Spacer(),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            _save(context, tasksModel);
          },
        )
      ],
    );
  }

  void _save(BuildContext context, TasksModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (!model.entryList.contains(model.entryBeingEdited)) {
      model.entryList.add(model.entryBeingEdited);
    }

    if (model.entryBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entryBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entryBeingEdited);
    }
    tasksModel.loadData(TasksDBWorker.db);
    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Note saved!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TasksModel>(
      builder: (BuildContext context, Widget child, TasksModel model) {
        _descriptionEditingController.text =
            model.entryBeingEdited?.description;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: _buildControlButtons(context, model),
          ),
          body: Column(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      _buildDescListTile(context),
                      _buildDateListTile(context)
                    ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
