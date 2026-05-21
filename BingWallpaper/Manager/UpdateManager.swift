import Foundation
import AppKit
import OSLog

private let logger = Logger(
    subsystem: Logging.subsystem,
    category: Logging.Category.Update.rawValue
)

protocol UpdateManagerDelegate: AnyObject {
    @MainActor
    func downloadedNewImage()
}

final class UpdateManager: @unchecked Sendable {
    private static let ACTIVITY_IDENTIFIER = "com.2h4u.BingWallpaper.update"

    weak var delegate: UpdateManagerDelegate?
    private let settings = Settings()
    private var activity: NSBackgroundActivityScheduler?
    private var pendingCompletion: NSBackgroundActivityScheduler.CompletionHandler?

    @MainActor
    func start() {
        setupObserver()
        doUpdateOrScheduleActivity()
    }

    @MainActor
    private func doUpdateOrScheduleActivity() {
        if UpdateScheduleManager.isUpdateNecessary() {
            update()
            return
        }

        scheduleNextActivity()
    }

    @MainActor
    private func scheduleNextActivity() {
        let nextFetchInterval = UpdateScheduleManager.nextFetchTimeInterval()
        logger.info("Currently no update necessary, next update at \(Date().addingTimeInterval(nextFetchInterval), privacy: .public)")

        activity?.invalidate()

        let scheduler = NSBackgroundActivityScheduler(identifier: UpdateManager.ACTIVITY_IDENTIFIER)
        scheduler.repeats = false
        scheduler.interval = nextFetchInterval
        scheduler.tolerance = min(nextFetchInterval / 2, 60 * 30)
        scheduler.qualityOfService = .utility
        scheduler.schedule { completion in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    completion(.finished)
                    return
                }
                self.pendingCompletion = completion
                self.update()
            }
        }

        activity = scheduler
    }
        
    @MainActor
    private func cleanup() {
        // TODO: @2h4u: find entries with same startDate and remove them
        // TODO: @2h4u: probably do this in a migration function in appdelegate
        
        guard let oldestDateStringToKeep = settings.oldestDateStringToKeep() else { return }
        try? Database.instance.deleteImageDescriptors(olderThan: oldestDateStringToKeep)
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
        logger.info("Updating")
        settings.lastUpdate = Date()
        
        Task { [weak self] in
            
            let imageEntries: [DownloadManager.ImageEntry]
            do {
                imageEntries = try await DownloadManager.downloadImageEntries(numberOfImages: 8)
            } catch {
                logger.error("Failed to download image entries with error: \(error.localizedDescription, privacy: .public)")
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    let completion = self.pendingCompletion
                    self.pendingCompletion = nil
                    completion?(.deferred)
                    self.scheduleNextActivity()
                }
                return
            }
            
           let descriptors = Database.instance.updateImageDescriptors(from: imageEntries)
            
           let newDescriptors = descriptors
                .filter { $0.image.isOnDisk() == false }
            
            for descriptor in newDescriptors {
                do {
                    try await descriptor.image.downloadAndSaveToDisk()
                } catch {
                    logger.error("Failed to download and store image \(descriptor.imageUrl, privacy: .public) with error: \(error.localizedDescription, privacy: .public)")
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.cleanup()
                if newDescriptors.isEmpty == false {
                    self.delegate?.downloadedNewImage()
                }

                let completion = self.pendingCompletion
                self.pendingCompletion = nil
                completion?(.finished)

                self.scheduleNextActivity()
            }
        }
    }
    
    @MainActor
    @objc func receiveSleepNote(note: NSNotification) {
        activity?.invalidate()
    }

    @MainActor
    @objc func receiveWakeNote(note: NSNotification) {
        doUpdateOrScheduleActivity()
    }
}
