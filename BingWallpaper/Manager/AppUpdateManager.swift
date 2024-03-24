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
    
    static func fetchLatestAppVersionFromGithub() async -> String? {
        let latestHtmlHeaders = await DownloadManager.downloadHtmlHeaders(from: githubLatestReleaseUrl)
        return latestHtmlHeaders?.url?.lastPathComponent
    }
    
    private static func newVersionAvailable(_ currentAppVersion: String, _ latestAppVersion: String) -> Bool {
        let currentAppVersion = currentAppVersion.replacingOccurrences(of: "v", with: "")
        let latestAppVersion = latestAppVersion.replacingOccurrences(of: "v", with: "")
        return currentAppVersion.versionCompare(latestAppVersion) == .orderedAscending
    }
    
    static func checkForUpdate(notifyUserAboutNoNewVersion:Bool = false) async {
        guard let latestGithubAppVersion = await fetchLatestAppVersionFromGithub() else {
            print("Failed to fetch latest app version from github")
            return
        }
        
        let currentAppVersion = currentAppVersion()
        
        if newVersionAvailable(currentAppVersion, latestGithubAppVersion) == false {
            print("No app update requiered, \(currentAppVersion) is alread the newest version")
            
            if notifyUserAboutNoNewVersion == true {
                    await showAlreadyUpToDateDialog()
            }
            return
        }
        
        if let pkgInstallerPathUrl = FileHandler.pkgInstallerAlreadyDownloaded(appVersion: latestGithubAppVersion) {
            if await showShouldUpdateNowDialog(currentAppVersion: currentAppVersion, latestAppVersion: latestGithubAppVersion) == true {
                NSWorkspace.shared.open(pkgInstallerPathUrl)
            }
            return
        }
        
        
        guard let pkgInstaller = await downloadLatestInstallerFromGithub(latestGithubAppVersion: latestGithubAppVersion) else {
            print("Failed to download latest app installer from github")
            return
        }
        
        guard let pkgInstallerPathUrl = FileHandler.savePkgInstallerToDisk(pkgInstaller: pkgInstaller, appVersion: latestGithubAppVersion) else {
            return
        }
        
        if await showShouldUpdateNowDialog(currentAppVersion: currentAppVersion, latestAppVersion: latestGithubAppVersion) == true {
            NSWorkspace.shared.open(pkgInstallerPathUrl)
        }
    }
    
    static func downloadLatestInstallerFromGithub(latestGithubAppVersion: String) async -> Data? {
        var githubExpandedAssetsUrl = URL(string: githubExpandedAssetsPrefix)!
        githubExpandedAssetsUrl.appendPathComponent(latestGithubAppVersion)
        
        guard let html = await DownloadManager.downloadHtml(from: githubExpandedAssetsUrl) else { return nil }
        
        guard let aHref = html.split(separator: "\n").filter({ line in line.contains(".pkg") && line.contains("/\(latestGithubAppVersion)/")}).first else {
            assertionFailure("Failed to extract pkg link from latest github release website: \(html)")
            return nil
         }
        
        let newAppVersionDownloadPostfix = aHref.components(separatedBy: "href=\"").dropFirst().first!.components(separatedBy: "\"").first!
        
        var newAppVersionDownloadUrl = URL(string: githubDomain)!
        newAppVersionDownloadUrl.appendPathComponent(newAppVersionDownloadPostfix)

        return try? await DownloadManager.downloadBinary(from: newAppVersionDownloadUrl)
    }
    
    @MainActor
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
    
    @MainActor
    private static func showAlreadyUpToDateDialog() {
        let alert = NSAlert()
        alert.messageText = "BingWallpaper already up to date"
        alert.informativeText = "There is no new version of BingWallpaper available"
        let updateButton = alert.addButton(withTitle: "Ok")
        alert.alertStyle = .informational
        
        alert.window.defaultButtonCell = updateButton.cell as? NSButtonCell
        
        alert.runModal()
    }
    
}
