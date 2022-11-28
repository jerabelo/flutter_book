import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_book/contacts/ContactsDBWorker.dart';
import 'package:flutter_book/contacts/ContactsModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'Avatar.dart';
import 'package:flutter_book/utils.dart' as utils;

class ContactsEntry extends StatelessWidget with Avatar {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();

  int id;
  void _save(BuildContext context, ContactModel contactsModel) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    //entityList.contains(model.entityList)

    if (!contactsModel.entityList.contains(contactsModel.entityList)) {
      contactsModel.entityList.add(contactsModel.entityBeingEdited);
    }

    if (contactsModel.entityBeingEdited.id == null) {
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }
    File avatarFile = File(join(utils.docsDir.path, "avatar"));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }
    contactsModel.loadData(ContactsDBWorker.db);
    contactsModel.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Contact saved!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactModel>(
        builder: (BuildContext context, Widget inChild, ContactModel inModel) {
          File avatarFile = File(join(Avatar.docsDir.path, "avatar"));
          if (avatarFile.existsSync() == false) {
            if (inModel.entityBeingEdited != null &&
                inModel.entityBeingEdited != null) {
              avatarFile = File(join(
                  Avatar.docsDir.path, inModel.entityBeingEdited.toString()));
            }
          }
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  ElevatedButton(
                    child: Text('cancel'),
                    onPressed: () {
                      File avatarFile =
                          File(join(utils.docsDir.path, 'avatar'));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    child: Text('save'),
                    onPressed: () {
                      _save(context, inModel);
                    },
                  )
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    title: avatarFile.existsSync()
                        ? Image.memory(
                            Uint8List.fromList(avatarFile.readAsBytesSync()),
                            alignment: Alignment.center,
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain)
                        : Text('No avatar image for this container'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectAvatar(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: 'Name'),
                      controller: _nameEditingController,
                      validator: (String inValue) {
                        if (inValue.length == 0) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(hintText: "Phone"),
                        controller: _phoneEditingController),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(hintText: "Email"),
                        controller: _emailEditingController),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text('Birthday'),
                    subtitle: Text(contactsModel.chosenDate == null
                        ? ""
                        : contactsModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                            context,
                            contactsModel,
                            contactsModel.entityBeingEdited.birthday);
                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited.birthday = chosenDate;
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectAvatar(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
              child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Take a picture"),
                onTap: () async {
                  // ignore: deprecated_member_use
                  var cameraImage =
                      // ignore: deprecated_member_use
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  if (cameraImage != null) {
                    cameraImage.copySync(avatarTempFileName());
                    contactsModel.triggerRebuild();
                  }
                  Navigator.of(dialogContext).pop();
                },
              ),
              const Divider(),
              GestureDetector(
                child: Text('Select From Gallery'),
                onTap: () async {
                  var galleryImage =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  if (galleryImage != null) {
                    galleryImage.copySync(
                      join(utils.docsDir.path, "avatar"),
                    );
                    contactsModel.triggerRebuild();
                  }
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          )),
        );
      },
    );
  }
}
