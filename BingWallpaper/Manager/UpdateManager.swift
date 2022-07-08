import Foundation

protocol UpdateManagerDelegate: AnyObject {
  func imagesUpdated(descriptors: [ImageDescriptorOld])
}

class UpdateManager {
  weak var delegate: UpdateManagerDelegate?
  private let settings = Settings()
  private var timer: Timer?
  private let refreshInterval: Double = 3600 * 6

  func start() {
    let lastUpdate = settings.lastUpdate

    if abs(lastUpdate.timeIntervalSinceNow) >= refreshInterval {
      update()
      return
    }

    timer = Timer.scheduledTimer(
      timeInterval: refreshInterval - abs(lastUpdate.timeIntervalSinceNow),
      target: self,
      selector: #selector(update),
      userInfo: nil,
      repeats: false
    )
  }

  @objc func update() {
    print("Updating")
    settings.lastUpdate = Date()

    DispatchQueue.global().async { [weak self] in
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
        guard let self = self else { return }
        self.delegate?.imagesUpdated(descriptors: descriptors)

        if let newestDescriptor = ImageDescriptionHandler.newest(descriptors: descriptors) {
          WallpaperManager.shared.setWallpaper(descriptor: newestDescriptor)
        }

        print("Update complete, next update at \(Date().addingTimeInterval(self.refreshInterval))")
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
          timeInterval: self.refreshInterval,
          target: self,
          selector: #selector(self.update),
          userInfo: nil,
          repeats: false
        )
      }
    }
  }
}
