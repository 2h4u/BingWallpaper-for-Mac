import Foundation
import AppKit

struct ImageDescriptor {
  let startDate: String
  let endDate: String
  let url: String
  let description: String
  var image: NSImage? = nil

  func imageUrl() -> URL {
    return URL(string: "https://www.bing.com" + url.replacingOccurrences(of: "1920x1080", with: "UHD"))!
  }

  mutating func deleteImageFromMemory() {
    image = nil
  }
}
