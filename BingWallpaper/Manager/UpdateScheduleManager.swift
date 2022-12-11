//
//  UpdateScheduleManager.swift
//  BingWallpaper
//
//  Created by Laurenz Lazarus on 06.11.22.
//

import Foundation

public class UpdateScheduleManager {
    
    private static let FETCH_INTERVAL: Double = 3600 * 3
    
    private init() { }
    
    public static func isUpdateNecessary() -> Bool {
        return nextFetchTimeInterval() == 0
    }
    
    public static func nextFetchTimeInterval() -> TimeInterval {
        let lastUpdate = Settings().lastUpdate
        return max(0, FETCH_INTERVAL - abs(lastUpdate.timeIntervalSinceNow))
    }
        
}

