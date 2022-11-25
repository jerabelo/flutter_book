import 'package:scoped_model/scoped_model.dart';
import '../BaseModel.dart';
import 'Links.dart';
import 'LinksEntry.dart';
import 'LinksList.dart';

LinksModel linksModel = LinksModel();

class Link {
  int id;
  String title;
  String content;
  String color;

  String toString() => "{title=$title, content=$content, color=$color }";
}

class LinksModel extends BaseModel<Link> {
  String color;

  void setColor(String color) {
    this.color = color;
    notifyListeners();
  }
}
