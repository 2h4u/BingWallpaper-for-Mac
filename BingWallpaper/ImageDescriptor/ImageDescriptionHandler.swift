import Cocoa
import Foundation

class ImageDescriptionHandler {
  static func downloadImage(descriptor: ImageDescriptorOld) -> NSImage? {
    return DownloadManager.downloadImage(from: descriptor.imageUrl())
  }

  static func getImageDescriptors(json: [String: Any]) -> [ImageDescriptor] {
    guard json.isEmpty == false,
          let images = json["images"] as? [[String: Any]]
    else {
      return []
    }

    guard let appDelegate =
      NSApplication.shared.delegate as? AppDelegate
    else {
      return []
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    let imageDescriptors = images.map { image -> ImageDescriptor in
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

  static func getImageDescriptors(json: [String: Any]) -> [ImageDescriptorOld] {
    guard json.isEmpty == false,
          let images = json["images"] as? [[String: Any]]
    else {
      return []
    }

    let imageDescriptors = images.map { image -> ImageDescriptorOld in
      ImageDescriptorOld(startDate: image["startdate"] as! String, endDate: image["enddate"] as! String, url: image["url"] as! String, description: image["copyright"] as! String, copyrightLink: image["copyrightlink"] as! String)
    }

    return imageDescriptors
  }

  static func downloadImageDescriptors(numberOfImages: Int) -> [ImageDescriptorOld] {
    let json = DownloadManager.downloadJson(numberOfImages: numberOfImages)
    return getImageDescriptors(json: json)
  }

  static func imageDownloadPath(descriptor: ImageDescriptorOld) -> URL {
    return FileHandler.defaultBingWallpaperDirectory().appendingPathComponent(descriptor.startDate + ".jpg")
  }

  static func saveToDisk(descriptor: inout ImageDescriptorOld) {
    guard let image = descriptor.image else { return }
    FileHandler.saveImageToDisk(image: image, toUrl: imageDownloadPath(descriptor: descriptor))
  }

  static func isSavedToDisk(descriptor: ImageDescriptorOld) -> Bool {
    let imagePath = FileHandler.defaultBingWallpaperDirectory() + "/" + descriptor.startDate + ".jpg"
    return FileManager.default.fileExists(atPath: imagePath)
  }

  static func loadImageFromDisk(descriptor: ImageDescriptorOld) -> NSImage? {
    let imageUrl = imageDownloadPath(descriptor: descriptor)
    do {
      let imageData = try Data(contentsOf: imageUrl)
      return NSImage(data: imageData)
    } catch {
      print("Failed to read image from path: \(imageUrl) with error: \(error)")
    }

    return nil
  }

  static func newest(descriptors: [ImageDescriptorOld]) -> ImageDescriptorOld? {
    return descriptors.sorted(by: { desc1, desc2 in desc1.startDate > desc2.startDate }).first
  }
}
