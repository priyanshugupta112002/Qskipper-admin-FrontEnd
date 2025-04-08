//
//  user.swift
//  QskipperAdmin
//
//  Created by Batch-1 on 28/05/24.
//

import Foundation
import UIKit


struct user: Codable  {
    var id :String = ""
    var email: String = ""
    var password: String = ""
    var securityCode: String = "0"
}


struct User:Codable{
    
    var id:String = ""
    enum CodingKeys :String ,CodingKey{
        case id
    }
}





struct UserResponse : Codable{
    var id:String = ""
    var restaurantid :String = ""
    var restaurantName:String = ""
    var resturantEstimateTime:Int = 0
    var resturantphoto : UIImage?
    var resturantCusine : String = ""
    
    
    enum CodingKeys : String ,CodingKey{
        case id = "id"
        case restaurantid
        case restaurantName
        case resturantEstimateTime
        case resturantCusine
        
    }
}

