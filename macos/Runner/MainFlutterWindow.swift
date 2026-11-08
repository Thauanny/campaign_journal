import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    // Cor de fundo até o primeiro quadro do Flutter (senão a janela fica preta).
    flutterViewController.backgroundColor = NSColor(red: 0xEF / 255.0, green: 0xF2 / 255.0, blue: 0xFF / 255.0, alpha: 1)
    self.backgroundColor = NSColor(red: 0xEF / 255.0, green: 0xF2 / 255.0, blue: 0xFF / 255.0, alpha: 1)
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
