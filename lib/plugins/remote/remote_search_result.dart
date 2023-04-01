import '../../core/plugin_command.dart';

class RemoteSearchResult extends SearchResult {
  Map<String, dynamic> raw;

  RemoteSearchResult.fromJson(this.raw) : super.fromJson(raw);
}
