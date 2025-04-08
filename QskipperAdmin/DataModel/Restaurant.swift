



import Foundation
import UIKit

struct Restaurant: Codable {
    var id:String = ""
    var user: String = ""
    var restaurant_Name: String = ""
    var banner_photo: UIImage?
    var bannerPhoto64Image: String = ""
    var cuisine: String = ""
    var estimatedTime: Int = 10
    var dish: [Dish] = []
    var rating: Double = 0.0

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user = "restaurantid"
        case restaurant_Name
        case bannerPhoto64Image
        case cuisine
        case estimatedTime
        case dish
        case rating
    }

//    init() {}
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        user = try container.decode(String.self, forKey: .user)
//        restaurant_Name = try container.decode(String.self, forKey: .restaurant_Name)
//        bannerPhoto64Image = try container.decode(String.self, forKey: .bannerPhoto64Image)
//        cuisine = try container.decode(String.self, forKey: .cuisine)
//        estimatedTime = try container.decode(Int.self, forKey: .estimatedTime)
//        dish = try container.decode([Dish].self, forKey: .dish)
//        rating = try container.decode(Double.self, forKey: .rating)
//        
//        if let imageData = Data(base64Encoded: bannerPhoto64Image) {
//            banner_photo = UIImage(data: imageData)
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(user, forKey: .user)
//        try container.encode(restaurant_Name, forKey: .restaurant_Name)
//        try container.encode(bannerPhoto64Image, forKey: .bannerPhoto64Image)
//        try container.encode(cuisine, forKey: .cuisine)
//        try container.encode(estimatedTime, forKey: .estimatedTime)
//        try container.encode(dish, forKey: .dish)
//        try container.encode(rating, forKey: .rating)
//    }
}

struct Dish: Codable {
    var image: String
    var name: String
    var description: String
    var price: Int
    var rating: Double
    var foodType: String

    enum CodingKeys: String, CodingKey {
        case image
        case name
        case description
        case price
        case rating
        case foodType
    }
}

var Cuisine: [String] = ["North India", "South Indian", "Chinese", "Fast Food" , "Drinks & Snacks"]
