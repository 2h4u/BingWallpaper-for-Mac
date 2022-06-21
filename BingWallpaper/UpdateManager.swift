import Foundation

class UpdateManager {
  private var wallpaperManager = WallpaperManager()

  func setup() {
    wallpaperManager.setupObserver()
    doUpdate(withDelay: 0)
  }

  func doUpdate(withDelay: Int) {
    DispatchQueue.global().asyncAfter(deadline: .now().advanced(by: DispatchTimeInterval.seconds(withDelay))) { [weak self] in
      let descriptors = ImageDescriptionHandler.downloadImageDescriptors(numberOfImages: 5)

      for var descriptor in descriptors {
        if ImageDescriptionHandler.isSavedToDisk(descriptor: descriptor) {
          continue
        }

        descriptor.image = ImageDescriptionHandler.downloadImage(descriptor: descriptor)
        ImageDescriptionHandler.saveToDisk(descriptor: &descriptor)
      }

      if let newestDescriptor = descriptors.sorted(by: { desc1, desc2 in desc1.startDate > desc2.startDate }).first {
        self?.wallpaperManager.setWallpaper(descriptor: newestDescriptor)
        self?.wallpaperManager.updateWallpaperIfNeeded()
      }

      self?.doUpdate(withDelay: 3600 * 12)
    }
  }
}
