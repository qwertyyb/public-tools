import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, FlutterStreamHandler {
    private var events: FlutterEventSink?;
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.events = nil
        return nil
    }
    
    
    private var eventChannel: FlutterEventChannel? = nil;
    
    override var canBecomeKey: Bool {
        get { return true }
    }
  
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    self.contentViewController = flutterViewController
    self.styleMask = [.borderless, .fullSizeContentView]
    self.eventChannel = FlutterEventChannel(name: "events-listener", binaryMessenger: flutterViewController.engine.binaryMessenger)
    self.eventChannel?.setStreamHandler(self)
    
    NotificationCenter.default.addObserver(forName: NSApplication.didHideNotification, object: NSApp, queue: nil) { notification in
        self.events?("DID_HIDE")
    }
    
    NotificationCenter.default.addObserver(forName: NSApplication.willUnhideNotification, object: NSApp, queue: nil) { notification in
        self.events?("WILL_UNHIDE")
    }

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    PBCServiceSetup(flutterViewController.engine.binaryMessenger, AppService())
    
    super.awakeFromNib()
    
    let winW = CGFloat(720.0)
    let winH = CGFloat(480.0)
    let frame = NSScreen.main?.frame ?? NSRect.zero
    let x = (frame.width - winW) / 2 + frame.minX
    let y = frame.height * 3 / 4 + frame.minY

    let origin = NSPoint(x: x, y: y)
    let windowFrame = NSRect(origin: origin, size: CGSize(width: winW, height: winH))
    isOpaque = false
    backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
    self.setFrame(windowFrame, display: true)
  }
}
