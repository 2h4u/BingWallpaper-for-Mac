//
//  Image.swift
//  BingWallpaper
//
//  Created by Laurenz Lazarus on 23.03.24.
//

import Foundation

class Image {
    enum Error: Swift.Error {
        case missingDescriptor
    }
    
    let downloadPath: URL
    private weak var descriptor: ImageDescriptor?
    
    init(descriptor: ImageDescriptor) {
        self.descriptor = descriptor
        self.downloadPath = FileHandler.defaultBingWallpaperDirectory().appendingPathComponent(descriptor.startDate + ".jpg")
    }
    
    func loadFromDisk() async throws -> Data {
        return try Data(contentsOf: downloadPath)
    }
    
    func downloadAndSaveToDisk() async throws {
        guard let descriptor else {
            throw Error.missingDescriptor
        }
        let imageData = try await DownloadManager.downloadBinary(from: descriptor.imageUrl)
        try FileHandler.saveImageDataToDisk(imageData: imageData, toUrl: downloadPath)
    }
    
    static func isSavedToDisk(descriptor: ImageDescriptor) -> Bool {
        let imagePath = FileHandler.defaultBingWallpaperDirectory() + "/" + descriptor.startDate + ".jpg"
        return FileManager.default.fileExists(atPath: imagePath)
    }
    
    func isOnDisk() -> Bool {
        return FileManager.default.fileExists(atPath: downloadPath.relativePath)
    }
}
