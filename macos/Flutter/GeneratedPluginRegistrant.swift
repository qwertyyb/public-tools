//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import hotkey_shortcuts
import path_provider_macos
import shared_preferences_macos
import sqflite
import window_activator

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  HotkeyShortcutsPlugin.register(with: registry.registrar(forPlugin: "HotkeyShortcutsPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  WindowActivatorPlugin.register(with: registry.registrar(forPlugin: "WindowActivatorPlugin"))
}
