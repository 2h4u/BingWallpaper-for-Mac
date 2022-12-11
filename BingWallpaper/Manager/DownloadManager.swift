import Cocoa
import Foundation

class DownloadManager {
    
    private static func downloadData(from url: URL) -> DownloadResponse {
        assert(Thread.isMainThread == false)
        
        let semaphore = DispatchSemaphore(value: 0)
        var response: DownloadResponse!
        URLSession.shared.dataTask(with: url, completionHandler: { data, urlResponse, error in
            response = DownloadResponse(data: data, urlResponse: urlResponse, error: error)
            semaphore.signal()
        }).resume()
        
        semaphore.wait()
        return response
    }
    
    private static func downloadHttpHead(from url: URL) -> DownloadResponse {
        assert(Thread.isMainThread == false)
        
        let semaphore = DispatchSemaphore(value: 0)
        var response: DownloadResponse!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, urlResponse, error in
            response = DownloadResponse(data: data, urlResponse: urlResponse, error: error)
            semaphore.signal()
        }).resume()
        
        semaphore.wait()
        return response
    }
    
    static func downloadJson(numberOfImages: Int) -> [String: Any] {
        // TODO: @2h4u: idx is the start index of the batch of image descriptors that is downloaded, maybe add support for it so more images from the past can be used?
        let response = downloadData(from: URL(string: "https://www.bing.com/HPImageArchive.aspx?format=js&n=\(numberOfImages)&idx=0")!)
        
        if let error = response.error {
            print(error)
        }
        
        guard let data = response.data else {
            return [:]
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
        } catch {
            print(error)
            return [:]
        }
    }
    
    static func downloadImage(from url: URL) -> NSImage? {
        let response = downloadData(from: url)
        if let error = response.error {
            print(error)
        }
        
        guard let data = response.data else {
            return nil
        }
        
        return NSImage(data: data)
    }
    
    static func downloadHtml(from url: URL) -> String? {
        let response = downloadData(from: url)
        if let error = response.error {
            print(error)
        }
        
        guard let data = response.data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    static func downloadHtmlHeaders(from url: URL) -> URLResponse? {
        let response = downloadHttpHead(from: url)
        if let error = response.error {
            print(error)
        }
        
        return response.urlResponse
    }
    
    static func downloadBinary(from url: URL) -> Data? {
        let response = downloadData(from: url)
        if let error = response.error {
            print(error)
        }
        
        return response.data
    }
}
