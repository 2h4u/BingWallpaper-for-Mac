import Cocoa
import Foundation

class ImageDescriptionHandler {
  static func downloadImage(descriptor: ImageDescriptor) -> NSImage? {
    return DownloadManager.downloadImage(from: descriptor.imageUrl())
  }

  static func getImageDescriptors(json: [String: Any]) -> [ImageDescriptor] {
    guard json.isEmpty == false,
          let images = json["images"] as? [[String: Any]]
    else {
      return []
    }

    let imageDescriptors = images.map { image -> ImageDescriptor in
      ImageDescriptor(startDate: image["startdate"] as! String, endDate: image["enddate"] as! String, url: image["url"] as! String, description: image["copyright"] as! String, copyrightLink: image["copyrightlink"] as! String)
    }

    return imageDescriptors
  }

  static func downloadImageDescriptors(numberOfImages: Int) -> [ImageDescriptor] {
    let json = DownloadManager.downloadJson(numberOfImages: numberOfImages)
    return getImageDescriptors(json: json)
  }

  static func imageDownloadPath(descriptor: ImageDescriptor) -> URL {
    return FileHandler.bingWallpaperDirectory().appendingPathComponent(descriptor.startDate + ".jpg")
  }

  static func saveToDisk(descriptor: inout ImageDescriptor) {
    guard let image = descriptor.image else { return }
    FileHandler.saveImageToDisk(image: image, toUrl: imageDownloadPath(descriptor: descriptor))
  }

  static func isSavedToDisk(descriptor: ImageDescriptor) -> Bool {
    let imagePath = FileHandler.bingWallpaperDirectory() + "/" + descriptor.startDate + ".jpg"
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
}
