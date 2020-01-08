class User {
  String _name;
  String _email;
  String _password;
  String _idUser;
  bool _adm;

  User();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "name": this.name,
      "email": this.email,
      "adm": this.adm
    };
    return map;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }

  bool get adm => _adm;

  set adm(bool value) {
    _adm = value;
  }


}