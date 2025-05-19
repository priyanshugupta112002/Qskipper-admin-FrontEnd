
import Foundation

struct orderResponse:Codable{
    var length:Int = 0

    var order :[OrderProduct ] = []

        enum  CodingKeys: String, CodingKey {
        case length = "length"
        case order = "all_orders"
    }

    
}
struct OrderProduct:Codable{
    var status:String = ""
    var totalPrice :String = ""
    var id :String = ""
    var items:[item] = []
    var takeAway :Bool = true
    var scheduleDate:String?
    
    
    enum CodingKeys :String ,CodingKey{
        case status = "status"
        case totalPrice="totalAmount"
        case id = "_id"
        case items
        case takeAway = "takeAway"
        case scheduleDate = "scheduleDate"
    }
}
struct item:Codable{
    var id:String = ""
    var product_name :String = ""
    var quantity :Int = 1
    var product_price :Int = 0
    
    enum CodingKeys :String , CodingKey{
        case id = "productId"
        case product_name = "name"
        case quantity = "quantity"
        case product_price = "price"
    }

}
