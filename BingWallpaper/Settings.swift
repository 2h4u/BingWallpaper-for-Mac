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

  var imageDownloadPath: URL {
    get {
      return defaults.url(forKey: Settings.IMAGE_DOWNLOAD_PATH) ?? FileHandler.defaultBingWallpaperDirectory()
    }
    set {
      defaults.set(newValue, forKey: Settings.IMAGE_DOWNLOAD_PATH)
    }
  }

  var lastUpdate: Date {
    get {
      return defaults.object(forKey: Settings.LAST_UPDATE) as? Date ?? Date.distantPast
    }
    set {
      defaults.set(newValue, forKey: Settings.LAST_UPDATE)
    }
  }

  private static let SM_LOGIN_ENABLED = "SM_LOGIN_ENABLED"
  private static let IMAGE_DOWNLOAD_PATH = "IMAGE_DOWNLOAD_PATH"
  private static let LAST_UPDATE = "LAST_UPDATE"
}
