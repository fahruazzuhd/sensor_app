class Task {
  int? id;
  String? name;
  DateTime? dateTime;

  Task({this.id, this.name, this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'])
          : null,
    );
  }
}
