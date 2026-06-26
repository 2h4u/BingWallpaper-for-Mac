import AppKit
import Foundation
import OSLog

private let logger = Logger(
    subsystem: Logging.subsystem,
    category: Logging.Category.Wallpaper.rawValue
)

class WallpaperManager {
    private var imageDescriptor: ImageDescriptor?
    static let shared = WallpaperManager()
    
    private init() {
        setupObserver()
    }
    
    private func setupObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(WallpaperManager.activeWorkspaceDidChange),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(WallpaperManager.workspaceDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(WallpaperManager.screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc func activeWorkspaceDidChange() {
        updateWallpaperIfNeeded()
    }

    @objc func workspaceDidWake() {
        updateWallpaperIfNeeded()
    }

    @objc func screenParametersDidChange() {
        updateWallpaperIfNeeded()
    }
    
    func setWallpaper(descriptor: ImageDescriptor) {
        imageDescriptor = descriptor
        updateWallpaperIfNeeded()
    }
    
    private func updateWallpaperIfNeeded() {
        guard let descriptor = imageDescriptor else { return }
        let imageUrl = descriptor.image.downloadPath
        let workspace = NSWorkspace.shared
        
        do {
            for screen in NSScreen.screens {
                try workspace.setDesktopImageURL(imageUrl, for: screen, options: [:])
            }
        } catch {
            logger.error("Failed to set desktop image: \(error.localizedDescription, privacy: .public)")
        }
    }
}
