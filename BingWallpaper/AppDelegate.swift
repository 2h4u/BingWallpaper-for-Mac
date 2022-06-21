import Cocoa
import ServiceManagement

extension Notification.Name {
  static let killLauncher = Notification.Name("killLauncher")
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private let updateManager = UpdateManager()
  private let menuController = MenuController()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    menuController.createMenu()
    FileHandler.createWallpaperFolderIfNeeded()
    updateManager.start()
    updateManager.delegate = menuController
    killBingWallpaperHelperIfNeeded()
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  fileprivate func killBingWallpaperHelperIfNeeded() {
    let launcherAppId = "com.2h4u.BingWallpaperHelper"
    let runningApps = NSWorkspace.shared.runningApplications
    let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty

    if isRunning {
      DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
    }
  }
}
