import Cocoa

class SettingsVc: NSViewController {
  private let settings = Settings()

  @IBOutlet var launchAtLoginCheckBox: NSButton!
  @IBOutlet var imagePathButton: NSButton!
  @IBOutlet weak var keepImagesSlider: NSSlider!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    launchAtLoginCheckBox.state = settings.launchAtLogin ? .on : .off
    imagePathButton.title = settings.imageDownloadPath.path
    // TODO: set keepImagesSlider to corresponding settings value
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
  
  @IBAction func keepImagesSliderAction(_ sender: NSSlider) {
    // TODO: update settings value
  }
}
