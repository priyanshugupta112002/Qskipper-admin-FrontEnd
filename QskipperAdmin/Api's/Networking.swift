//
//  Networking.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 29/05/24.
//
import UIKit

import Foundation

class Networking {
    
    static let shared = Networking()
    let baseUrl = URL(string: "https://qskipperbackend.onrender.com/")!
    
    
    enum NetworkingError : Error , LocalizedError{
        case userNotRegister
    }
    
    func registerUser(currentUser: user) async throws -> User?
    {
        
        let registerUrl = baseUrl.appendingPathComponent("resturant-register")
        var request = URLRequest(url:registerUrl)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        
        
        let jsonEncoder = JSONEncoder()
        
        let jsonData = try? jsonEncoder.encode(currentUser)
        request.httpBody = jsonData
        
        let(data , response) = try await URLSession.shared.data(for: request)
        
        
        if let string = String(data: data, encoding: .utf8)
        {
           debugPrint(string)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 202 else{
            
            throw NetworkingError.userNotRegister
        }
        let decoder = JSONDecoder()
        let userResponse = try decoder.decode(User.self, from: data)
        
        
        
        return userResponse
        
        
    }
    
    
    func loginUser(currentUser:user) async throws ->UserResponse?{
        let registerUrl = baseUrl.appendingPathComponent("resturant-login")
        var request = URLRequest(url:registerUrl)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField:  "Content-Type")
      
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(currentUser)
        request.httpBody = jsonData
        
        let(data , response) = try await URLSession.shared.data(for: request)
        print("hjhj")
        
//        if let string = String(data: data, encoding: .utf8)
//        {
//           debugPrint(string)
//        }
       
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else{
            
            throw NetworkingError.userNotRegister
        }
        let decoder = JSONDecoder()
        let userResponse = try decoder.decode(UserResponse.self, from: data)
       
        print(userResponse)
        print("ccwdcd")
        
        
        return userResponse
        
    }
    
    
}


