import Foundation
import ServiceManagement

class Settings {

  private let defaults = UserDefaults.standard

  var test: Bool {
    get {
      return defaults.bool(forKey: Settings.SM_LOGIN_ENABLED)
    }
    set {
      SMLoginItemSetEnabled(Bundle.main.bundleURL.path as CFString, newValue)
      defaults.set(newValue, forKey: Settings.SM_LOGIN_ENABLED)
    }
  }

  private static let SM_LOGIN_ENABLED = "1"
//
//  class var isStartAtLoginEnabled: Bool {
//    get {
//      let appPath = Bundle.main.bundlePath
//
//      var result = false
//
//      if let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)?.takeRetainedValue() {
//        let loginItemsArray = LSSharedFileListCopySnapshot(loginItems, nil)?.takeRetainedValue() as! [LSSharedFileListItem]
//
//        for item in loginItemsArray {
//          guard let url = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?.takeRetainedValue() as NSURL?
//          else {
//            continue
//          }
//
//          if url.path == appPath {
//            result = true
//          }
//        }
//      }
//
//      return result
//    }
//
//    set {
//      let appURL = Bundle.main.bundleURL
//
//      if let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)?.takeRetainedValue() {
//        if newValue {
//          let newList = LSSharedFileListInsertItemURL(loginItems,
//                                        kLSSharedFileListItemBeforeFirst.takeRetainedValue(), nil, nil,
//                                        appURL as CFURL, nil, nil)
//
//          print(newList)
//        }
//        else {
//          let loginItemsArray = LSSharedFileListCopySnapshot(loginItems, nil)?.takeRetainedValue() as! [LSSharedFileListItem]
//
//          for item in loginItemsArray {
//            if let url = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?.takeRetainedValue() as URL? {
//              if appURL.absoluteURL == url.absoluteURL {
//                LSSharedFileListItemRemove(loginItems, item)
//              }
//            }
//          }
//        }
//      }
//    }
//  }
}
