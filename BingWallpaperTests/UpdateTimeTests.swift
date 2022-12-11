//
//  UpdateTimeTests.swift
//  BingWallpaperTests
//
//  Created by Laurenz Lazarus on 31.10.22.
//

import XCTest
import BingWallpaper

final class UpdateTimeTests: XCTestCase {
    
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func testUpdateAfter3h() {
        let before3h = Date(timeIntervalSinceNow: -3 * 3600)
        let settings = Settings()
        settings.lastUpdate = before3h
        
        XCTAssertTrue(UpdateScheduleManager.isUpdateNecessary())
    }
    
    func testUpdateAfer2h() {
        let before2h = Date(timeIntervalSinceNow: -2 * 3600)
        let settings = Settings()
        settings.lastUpdate = before2h
        
        XCTAssertFalse(UpdateScheduleManager.isUpdateNecessary())
    }

}
