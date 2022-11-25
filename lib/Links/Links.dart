import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'LinksEntry.dart';
import 'LinksModel.dart' show LinksModel, linksModel;
import 'LinksList.dart';
import 'LinksDBWorker.dart';

class Links extends StatelessWidget {
  Links() {
    linksModel.loadData(LinksDBWorker.db);
  }
  @override
  Widget build(BuildContext context) {
    return ScopedModel<LinksModel>(
      model: linksModel,
      child: ScopedModelDescendant<LinksModel>(
        builder: (BuildContext context, Widget child, LinksModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[LinksList(), LinksEntry()],
          );
        },
      ),
    );
  }
}
