import 'package:scoped_model/scoped_model.dart';
import 'LinksModel.dart';
import 'LinksEntry.dart';
import 'Links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book/BaseModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksList extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<LinksModel>(
      builder: (BuildContext context, Widget child, LinksModel model) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              model.entityBeingEdited = Link();
              model.setColor(null);
              model.setStackIndex(1);
            },
          ),
          body: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: model.entityList.length,
            itemBuilder: (BuildContext context, int index) {
              Link link = model.entityList[index];
              Color color = _toColor(link.color);
              return Container(
                height: 100,
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 20,
                  shadowColor: Colors.black,
                  color: color,
                  child: ListTile(
                    leading: Icon(
                      Icons.star_border_rounded,
                      size: 50,
                    ),
                    title: Text(
                      link.title,
                      textScaleFactor: 1.5,
                      style: const TextStyle(fontStyle: FontStyle.normal),
                    ),
                    subtitle: Text(link.content),
                    onTap: () {
                      model.entityBeingEdited = link;
                      model.setColor(model.entityBeingEdited.color);
                      model.setStackIndex(1);
                    },
                    onLongPress: () async {
                      var url = 'https://${link.content}';
                      if (await canLaunch(url)) {
                        print(url);
                        await launch(
                          url,
                          forceWebView: true,
                          enableJavaScript: true,
                        );
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
