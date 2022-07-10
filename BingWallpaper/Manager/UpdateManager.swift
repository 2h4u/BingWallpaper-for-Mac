import Foundation

protocol UpdateManagerDelegate: AnyObject {
  func imagesUpdated()
}

class UpdateManager {
  weak var delegate: UpdateManagerDelegate?
  private let settings = Settings()
  private var timer: Timer?
  private let refreshInterval: Double = 3600 * 24
    
  func start() {
    assert(Thread.isMainThread)
    
    let lastUpdate = settings.lastUpdate
    
    if isUpdateNecessary(lastUpdate) {
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
  
  private func isUpdateNecessary(_ lastUpdate: Date) -> Bool {
    return abs(lastUpdate.timeIntervalSinceNow) >= refreshInterval
    || ImageDescriptionHandler.imageDescriptorsFromDb().isEmpty
  }
  
  @objc func update() {
    print("Updating")
    assert(Thread.isMainThread)
    settings.lastUpdate = Date()
        
    DispatchQueue.global().async {
      ImageDescriptionHandler.downloadNewestImageDescriptors(maxNumberOfImages: 5)
        .filter { ImageDescriptionHandler.isSavedToDisk(descriptor: $0) == false }
        .forEach { descriptor in
          descriptor.image = ImageDescriptionHandler.downloadImage(descriptor: descriptor)
          ImageDescriptionHandler.saveToDisk(descriptor: descriptor)
        }
      
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.delegate?.imagesUpdated()
        
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
