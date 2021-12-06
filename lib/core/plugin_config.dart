class PluginConfig {
  String name;
  String title;
  String description;
  String icon;
  String main;
  List<Command> commands;

  PluginConfig(
      {this.name, this.title, this.description, this.icon, this.commands});

  PluginConfig.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'];
    main = json['main'];
    if (json['commands'] != null) {
      commands = [];
      json['commands'].forEach((v) {
        commands.add(new Command.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['title'] = this.title;
    data['description'] = this.description;
    data['icon'] = this.icon;
    data['main'] = this.main;
    if (this.commands != null) {
      data['commands'] = this.commands.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Command {
  List<String> keywords;
  String name;
  String title;
  String description;
  String mode;

  Command({this.keywords, this.name, this.title, this.description, this.mode});

  Command.fromJson(Map<String, dynamic> json) {
    keywords = json['keywords'].cast<String>();
    name = json['name'];
    title = json['title'];
    description = json['description'];
    mode = json['mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['keywords'] = this.keywords;
    data['name'] = this.name;
    data['title'] = this.title;
    data['description'] = this.description;
    data['mode'] = this.mode;
    return data;
  }
}
