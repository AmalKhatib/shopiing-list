
class Item {
  String? id;
  String? name;
  bool obtained = false;

  Item({this.id, required this.name, this.obtained = false});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    obtained = json['obtained'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['obtained'] = this.obtained;
    return data;
  }
}
