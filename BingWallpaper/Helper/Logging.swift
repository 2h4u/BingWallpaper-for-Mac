//
//  Logging.swift
//  BingWallpaper
//
//  Created by Laurenz Lazarus on 21.05.26.
//

class Logging {
    private init() { }
    
    static let subsystem = "com.2h4u.BingWallpaper"
    
    enum Category: String {
        case Settings
        case Database
        case Download
        case FileHandler
        case Wallpaper
        case Update
        case AppUpdate
        case Menu
    }
}
