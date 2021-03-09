import Cocoa
import HotKey
import FlutterMacOS


var query: NSMetadataQuery?
func getInstalledApps(callback: @escaping ([[String: String]]) -> ()) {
    query = NSMetadataQuery()
    query?.stop()
    let predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
    query?.predicate = predicate
    query?.searchScopes = ["/Applications"]
    var observer: Any?
    observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil, queue: nil) { (notification) in
        var list = [[String: String]]()
        for i in 0 ..< query!.resultCount {
            guard let item = query?.result(at: i) as? NSMetadataItem else { continue }
            let name = item.value(forAttribute: kMDItemDisplayName as String)
            let path = item.value(forAttribute: kMDItemPath as String)
            list.append([
                "name": name as! String,
                "path": path as! String
            ])
        }
        callback(list)
        NotificationCenter.default.removeObserver(observer!)
    }
    query?.start()
}

@available(OSX 10.12, *)
public class HotkeyShortcutsPlugin: NSObject, FlutterPlugin {

  public static var channel: FlutterMethodChannel?

  public static var windowPosition: NSPoint = NSPoint.zero
  public static var windowFrame: NSRect = NSRect.zero

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
        channel?.invokeMethod("onHotkey", arguments: [label])
      },
      keyUpHandler: nil
    )
    hotkeyMap[label] = hotkey
  }

  /**
    * 检查粘贴权限
    * @param {Bool} prompt 如果没有权限，是否弹出询问授权弹窗
    * @returns {Bool} 是否授权
    */
  fileprivate static func checkAccess(prompt: Bool = false) -> Bool {
    let checkOptionPromptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    let opts = [checkOptionPromptKey: prompt] as CFDictionary
    return AXIsProcessTrustedWithOptions(opts)
  }

  fileprivate static func triggerPaste() {
    if !HotkeyShortcutsPlugin.checkAccess() {
      let _ = HotkeyShortcutsPlugin.checkAccess(prompt: true)
    }
    NSApp.hide(nil)
    
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
        // Based on https://github.com/Clipy/Clipy/blob/develop/Clipy/Sources/Services/PasteService.swift.
    
      let vCode = UInt16(0x09)
      let source = CGEventSource(stateID: .combinedSessionState)
      // Disable local keyboard events while pasting
      source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
      
      let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: true)
      let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: false)
      keyVDown?.flags = .maskCommand
      keyVUp?.flags = .maskCommand
      keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
      keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "hotkey_shortcuts", binaryMessenger: registrar.messenger)
    let instance = HotkeyShortcutsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    HotkeyShortcutsPlugin.channel = channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("native call", call.method, call.arguments as Any)
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
      break;
    case "registerHotkey":
      HotkeyShortcutsPlugin.registerHotkey(label: (call.arguments as! [String])[0])
      result(true)
      break;
    case "updateWindowSize":
      let args = call.arguments as! [String:Double]
      let size = NSSize(width: args["width"]!, height: args["height"]!)
      NSApp.keyWindow?.setContentSize(size)
      result(true)
      break;
    case "recordWindowPosition":
      HotkeyShortcutsPlugin.windowPosition = NSEvent.mouseLocation
      HotkeyShortcutsPlugin.windowFrame = NSApp.keyWindow!.frame
      result(true)
      break;
    case "updateWindowPosition":
      let dx = NSEvent.mouseLocation.x - HotkeyShortcutsPlugin.windowPosition.x
      let dy = NSEvent.mouseLocation.y - HotkeyShortcutsPlugin.windowPosition.y
      let rect = HotkeyShortcutsPlugin.windowFrame.offsetBy(dx: dx, dy: dy)
      NSApp.keyWindow?.setFrame(rect, display: true)
      result(true)
      break;
    case "pasteToFrontestApp":
      HotkeyShortcutsPlugin.triggerPaste()
      result(true)
      break;
    case "getInstalledApps":
        getInstalledApps(callback: result)
        break;
    default:
        print(FlutterMethodNotImplemented)
//      result(FlutterMethodNotImplemented)
    }
  }
}
