import "../BaseModel.dart";

ContactModel contactsModel = ContactModel();

class Contact {
  int id;
  String name;
  String phone;
  String email;
  String birthday;

  @override
  String toString() {
    return "{ id=$id, name=$name, phone=$phone, email=$email, birthday=$birthday }";
  }
}

class ContactModel extends BaseModel<Contact> with DateSelection {
  void setBirthday(String date) {
    super.setChosenDate(date);
  }

  void triggerRebuild() {
    notifyListeners();
  }
}
