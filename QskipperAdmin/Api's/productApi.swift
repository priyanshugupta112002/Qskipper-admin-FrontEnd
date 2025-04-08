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
        
        debugPrint("fetching image")
        
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
    
    

