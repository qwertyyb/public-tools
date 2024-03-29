//
//  App.swift
//  Runner
//
//  Created by 虚幻 on 2021/11/28.
//

import Foundation
import FlutterMacOS
import hotkey_manager
import HotKey

public extension String {
    func isIncludeChinese() -> Bool {
        for ch in self.unicodeScalars {
            // 中文字符范围：0x4e00 ~ 0x9fff
            if (0x4e00 < ch.value  && ch.value < 0x9fff) {
                return true
            }
        }
        return false
    }
    
    func transformToPinyin() -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        // 转换为带音标的拼音
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false);
        // 去掉音标
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false);
        let pinyin = stringRef as String;
        return pinyin
    }

}

extension NSBitmapImageRep {
    func png() -> Data? {
        representation(using: .png, properties: [:])
    }
}

extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
    func png() -> Data? { tiffRepresentation?.bitmap?.png() }

    func resizedForFile(to size: Int) -> NSImage {
        let newSizeInt = size / Int(NSScreen.main?.backingScaleFactor ?? 1)
        let newSize = CGSize(width: newSizeInt, height: newSizeInt)

        let image = NSImage(size: newSize)
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high

        draw(
            in: CGRect(origin: .zero, size: newSize),
            from: .zero,
            operation: .copy,
            fraction: 1
        )

        image.unlockFocus()
        return image
    }
}

public class AppService: NSObject, PBCService {
    public func readClipboardData(forType: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> FlutterStandardTypedData? {
        if let data = NSPasteboard.general.data(forType: .init(rawValue: forType)) {
            return FlutterStandardTypedData(bytes: data)
        }
        return nil
    }
    
    public func setClipboardDataData(_ data: FlutterStandardTypedData, dataType: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
        NSPasteboard.general.declareTypes([.init(rawValue: dataType)], owner: nil)
        let success = NSPasteboard.general.setData(data.data, forType: .init(rawValue: dataType));
        return NSNumber(booleanLiteral: success)
    }
  
    private func checkAccess(prompt: Bool = false) -> Bool {
      let checkOptionPromptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
      let opts = [checkOptionPromptKey: prompt] as CFDictionary
      return AXIsProcessTrustedWithOptions(opts)
    }

    public func pasteToFrontestAppWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if !checkAccess() {
          let _ = checkAccess(prompt: true)
        }
        NSApp.hide(nil)
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer) in
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
    
    public func getInstalledApplicationList(completion: @escaping ([PBCInstalledApplication]?, FlutterError?) -> Void) {
        let query = NSMetadataQuery()
        query.stop()
        let predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
        query.predicate = predicate
        query.searchScopes = ["/Applications", "/System/Applications", "/System/Library/CoreServices/Applications"]
        var observer: Any?
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil, queue: nil) { (notification) in
            var list = [PBCInstalledApplication]()
            for i in 0 ..< query.resultCount {
                guard let item = query.result(at: i) as? NSMetadataItem else { continue }
                let name = (item.value(forAttribute: kMDItemDisplayName as String) as! String)
                    .replacingOccurrences(of: ".app", with: "")
                let path = item.value(forAttribute: kMDItemPath as String) as! String;
                var icon = NSWorkspace.shared.icon(forFile: path).resizedForFile(to: 64).png()?.base64EncodedString()
                if (icon != nil) {
                    icon = "base64:" + icon!
                } else {
                    icon = ""
                }
                let app = PBCInstalledApplication()
                app.name = name
                app.path = path
                app.icon = icon
                app.pinyin = name.transformToPinyin()
                list.append(app)
            }
            NotificationCenter.default.removeObserver(observer!)
            completion(list, nil);
        }
        query.start()
    }
    public func hideAppWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        NSApp.hide(nil)
    }
}
