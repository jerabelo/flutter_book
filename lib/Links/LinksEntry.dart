import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'LinksEntry.dart';
import 'Links.dart';
import 'LinksModel.dart' show LinksModel, linksModel;
import 'LinksList.dart';
import 'LinksDBWorker.dart';
import 'package:sqflite/sqflite.dart';

class LinksEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LinksEntry() {
    _titleEditingController.addListener(() {
      linksModel.entityBeingEdited?.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      linksModel.entityBeingEdited?.content = _contentEditingController.text;
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
        decoration: InputDecoration(hintText: 'Content'),
        controller: _contentEditingController,
        validator: (String value) {
          if (value?.length == 0) {
            return 'Please enter content';
          }
          return null;
        },
      ),
    );
  }

  ListTile _buildColorListTile(BuildContext context) {
    const colors = ['red', 'green', 'blue', 'yellow', 'grey', 'purple'];
    return ListTile(
      leading: Icon(Icons.color_lens),
      title: Row(
        children: colors
            .expand((c) => [_buildColorBox(context, c), const Spacer()])
            .toList()
          ..removeLast(),
      ),
    );
  }

  GestureDetector _buildColorBox(BuildContext context, String color) {
    Color _toColor(String LinkColor) {
      Color color = Colors.red;
      switch (LinkColor) {
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

    // setting color values as blue by default, unable to set null values atm
    final Color colorValue = _toColor(color);
    // color is returning null
    return GestureDetector(
      child: Container(
        decoration: ShapeDecoration(
            shape: Border.all(width: 16, color: colorValue) +
                Border.all(
                    width: 4,
                    color: linksModel.color == color
                        ? colorValue
                        : Theme.of(context).canvasColor)),
      ),
      onTap: () {
        linksModel.entityBeingEdited?.color = color;
        linksModel.setColor(color);
        print(linksModel.color);
      },
    );
  }

  Row _buildControlButtons(BuildContext context, LinksModel model) {
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
            _save(context, linksModel);
          },
        )
      ],
    );
  }

  void _save(BuildContext context, LinksModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (!model.entityList.contains(model.entityList)) {
      model.entityList.add(model.entityBeingEdited);
    }

    if (model.entityBeingEdited.id == null) {
      await LinksDBWorker.db.create(linksModel.entityBeingEdited);
    } else {
      await LinksDBWorker.db.update(linksModel.entityBeingEdited);
    }
    linksModel.loadData(LinksDBWorker.db);
    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Link saved!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<LinksModel>(
      builder: (BuildContext context, Widget child, LinksModel model) {
        _titleEditingController.text = model.entityBeingEdited?.title;
        _contentEditingController.text = model.entityBeingEdited?.content;
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
                    _buildColorListTile(context)
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
