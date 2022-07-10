import Cocoa
import Foundation

class DownloadManager {
  static func downloadJson(numberOfImages: Int) -> [String: Any] {
    let response = downloadData(from: URL(string: "https://www.bing.com/HPImageArchive.aspx?format=js&n=\(numberOfImages)")!)

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
}
