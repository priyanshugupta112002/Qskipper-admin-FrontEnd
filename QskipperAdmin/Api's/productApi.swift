//
//  productApi.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 03/06/24.
//

import Foundation
import UIKit

class productApi{
    
    static let shared = productApi()
//    let baseUrl = URL(string: "https://queueskipperbackend.onrender.com/")!
    let baseUrl = URL(string: "https://qskipperbackend.onrender.com/")!
    
    // Image cache
    private let imageCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        // Create cache directory in the documents folder
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsDirectory.appendingPathComponent("ImageCache")
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating cache directory: \(error.localizedDescription)")
        }
    }
    
    // Cache an image
    private func cacheImage(_ image: UIImage, forKey key: String) {
        imageCache.setObject(image, forKey: key as NSString)
        saveImageToDisk(image, forKey: key)
        print("Image cached for key: \(key)")
    }
    
    // Get image from cache
    private func getCachedImage(forKey key: String) -> UIImage? {
        // First try memory cache
        if let cachedImage = imageCache.object(forKey: key as NSString) {
            print("Used cached image from memory for key: \(key)")
            return cachedImage
        }
        
        // If not in memory, try disk cache
        if let diskCachedImage = getImageFromDisk(forKey: key) {
            // Update memory cache
            imageCache.setObject(diskCachedImage, forKey: key as NSString)
            print("Used cached image from disk for key: \(key)")
            return diskCachedImage
        }
        
        return nil
    }
    
    // Save image to disk
    private func saveImageToDisk(_ image: UIImage, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Could not convert image to data for key: \(key)")
            return
        }
        
        do {
            try data.write(to: fileURL)
            print("Image saved to disk for key: \(key)")
        } catch {
            print("Error saving image to disk: \(error.localizedDescription)")
        }
    }
    
    // Get image from disk
    private func getImageFromDisk(forKey key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image from disk: \(error.localizedDescription)")
            return nil
        }
    }
    
    enum productApiError : Error , LocalizedError{
        case productNotFound
        case ImageNotFound
        case productCanNotUpdated
    }
    
    
    func getAllProduct() async throws -> [Product] {
        
        
        let productUrl = baseUrl.appendingPathComponent("get_all_product/\(DataControlller.shared.restaurant.id)")
        let request = URLRequest(url:productUrl)
        
        let(data , response) = try await URLSession.shared.data(for: request)
        
        if let string = String(data: data, encoding: .utf8)
        {
            debugPrint(string)
            debugPrint("get all product")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else{
            
            throw productApiError.productNotFound
            
        }
        let decoder = JSONDecoder()
        let userResponse = try decoder.decode(ProductResponse.self, from: data)
        
        return userResponse.products
    }
    
    
    func fetchImage(from url :URL) async throws -> UIImage{
        
        // Create a URL string to use as cache key
        let urlString = url.absoluteString
        
        // Check if image exists in cache
        if let cachedImage = getCachedImage(forKey: urlString) {
            print("Using cached image for URL: \(urlString)")
            return cachedImage
        }
        
        print("Fetching image from network: \(urlString)")
        
        let(data , response) = try await URLSession.shared.data(from: url)
        
                if let string = String(data: data, encoding: .utf8)
                {
                    print("done doen")
                   debugPrint(string)
                }
        debugPrint("sbse phle")
        debugPrint(response)
        guard let httpResponse = response as? HTTPURLResponse , httpResponse.statusCode == 200  else{
            
                throw productApiError.ImageNotFound
            }
        debugPrint("aagya")
//            let decoder = JSONDecoder()
//            let productImage = try decoder.decode(Image.self, from: data)
//        / Create a UIImage from the data
            guard let image = UIImage(data: data) else {
                throw productApiError.ImageNotFound
            }
            
//        guard let image = UIImage(data: productImage.product_photo)else{
//                throw productApiError.ImageNotFound
//            }
        debugPrint(image)
        
        // Cache the downloaded image
        cacheImage(image, forKey: urlString)
        print("Image downloaded and cached for URL: \(urlString)")
            
        return image
            
        }
    
    
    func getAllOrder() async throws -> orderResponse {

        let productUrl = baseUrl.appendingPathComponent("get-order/\(DataControlller.shared.Currentuser.id)")
        debugPrint(DataControlller.shared.Currentuser.id);
        var request = URLRequest(url:productUrl)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let(data , response) = try await URLSession.shared.data(for: request)
        
        if let string = String(data: data, encoding: .utf8)
        {
//            debugPrint(string)
            debugPrint("get all product")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else{
            
            throw productApiError.productNotFound
            
        }
        let decoder = JSONDecoder()
        let userResponse = try decoder.decode(orderResponse.self, from: data)
        debugPrint(productUrl)
        debugPrint(userResponse)
        
        return userResponse
    }
 
    
    func OrderComplete(orderId:String) async throws {

        let productUrl = baseUrl.appendingPathComponent("order-complete/\(orderId)")
        var  request = URLRequest(url:productUrl)
        request.httpMethod = "PUT"
        
        let(data , response) = try await URLSession.shared.data(for: request)
        
        if let string = String(data: data, encoding: .utf8)
        {
//            debugPrint(string)
            debugPrint("get all product")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 202 else{
            
            throw productApiError.productNotFound
            
        }
        let decoder = JSONDecoder()
        let userResponse = try decoder.decode(orderResponse.self, from: data)
        
        debugPrint(userResponse)
     
    }
    
    
    
  
    }
    
    

