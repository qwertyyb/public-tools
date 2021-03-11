import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    
    override var canBecomeKey: Bool {
        get { return true }
    }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    self.contentViewController = flutterViewController
    self.styleMask = [.borderless, .fullSizeContentView]
    
    let origin = NSPoint(x: self.frame.origin.x, y: 100)
    let windowFrame = NSRect(origin: origin, size: CGSize(width: 720, height: 60))
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    super.awakeFromNib()
  }
}
