import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }

  // Stop macOS system beep but still forward keys to Flutter
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    // Tell macOS “this key was handled”
    return true
  }

  override func sendEvent(_ event: NSEvent) {
    // Forward ALL keyboard events to Flutter
    super.sendEvent(event)
  }
}
