import AppKit
import CoreData
import Foundation

public final class ImageDescriptor: NSManagedObject {
    @NSManaged var startDate: String
    @NSManaged var endDate: String
    @NSManaged var imageUrl: URL
    @NSManaged var descriptionString: String
    @NSManaged var copyrightUrl: URL
    lazy var image: Image = {
        return Image(descriptor: self)
    }()
    
    static func == (lhs: ImageDescriptor, rhs: ImageDescriptor) -> Bool {
        return lhs.startDate == rhs.startDate
    }
    
    static func instantiate(from entry: DownloadManager.ImageEntry, in managedContext: NSManagedObjectContext) -> ImageDescriptor {
        let entity = NSEntityDescription.entity(forEntityName: "ImageDescriptor", in: managedContext)!
        let imageDescriptor = ImageDescriptor(entity: entity, insertInto: managedContext)
        imageDescriptor.startDate = entry.startdate
        imageDescriptor.endDate = entry.enddate
        imageDescriptor.imageUrl = URL(string: "https://www.bing.com" + entry.url.replacingOccurrences(of: "1920x1080", with: "UHD"))!
        imageDescriptor.descriptionString = entry.copyright
        imageDescriptor.copyrightUrl = URL(string: entry.copyrightlink)!
        return imageDescriptor
    }
}

extension ImageDescriptor: Comparable {
    public static func < (lhs: ImageDescriptor, rhs: ImageDescriptor) -> Bool {
        return lhs.startDate < rhs.startDate
    }
}
