class Users{
  int? id;
  String? email;
  String? password;

  Users({this.email, this.password});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }
    map['email'] = email;
    map['password'] = password;

    return map;
  }

  Users.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.email = map['email'];
    this.password = map['password'];
  }
}