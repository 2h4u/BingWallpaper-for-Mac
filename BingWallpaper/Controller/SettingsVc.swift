import Cocoa

protocol SettingsVcDelegate: AnyObject {
    func showMenuBarIcon()
    func hideMenuBarIcon()
}

class SettingsVc: NSViewController {
    @IBOutlet var launchAtLoginCheckBox: NSButton!
    @IBOutlet weak var hideMenuBarIconCheckBox: NSButton!
    @IBOutlet var imagePathButton: NSButton!
    @IBOutlet weak var keepImagesSlider: NSSlider!
    
    private let settings = Settings()
    weak var delegate: SettingsVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launchAtLoginCheckBox.state = settings.launchAtLogin ? .on : .off
        hideMenuBarIconCheckBox.state = settings.hideMenuBarIcon ? .on : .off
        imagePathButton.title = settings.imageDownloadPath.path
        imagePathButton.toolTip = imagePathButton.title
        keepImagesSlider.integerValue = settings.keepImageDuration
    }
    
    @IBAction func launchAtLoginAction(_ sender: NSButton) {
        let newState = sender.state == .on
        settings.launchAtLogin = newState
    }
    
    @IBAction func hideMenuBarIconCheckBoxAction(_ sender: NSButton) {
        let newState = sender.state == .on
        settings.hideMenuBarIcon = newState
        if newState == true {
            delegate?.hideMenuBarIcon()
        } else {
            delegate?.showMenuBarIcon()
        }
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
            imagePathButton.toolTip = result.path
        }
    }
    
    @IBAction func keepImagesSliderAction(_ sender: NSSlider) {
        settings.keepImageDuration = sender.integerValue
    }
}

enum KeepImageDuration: Int {
    case five
    case ten
    case fifty
    case onehundred
    case infinite
}
