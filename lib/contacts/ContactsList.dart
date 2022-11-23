import 'dart:io';
import 'package:intl/intl.dart';
import 'ContactsModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'ContactsDBWorker.dart';
import 'Avatar.dart';
import 'package:flutter_book/utils.dart' as utils;

class ContactList extends StatelessWidget with Avatar {
  Future _deleteContact(BuildContext inContext, Contact inContact) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Delete Contact"),
          content: Text("Are you sure you want to delete ${inContact.name}?"),
          actions: [
            FloatingActionButton(
              child: Text('cancel'),
              onPressed: () {
                Navigator.of(inAlertContext).pop();
              },
            ),
            FloatingActionButton(
              child: Text('Delete'),
              onPressed: () async {
                File avatarFile =
                    File(join(utils.docsDir.path, inContact.id.toString()));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                await ContactsDBWorker.db.delete(inContact.id);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Contact deleted"),
                  ),
                );
                contactsModel.loadData(ContactsDBWorker.db);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactModel>(
        builder: (BuildContext context, Widget inChild, ContactModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                File avatarFile = File(join(utils.docsDir.path, "avatar"));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = contactsModel.entityList[index];
                File avatarFile = File(avatarFileName(contact.id));
                bool avatarFileExists = avatarFile.existsSync();
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      Slidable(
                        actionPane: SlidableScrollActionPane(),
                        actionExtentRatio: .25,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            backgroundImage:
                                avatarFileExists ? FileImage(avatarFile) : null,
                            child: avatarFileExists
                                ? null
                                : Text(
                                    //contact.name.substring(0, 1).toUpperCase(),
                                    contact.name = 'i cant change this'
                                        .substring(0, 1)
                                        .toUpperCase(),
                                  ),
                          ),
                          title: Text("${contact.name}"),
                          subtitle: contact.phone == null
                              ? null
                              : Text("${contact.phone}"),
                          //this is where deleting takes place
                          onTap: () async {
                            File avatarFile =
                                File(join(utils.docsDir.path, "avatar"));
                            if (avatarFile.existsSync()) {
                              avatarFile.deleteSync();
                            }
                            contactsModel.entityBeingEdited =
                                await ContactsDBWorker.db.get(contact.id);
                            if (contactsModel.entityBeingEdited.birthday ==
                                null) {
                              contactsModel.setChosenDate(null);
                            } else {
                              List dateParts = contactsModel
                                  .entityBeingEdited.birthday
                                  .split(",");
                              DateTime birthday = DateTime(
                                  int.parse(dateParts[0]),
                                  int.parse(dateParts[1]),
                                  int.parse(dateParts[2]));
                              contactsModel.setChosenDate(
                                DateFormat.yMMMMd("en_US")
                                    .format(birthday.toLocal()),
                              );
                            }
                            contactsModel.setStackIndex(1);
                          },
                        ),
                        secondaryActions: [
                          IconSlideAction(
                            caption: "Delete",
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => _deleteContact(context, contact),
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
