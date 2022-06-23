import Foundation

protocol UpdateManagerDelegate {
  func imagesUpdated(descriptors: [ImageDescriptor])
}

class UpdateManager {
  var wallpaperManager: WallpaperManager?
  var delegate: UpdateManagerDelegate?

  func start() {
    doUpdate(withDelay: 0)
  }

  func doUpdate(withDelay: Int) {
    DispatchQueue.global().asyncAfter(deadline: .now().advanced(by: DispatchTimeInterval.seconds(withDelay))) { [weak self] in
      var descriptors = ImageDescriptionHandler.downloadImageDescriptors(numberOfImages: 5)

      descriptors = descriptors.map { descriptor in
        var descriptor = descriptor
        if ImageDescriptionHandler.isSavedToDisk(descriptor: descriptor) {
          descriptor.image = ImageDescriptionHandler.loadImageFromDisk(descriptor: descriptor)
          return descriptor
        }

        descriptor.image = ImageDescriptionHandler.downloadImage(descriptor: descriptor)
        ImageDescriptionHandler.saveToDisk(descriptor: &descriptor)
        return descriptor
      }

      DispatchQueue.main.async {
        self?.delegate?.imagesUpdated(descriptors: descriptors)
      }

      if let newestDescriptor = ImageDescriptionHandler.newest(descriptors: descriptors) {
        self?.wallpaperManager?.setWallpaper(descriptor: newestDescriptor)
      }

      self?.doUpdate(withDelay: 3600 * 12)
    }
  }
}
