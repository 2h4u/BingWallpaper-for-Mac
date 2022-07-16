import Cocoa

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "com.2h4u.BingWallpaper"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty
        
        if isRunning {
            terminate()
            return
        }
        
        DistributedNotificationCenter.default()
            .addObserver(
                self,
                selector: #selector(terminate),
                name: .killLauncher,
                object: mainAppIdentifier
            )
        
        var components = (Bundle.main.bundlePath as NSString).pathComponents
        components.removeLast()
        components.removeLast()
        components.removeLast()
        components.removeLast()
        
        let applicationURL = URL(fileURLWithPath: NSString.path(withComponents: components))
        NSWorkspace.shared.openApplication(at: applicationURL, configuration: NSWorkspace.OpenConfiguration())
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }
}
