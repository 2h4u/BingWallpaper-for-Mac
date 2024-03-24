import AppKit
import Foundation

class FileHandler {
    static func usersPictureDirectory() -> String {
        guard let picturesDirectory = NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true).first else {
            print("Couldn't find picture directory of user")
            return FileManager.default.homeDirectoryForCurrentUser.path
        }
        
        return picturesDirectory
    }
    
    static func defaultBingWallpaperDirectory() -> String {
        return usersPictureDirectory() + "/bing-wallpapers/"
    }
    
    static func defaultBingWallpaperDirectory() -> URL {
        return URL(fileURLWithPath: defaultBingWallpaperDirectory(), isDirectory: true)
    }
    
    static func createWallpaperFolderIfNeeded() {
        let bingDir: String = Settings().imageDownloadPath.path
        
        if FileManager.default.fileExists(atPath: bingDir) { return }
        
        do {
            try FileManager.default.createDirectory(atPath: bingDir, withIntermediateDirectories: false)
        } catch {
            print("Failed to create bing-wallpapers folder with error:\n\(error)")
        }
    }
    
    static func saveImageToDisk(image: NSImage, toUrl: URL) {
        guard let tiffRepresentation = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffRepresentation),
              let imageData = bitmap.representation(using: .jpeg, properties: [:]) else { return }
        
        do {
            try imageData.write(to: toUrl, options: .withoutOverwriting)
        } catch {
            print("Failed to save image to disk with error:\n\(error)")
        }
    }
    
    static func saveImageDataToDisk(imageData: Data, toUrl: URL) throws {
        try imageData.write(to: toUrl, options: .withoutOverwriting)
    }
    
    static func getSavedImages() -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(at: Settings().imageDownloadPath, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        } catch {
            print(error)
            return []
        }
    }
    
    static func removeImageFromDisk(imagePath: URL) {
        do {
            return try FileManager.default.removeItem(at: imagePath)
        } catch {
            print(error)
            return
        }
    }
    
    static func deleteOldImages(oldestDateStringToKeep: String) {
        getSavedImages()
            .filter { $0.lastPathComponent.replacingOccurrences(of: ".jpg", with: "") <= oldestDateStringToKeep }
            .forEach { removeImageFromDisk(imagePath: $0) }
    }
    
    static func savePkgInstallerToDisk(pkgInstaller: Data, appVersion: String) -> URL? {
        let temporaryDirectoryUrl = pkgInstallerPathUrl(appVersion: appVersion)
        do {
            try pkgInstaller.write(to: temporaryDirectoryUrl)
        } catch {
            print("Failed to save pkg installer to disk with error:\n\(error)")
            return nil
        }
        
        return temporaryDirectoryUrl
    }
    
    static func pkgInstallerAlreadyDownloaded(appVersion: String) -> URL? {
        let temporaryDirectoryUrl = pkgInstallerPathUrl(appVersion: appVersion)
        if FileManager.default.fileExists(atPath: temporaryDirectoryUrl.relativePath) == true {
            return temporaryDirectoryUrl
        }
        
        return nil
    }
    
    static func pkgInstallerPathUrl(appVersion: String) -> URL {
        var temporaryDirectoryUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        temporaryDirectoryUrl.appendPathComponent("BingWallpaper_" + appVersion + ".pkg")
        return temporaryDirectoryUrl
    }
}
