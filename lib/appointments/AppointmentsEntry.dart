import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart';
import 'Appointments.dart';
import 'AppointmentsModel.dart';
import 'package:flutter_book/BaseModel.dart';
import 'AppointmentsDBWorker.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry() {
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited?.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited?.description =
          _descriptionEditingController.text;
    });
  }

  ListTile _buildTitleListTile() {
    return ListTile(
        leading: Icon(Icons.title),
        title: TextFormField(
          decoration: InputDecoration(hintText: 'Title'),
          controller: _titleEditingController,
          validator: (String value) {
            if (value?.length == 0) {
              return 'Please enter a title';
            }
            return null;
          },
        ));
  }

  ListTile _buildContentListTile() {
    return ListTile(
      leading: Icon(Icons.content_paste),
      title: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 8,
        decoration: InputDecoration(hintText: 'Description'),
        controller: _descriptionEditingController,
        validator: (String value) {
          if (value?.length == 0) {
            return 'Please enter description';
          }
          return null;
        },
      ),
    );
  }

  String _Date() {
    if (appointmentsModel.entityBeingEdited != null &&
        appointmentsModel.entityBeingEdited.hasDate()) {
      return appointmentsModel.entityBeingEdited.date;
    }
    return '';
  }

  ListTile _buildDateListTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.today),
      title: Text("Date"),
      subtitle: Text(_Date()),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        color: Colors.blue,
        onPressed: () async {
          String chosenDate = await selectDate(context, appointmentsModel,
              appointmentsModel.entityBeingEdited.date);
          if (chosenDate != null) {
            appointmentsModel.entityBeingEdited.date = chosenDate;
          }
        },
      ),
    );
  }

  Row _buildControlButtons(BuildContext context, AppointmentsModel model) {
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
            _save(context, appointmentsModel);
          },
        )
      ],
    );
  }

  void _save(BuildContext context, AppointmentsModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (!model.entityList.contains(model.entityList)) {
      model.entityList.add(model.entityBeingEdited);
    }

    if (model.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }
    appointmentsModel.loadData(AppointmentsDBWorker.db);
    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Note saved!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppointmentsModel>(
      builder: (BuildContext context, Widget child, AppointmentsModel model) {
        _titleEditingController.text = model.entityBeingEdited?.title;
        _descriptionEditingController.text =
            model.entityBeingEdited?.description;
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
                    _buildTitleListTile(),
                    _buildContentListTile(),
                    _buildDateListTile(context),
                    _buildTimeTile(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _selectTime(BuildContext context) async {
  TimeOfDay initialTime = TimeOfDay.now();
  if (appointmentsModel.entityBeingEdited.time != null) {
    initialTime = toTime(appointmentsModel.entityBeingEdited.time);
  }
  TimeOfDay picked =
      await showTimePicker(context: context, initialTime: initialTime);
  if (picked != null) {
    appointmentsModel.entityBeingEdited.time =
        "${picked.hour},${picked.minute}";
    appointmentsModel.setTime(picked.format(context));
  }
}

_buildTimeTile(BuildContext context) {
  return ListTile(
      leading: Icon(Icons.alarm),
      title: Text("Time"),
      subtitle: Text(appointmentsModel.time ?? ''),
      trailing: IconButton(
          icon: Icon(Icons.edit),
          color: Colors.blue,
          onPressed: (() => _selectTime(context))));
}

toTime(time) {
  List timeParts = time.split(",");
  TimeOfDay initialtime =
      TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
  return initialtime;
}
