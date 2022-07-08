import Cocoa

class SettingsVc: NSViewController {
  private let settings = Settings()

  @IBOutlet var launchAtLoginCheckBox: NSButton!
  @IBOutlet var imagePathButton: NSButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    launchAtLoginCheckBox.state = settings.launchAtLogin ? .on : .off
    imagePathButton.title = settings.imageDownloadPath.path
  }

  @IBAction func launchAtLoginAction(_ sender: NSButton) {
    let newState = sender.state == .on
    settings.launchAtLogin = newState
  }

  @IBAction func imagePathButtonAction(_ sender: NSButton) {
    let dialog = NSOpenPanel()
    dialog.showsResizeIndicator = true
    dialog.showsHiddenFiles = false
    dialog.allowsMultipleSelection = false
    dialog.canChooseDirectories = true

    if dialog.runModal() == NSApplication.ModalResponse.OK {
      guard let result = dialog.url else { return }
      settings.imageDownloadPath = result
      imagePathButton.title = result.path
    }
  }
}
