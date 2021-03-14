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

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    super.awakeFromNib()
    
    let winW = CGFloat(720.0)
    let winH = CGFloat(60.0)
    let frame = NSScreen.main?.frame ?? NSRect.zero
    let x = (frame.width - winW) / 2 + frame.minX
    let y = frame.height * 3 / 4 + frame.minY

    let origin = NSPoint(x: x, y: y)
    let windowFrame = NSRect(origin: origin, size: CGSize(width: winW, height: winH))
    self.setFrame(windowFrame, display: true)
  }
}
