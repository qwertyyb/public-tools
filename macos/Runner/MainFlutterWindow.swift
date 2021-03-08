import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    
    override var canBecomeKey: Bool {
        get { return true }
    }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    super.awakeFromNib()
    self.styleMask = [.borderless, .fullSizeContentView]
  }
}
