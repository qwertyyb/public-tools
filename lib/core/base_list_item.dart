class BaseListItem {
  String id;
  String subtitle;
  String title;
  String? description;
  String? icon;

  BaseListItem(
      {required this.subtitle,
      required this.title,
      this.description,
      this.icon,
      required this.id});

  BaseListItem.fromJson(Map<String, dynamic> json)
      : subtitle = json['subtitle'],
        title = json['title'],
        description = json['description'],
        icon = json['icon'],
        id = json['id'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subtitle'] = this.subtitle;
    data['title'] = this.title;
    data['description'] = this.description;
    data['icon'] = this.icon;
    data['id'] = this.id;
    return data;
  }
}
