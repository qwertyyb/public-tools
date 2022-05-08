import 'base_list_item.dart';
import 'plugin_command.dart';

final void Function() _defaultOnRegister = () {};

class Plugin extends BaseListItem {
  List<PluginCommand> commands = [];

  final void Function() onRegister;

  Plugin({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required String icon,
    required this.commands,
    void Function()? onRegister,
  })  : onRegister = onRegister ?? _defaultOnRegister,
        super(
          id: id,
          subtitle: subtitle,
          title: title,
          description: description,
          icon: icon,
        );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['commands'] = this.commands.map((v) => v.toJson()).toList();
    return data;
  }
}

class PluginResult<T> {
  Plugin plugin;
  double point = 0;
  T value;

  PluginResult({required this.plugin, required this.value, this.point = 0});
}
