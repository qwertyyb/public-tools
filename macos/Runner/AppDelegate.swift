import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  @IBAction func showAbout(_ sender: NSMenuItem) {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.orderFrontStandardAboutPanel(sender)
  }
  //  切换显示隐藏窗口
  @IBAction func toggleApp(_ sender: Any!) {
    if(NSApp.isActive) {
      NSApp.hide(sender)
    } else {
      NSApp.activate(ignoringOtherApps: true)
    }
  }
  override func applicationDidFinishLaunching(_ notification: Notification) {
    statusItem.button?.image = NSImage(named: "StatusIcon")
    statusItem.menu = NSApp.mainMenu?.item(at: 0)?.submenu
  }
  override func applicationWillResignActive(_ notification: Notification) {
    NSApp.hide(nil)
  }
}
