import Cocoa
import Foundation

class ImageDescriptionHandler {
    static func downloadImage(descriptor: ImageDescriptor) async -> NSImage? {
        return await DownloadManager.downloadImage(from: descriptor.imageUrl)
    }
    
    static func imageDescriptorsFromDb() -> [ImageDescriptor] {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ImageDescriptor>(entityName: "ImageDescriptor")
        
        do {
            let descriptors = try managedContext.fetch(fetchRequest)
            return descriptors
                .map { descriptor in
                    descriptor.image = loadImageFromDisk(descriptor: descriptor)
                    return descriptor
                }
                .sorted()
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    @MainActor 
    static func updateImageDescriptors(from json: [String: Any]) -> [ImageDescriptor] {
        guard json.isEmpty == false,
              let images = json["images"] as? [[String: Any]]
        else {
            return []
        }
        
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let preservedStartDates = ImageDescriptionHandler
            .imageDescriptorsFromDb()
            .map { $0.startDate }
        
        let imageDescriptors = images
            .filter { image in preservedStartDates.contains(image["startdate"] as! String) == false }
            .map { image -> ImageDescriptor in
                let entity = NSEntityDescription.entity(forEntityName: "ImageDescriptor", in: managedContext)!
                let imageDescriptor = ImageDescriptor(entity: entity, insertInto: managedContext)
                imageDescriptor.startDate = image["startdate"] as! String
                imageDescriptor.endDate = image["enddate"] as! String
                imageDescriptor.imageUrl = URL(string: "https://www.bing.com" + (image["url"] as! String).replacingOccurrences(of: "1920x1080", with: "UHD"))!
                imageDescriptor.descriptionString = image["copyright"] as! String
                imageDescriptor.copyrightUrl = URL(string: image["copyrightlink"] as! String)!
                return imageDescriptor
            }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return imageDescriptors
    }
    
    static func downloadNewestImageDescriptors(maxNumberOfImages: Int) async -> [ImageDescriptor] {
        let json = await DownloadManager.downloadJson(numberOfImages: maxNumberOfImages)
        return await ImageDescriptionHandler.updateImageDescriptors(from: json)
    }
    
    static func imageDownloadPath(descriptor: ImageDescriptor) -> URL {
        return FileHandler.defaultBingWallpaperDirectory().appendingPathComponent(descriptor.startDate + ".jpg")
    }
    
    static func saveToDisk(descriptor: ImageDescriptor) {
        guard let image = descriptor.image else { return }
        FileHandler.saveImageToDisk(image: image, toUrl: imageDownloadPath(descriptor: descriptor))
    }
    
    static func isSavedToDisk(descriptor: ImageDescriptor) -> Bool {
        let imagePath = FileHandler.defaultBingWallpaperDirectory() + "/" + descriptor.startDate + ".jpg"
        return FileManager.default.fileExists(atPath: imagePath)
    }
    
    static func loadImageFromDisk(descriptor: ImageDescriptor) -> NSImage? {
        let imageUrl = imageDownloadPath(descriptor: descriptor)
        do {
            let imageData = try Data(contentsOf: imageUrl)
            return NSImage(data: imageData)
        } catch {
            print("Failed to read image from path: \(imageUrl) with error: \(error)")
        }
        
        return nil
    }
    
    static func newest(descriptors: [ImageDescriptor]) -> ImageDescriptor? {
        return descriptors.sorted(by: { desc1, desc2 in desc1.startDate > desc2.startDate }).first
    }
    
    static func deleteOldDescriptors(oldestDateStringToKeep: String) {
        assert(Thread.isMainThread)
        
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        imageDescriptorsFromDb()
            .filter { $0.startDate <= oldestDateStringToKeep }
            .forEach { managedContext.delete($0) }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
