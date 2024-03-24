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
    
    func download() async throws -> Data {
        guard let descriptor else {
            throw Error.missingDescriptor
        }
        return try await DownloadManager.downloadBinary(from: descriptor.imageUrl)
    }
    
    static func isSavedToDisk(descriptor: ImageDescriptor) -> Bool {
        let imagePath = FileHandler.defaultBingWallpaperDirectory() + "/" + descriptor.startDate + ".jpg"
        return FileManager.default.fileExists(atPath: imagePath)
    }
    
    func isOnDisk() -> Bool {
        return FileManager.default.fileExists(atPath: downloadPath.relativePath)
    }
    
    func saveToDisk(imageData: Data) throws {
        try FileHandler.saveImageDataToDisk(imageData: imageData, toUrl: downloadPath)
    }

}
