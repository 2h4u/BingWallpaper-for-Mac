import Foundation
import ServiceManagement

class Settings {
  private let defaults = UserDefaults.standard

  var launchAtLogin: Bool {
    get {
      return defaults.bool(forKey: Settings.SM_LOGIN_ENABLED)
    }
    set {
      SMLoginItemSetEnabled("com.2h4u.BingWallpaperHelper" as CFString, newValue)
      defaults.set(newValue, forKey: Settings.SM_LOGIN_ENABLED)
    }
  }

  private static let SM_LOGIN_ENABLED = "SM_LOGIN_ENABLED"
}
