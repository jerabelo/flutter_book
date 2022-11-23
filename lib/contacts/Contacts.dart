import 'dart:io';
import 'package:flutter_book/contacts/ContactsEntry.dart';
import 'package:flutter_book/contacts/ContactsModel.dart';
import 'package:flutter_book/contacts/ContactsList.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsDBWorker.dart';

class Contacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactModel>(
        builder: (BuildContext context, Widget child, ContactModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[ContactList(), ContactsEntry()],
          );
        },
      ),
    );
  }
}
