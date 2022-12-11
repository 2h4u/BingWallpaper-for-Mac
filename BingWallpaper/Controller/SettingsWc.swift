import Cocoa

class SettingsWc: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title = "BingWallpaper v\(AppUpdateManager.currentAppVersion())"
        self.window?.titleVisibility = .visible
    }
    
    static func instance() -> SettingsWc {
        let mainStoryboard = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
        return mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(String(describing: self))) as! SettingsWc
    }
}
