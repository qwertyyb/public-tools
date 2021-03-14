import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  override func applicationDidFinishLaunching(_ notification: Notification) {
    print("hhhhhh")
//    super.applicationDidFinishLaunching(notification)
    statusItem.button?.image = NSImage(named: "StatusIcon")
    print("bbbbb")
    print(statusItem.button)
    statusItem.menu = NSApp.mainMenu?.item(at: 0)?.submenu
  }
}
