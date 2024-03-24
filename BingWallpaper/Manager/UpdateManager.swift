import Foundation
import AppKit

protocol UpdateManagerDelegate: AnyObject {
    @MainActor
    func imagesUpdated()
}

class UpdateManager {
    weak var delegate: UpdateManagerDelegate?
    private let settings = Settings()
    private var timer: Timer?
    
    @MainActor 
    func start() {
        setupObserver()
        doUpdateOrSetTimer()
    }
    
    @MainActor 
    private func doUpdateOrSetTimer() {
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
        
    @MainActor
    private func cleanup() {
        // TODO: @2h4u: find entries with same startDate and remove them
        // TODO: @2h4u: probably do this in a migration function in appdelegate
        
        guard let oldestDateStringToKeep = settings.oldestDateStringToKeep() else { return }
        Database.instance.deleteImageDescriptors(olderThan: oldestDateStringToKeep)
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
    
    @MainActor
    @objc func update() {
        print("Updating")
        settings.lastUpdate = Date()
        
        Task { [weak self] in
            
            let imageEntries: [DownloadManager.ImageEntry]
            do {
                imageEntries = try await DownloadManager.downloadImageEntries(numberOfImages: 8)
            } catch {
                print("Failed to download image entries with error: \(error.localizedDescription)")
                return
            }
            
           let descriptors = Database.instance.updateImageDescriptors(from: imageEntries)
            
           let newDescriptors = descriptors
                .filter { $0.image.isOnDisk() == false }
            
            for descriptor in newDescriptors {
                do {
                    let imageData = try await descriptor.image.download()
                    try descriptor.image.saveToDisk(imageData: imageData)
                } catch {
                    print("Failed to download and store image with error: \(error.localizedDescription)")
                }
            }
            
            await MainActor.run { [weak self] in
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
    
    @MainActor 
    @objc func receiveSleepNote(note: NSNotification) {
        timer?.invalidate()
    }
    
    @MainActor 
    @objc func receiveWakeNote(note: NSNotification) {
        doUpdateOrSetTimer()
    }
}
