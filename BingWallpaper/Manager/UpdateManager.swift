import Foundation
import AppKit

protocol UpdateManagerDelegate: AnyObject {
    func imagesUpdated()
}

class UpdateManager {
    weak var delegate: UpdateManagerDelegate?
    private let settings = Settings()
    private var timer: Timer?
    
    func start() {
        assert(Thread.isMainThread)
        setupObserver()
        doUpdateOrSetTimer()
    }
    
    private func doUpdateOrSetTimer() {
        assert(Thread.isMainThread)
        
        if UpdateScheduleManager.isUpdateNecessary() {
            update()
            return
        }
        
        let nextFetchInterval = UpdateScheduleManager.nextFetchTimeInterval()
        print("Currently no update necessary, next update at \(Date().addingTimeInterval(nextFetchInterval))")
        
        timer = Timer.scheduledTimer(
            timeInterval: nextFetchInterval,
            target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: false
        )
    }
        
    private func cleanup() {
        guard let oldestDateStringToKeep = settings.oldestDateStringToKeep() else { return }
        ImageDescriptionHandler.deleteOldDescriptors(oldestDateStringToKeep: oldestDateStringToKeep)
        FileHandler.deleteOldImages(oldestDateStringToKeep: oldestDateStringToKeep)
    }
    
    private func setupObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(receiveSleepNote),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(receiveWakeNote),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    @objc func update() {
        print("Updating")
        assert(Thread.isMainThread)
        settings.lastUpdate = Date()
        
        DispatchQueue.global().async {
            ImageDescriptionHandler.downloadNewestImageDescriptors(maxNumberOfImages: 8)
                .filter { ImageDescriptionHandler.isSavedToDisk(descriptor: $0) == false }
                .forEach { descriptor in
                    descriptor.image = ImageDescriptionHandler.downloadImage(descriptor: descriptor)
                    ImageDescriptionHandler.saveToDisk(descriptor: descriptor)
                }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.cleanup()
                self.delegate?.imagesUpdated()
                let fetchInterval = UpdateScheduleManager.nextFetchTimeInterval()
                print("Update complete, next update at \(Date().addingTimeInterval(fetchInterval))")
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(
                    timeInterval: fetchInterval,
                    target: self,
                    selector: #selector(self.update),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
    }
    
    @objc func receiveSleepNote(note: NSNotification) {
        timer?.invalidate()
    }
    
    @objc func receiveWakeNote(note: NSNotification) {
        doUpdateOrSetTimer()
    }
}
