import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';

void main() {
  const MethodChannel channel = MethodChannel('hotkey_shortcuts');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HotkeyShortcuts.platformVersion, '42');
  });
}
