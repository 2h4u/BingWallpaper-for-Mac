//
//  AppUpdateManager.swift
//  BingWallpaper
//
//  Created by Laurenz Lazarus on 11.12.22.
//

import Foundation
import AppKit

class AppUpdateManager {
    
    private static let githubLatestReleaseUrl = URL(string: "https://github.com/2h4u/BingWallpaper-for-Mac/releases/latest")!
    private static let githubExpandedAssetsPrefix = "https://github.com/2h4u/BingWallpaper-for-Mac/releases/expanded_assets/"
    private static let githubDomain = "https://github.com"
    
    static func currentAppVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static func fetchLatestAppVersionFromGithub() -> String? {
        assert(Thread.isMainThread == false)
        let latestHtmlHeaders = DownloadManager.downloadHtmlHeaders(from: githubLatestReleaseUrl)
        return latestHtmlHeaders?.url?.lastPathComponent
    }
    
    private static func newVersionAvailable(_ currentAppVersion: String, _ latestAppVersion: String) -> Bool {
        let currentAppVersion = currentAppVersion.replacingOccurrences(of: "v", with: "")
        let latestAppVersion = latestAppVersion.replacingOccurrences(of: "v", with: "")
        return currentAppVersion.versionCompare(latestAppVersion) == .orderedAscending
    }
    
    static func checkForUpdate(notifyUserAboutNoNewVersion:Bool = false) {
        DispatchQueue.global().async {
            guard let latestGithubAppVersion = fetchLatestAppVersionFromGithub() else {
                print("Failed to fetch latest app version from github")
                return
            }
            
            let currentAppVersion = currentAppVersion()
            
            if newVersionAvailable(currentAppVersion, latestGithubAppVersion) == false {
                print("No app update requiered, \(currentAppVersion) is alread the newest version")
                
                if notifyUserAboutNoNewVersion == true {
                    DispatchQueue.main.async {
                        showAlreadUpToDateDialog()
                    }
                }
                return
            }
            
            if let pkgInstallerPathUrl = FileHandler.pkgInstallerAlreadyDownloaded(appVersion: latestGithubAppVersion) {
                DispatchQueue.main.async {
                    if showShouldUpdateNowDialog(currentAppVersion: currentAppVersion, latestAppVersion: latestGithubAppVersion) == true {
                        NSWorkspace.shared.open(pkgInstallerPathUrl)
                    }
                }
                return
            }
            
            
            guard let pkgInstaller = downloadLatestInstallerFromGithub(latestGithubAppVersion: latestGithubAppVersion) else {
                print("Failed to download latest app installer from github")
                return
            }
            
            guard let pkgInstallerPathUrl = FileHandler.savePkgInstallerToDisk(pkgInstaller: pkgInstaller, appVersion: latestGithubAppVersion) else {
                return
            }
            
            DispatchQueue.main.async {
                if showShouldUpdateNowDialog(currentAppVersion: currentAppVersion, latestAppVersion: latestGithubAppVersion) == true {
                    NSWorkspace.shared.open(pkgInstallerPathUrl)
                }
            }
        }
    }
    
    static func downloadLatestInstallerFromGithub(latestGithubAppVersion: String) -> Data? {
        var githubExpandedAssetsUrl = URL(string: githubExpandedAssetsPrefix)!
        githubExpandedAssetsUrl.appendPathComponent(latestGithubAppVersion)
        
        guard let html = DownloadManager.downloadHtml(from: githubExpandedAssetsUrl) else { return nil }
        
        guard let aHref = html.split(separator: "\n").filter({ line in line.contains(".pkg") && line.contains("/\(latestGithubAppVersion)/")}).first else {
            assertionFailure("Failed to extract pkg link from latest github release website: \(html)")
            return nil
         }
        
        let newAppVersionDownloadPostfix = aHref.components(separatedBy: "href=\"").dropFirst().first!.components(separatedBy: "\"").first!
        
        var newAppVersionDownloadUrl = URL(string: githubDomain)!
        newAppVersionDownloadUrl.appendPathComponent(newAppVersionDownloadPostfix)

        return DownloadManager.downloadBinary(from: newAppVersionDownloadUrl)
    }
    
    
    private static func showShouldUpdateNowDialog(currentAppVersion: String, latestAppVersion: String) -> Bool {
        let currentAppVersion = currentAppVersion.replacingOccurrences(of: "v", with: "")
        let latestAppVersion = latestAppVersion.replacingOccurrences(of: "v", with: "")
        let alert = NSAlert()
        alert.messageText = "New version of BingWallpaper available"
        alert.informativeText = "Do you want to update now?\nCurrent version: \(currentAppVersion)\nNew version: \(latestAppVersion)"
        let updateButton = alert.addButton(withTitle: "Upate")
        alert.addButton(withTitle: "Later")
        alert.alertStyle = .informational
        
        alert.window.defaultButtonCell = updateButton.cell as? NSButtonCell
        
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    private static func showAlreadUpToDateDialog() {
        let alert = NSAlert()
        alert.messageText = "BingWallpaper already up to date"
        alert.informativeText = "There is no new version of BingWallpaper available"
        let updateButton = alert.addButton(withTitle: "Ok")
        alert.alertStyle = .informational
        
        alert.window.defaultButtonCell = updateButton.cell as? NSButtonCell
        
        alert.runModal()
    }
    
}
