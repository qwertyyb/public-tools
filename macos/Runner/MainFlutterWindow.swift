import Cocoa
import FlutterMacOS

class BlurryContainerViewController: NSViewController {
  let flutterViewController = FlutterViewController()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  override func loadView() {
    let blurView = NSVisualEffectView()
    blurView.autoresizingMask = [.width, .height]
    blurView.blendingMode = .behindWindow
    blurView.state = .active
    if #available(macOS 10.14, *) {
      blurView.material = .underWindowBackground
    }
    self.view = blurView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.addChild(flutterViewController)

    flutterViewController.view.frame = self.view.bounds
    flutterViewController.view.autoresizingMask = [.width, .height]
    self.view.addSubview(flutterViewController.view)
  }
}


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
    let blurryContainerViewController = BlurryContainerViewController()
    self.contentViewController = blurryContainerViewController
    self.styleMask = [.borderless, .fullSizeContentView]
    self.eventChannel = FlutterEventChannel(name: "events-listener", binaryMessenger: blurryContainerViewController.flutterViewController.engine.binaryMessenger)
    self.eventChannel?.setStreamHandler(self)
    
    NotificationCenter.default.addObserver(forName: NSApplication.didHideNotification, object: NSApp, queue: nil) { notification in
        self.events?("DID_HIDE")
    }
    
    NotificationCenter.default.addObserver(forName: NSApplication.willUnhideNotification, object: NSApp, queue: nil) { notification in
        self.events?("WILL_UNHIDE")
    }

    RegisterGeneratedPlugins(registry: blurryContainerViewController.flutterViewController)
    
    PBCServiceSetup(blurryContainerViewController.flutterViewController.engine.binaryMessenger, AppService())
    
    super.awakeFromNib()
    let winW = CGFloat(720.0)
    let winH = CGFloat(480.0)
    let frame = NSScreen.main?.frame ?? NSRect.zero
    let x = (frame.width - winW) / 2 + frame.minX
    let y = frame.height * 3 / 4 + frame.minY

    let origin = NSPoint(x: x, y: y)
    let windowFrame = NSRect(origin: origin, size: CGSize(width: winW, height: winH))
    isOpaque = false
    backgroundColor = .clear
    self.setFrame(windowFrame, display: true)
  }
}
