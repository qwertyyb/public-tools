import Cocoa
import HotKey
import FlutterMacOS

public class HotkeyShortcutsPlugin: NSObject, FlutterPlugin {

  public static var channel: FlutterMethodChannel?

  fileprivate static func parse(_ string: String) -> KeyCombo {
    var keysList = string.split(separator: "+")
        
    let keyString = keysList.popLast()
    let key = Key(string: String(keyString!))!
    
    var modifiers: NSEvent.ModifierFlags = []
    for keyString in keysList {
        switch keyString {
        case "command":
            modifiers.insert(.command)
        case "control":
            modifiers.insert(.control)
        case "option":
            modifiers.insert(.option)
        case "shift":
            modifiers.insert(.shift)
        default: ()
        }
    }
    return KeyCombo(key: key, modifiers: modifiers)
  }

  fileprivate static var hotkeyMap = [String: HotKey]()

  fileprivate static func registerHotkey(label: String) {
    if (hotkeyMap[label] != nil) {
      return;
    }
    let keyCombo = parse(label)
    print("register hotkey: \(label)")
    let hotkey = HotKey(
      keyCombo: keyCombo,
      keyDownHandler: {
        print("onHotkey: \(label)")
        print("textInput")
        print(NSTextInputContext.current)
        channel?.invokeMethod("onHotkey", arguments: [label])
      },
      keyUpHandler: nil
    )
    hotkeyMap[label] = hotkey
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "hotkey_shortcuts", binaryMessenger: registrar.messenger)
    let instance = HotkeyShortcutsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    HotkeyShortcutsPlugin.channel = channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("native call")
    print(call)
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "registerHotkey":
      print("native register")
      HotkeyShortcutsPlugin.registerHotkey(label: (call.arguments as! [String])[0])
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
