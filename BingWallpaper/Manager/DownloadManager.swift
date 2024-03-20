import Cocoa
import Foundation

class DownloadManager {
    
    private static func downloadData(from url: URL) async throws-> DownloadResponse {
        let (data, urlResponse) = try await URLSession.shared.data(from: url)
        return DownloadResponse(data: data, urlResponse: urlResponse)
    }
    
    private static func downloadHttpHead(from url: URL) async throws -> DownloadResponse {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
        return DownloadResponse(data: data, urlResponse: urlResponse)
    }
    
    static func downloadJson(numberOfImages: Int) async -> [String: Any] {
        // TODO: @2h4u: idx is the start index of the batch of image descriptors that is downloaded, maybe add support for it so more images from the past can be used?
        do {
            let response = try await downloadData(from: URL(string: "https://www.bing.com/HPImageArchive.aspx?format=js&n=\(numberOfImages)&idx=0")!)
            return try JSONSerialization.jsonObject(with: response.data, options: .mutableContainers) as! [String: Any]
        } catch {
            print(error)
            return [:]
        }
    }
    
    static func downloadImage(from url: URL) async -> NSImage? {
        do {
            let response = try await downloadData(from: url)
            return NSImage(data: response.data)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    static func downloadHtml(from url: URL) async -> String? {
        do {
            let response = try await downloadData(from: url)
            return String(data: response.data, encoding: .utf8)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    static func downloadHtmlHeaders(from url: URL) async -> URLResponse? {
        do {
            return try await downloadHttpHead(from: url).urlResponse
        } catch let error {
            print(error)
            return nil
        }
    }
    
    static func downloadBinary(from url: URL) async -> Data? {
        do {
            let response = try await downloadData(from: url)
            return response.data
        } catch let error {
            print(error)
            return nil
        }
    }
}
