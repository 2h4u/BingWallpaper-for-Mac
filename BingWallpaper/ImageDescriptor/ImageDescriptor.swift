import AppKit
import CoreData
import Foundation

public final class ImageDescriptor: NSManagedObject {
  @NSManaged var startDate: String
  @NSManaged var endDate: String
  @NSManaged var imageUrl: URL
  @NSManaged var descriptionString: String
  @NSManaged var copyrightUrl: URL
  var image: NSImage?

//  func imageUrl() -> URL {
//    return URL(string: "https://www.bing.com" + url.replacingOccurrences(of: "1920x1080", with: "UHD"))!
//  }
//
//  func copyrightUrl() -> URL {
//    return URL(string: copyrightLink)!
//  }

  static func == (lhs: ImageDescriptor, rhs: ImageDescriptor) -> Bool {
    return lhs.startDate == rhs.startDate
  }
}
