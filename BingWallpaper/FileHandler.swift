import AppKit
import Foundation

class FileHandler {
  static func picturesDirectory() -> String {
    guard let picturesDirectory = NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true).first else {
      print("Couldn't find picture directory of user")
      return FileManager.default.homeDirectoryForCurrentUser.path
    }

    return picturesDirectory
  }

  static func bingWallpaperDirectory() -> String {
    return picturesDirectory() + "/bing-wallpapers/"
  }

  static func bingWallpaperDirectory() -> URL {
    return URL(fileURLWithPath: bingWallpaperDirectory(), isDirectory: true)
  }

  static func createWallpaperFolderIfNeeded() {
    let bingDir: String = bingWallpaperDirectory()

    if FileManager.default.fileExists(atPath: bingDir) { return }

    do {
      try FileManager.default.createDirectory(atPath: bingDir, withIntermediateDirectories: false)
    } catch {
      print("Failed to create bing-wallpapers folder with error:\n\(error)")
    }
  }

  static func saveImageToDisk(image: NSImage, toUrl: URL) -> Bool {
    guard let tiffRepresentation = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffRepresentation),
          let imageData = bitmap.representation(using: .jpeg, properties: [:]) else { return false }

    do {
      try imageData.write(to: toUrl, options: .withoutOverwriting)
      return true
    } catch {
      print("Failed to save image to disk with error:\n\(error)")
      return false
    }
  }

  static func getSavedImages() -> [URL] {
    do {
      return try FileManager.default.contentsOfDirectory(at: bingWallpaperDirectory(), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
    } catch {
      print(error)
      return []
    }
  }
}
