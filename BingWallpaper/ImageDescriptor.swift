import AppKit
import Foundation

struct ImageDescriptor: Equatable {
  let startDate: String
  let endDate: String
  let url: String
  let description: String
  let copyrightLink: String
  var image: NSImage? = nil

  func imageUrl() -> URL {
    return URL(string: "https://www.bing.com" + url.replacingOccurrences(of: "1920x1080", with: "UHD"))!
  }

  func copyrightUrl() -> URL {
    return URL(string: copyrightLink)!
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.startDate == rhs.startDate
  }
}
